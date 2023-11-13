
#include "group_element.h"
#include "comms.h"
#include "dcf.h"
#include "mult.h"
#include <assert.h>
#include <utility>

#define DEBUG

void printBits(const __m128i var){
    unsigned char* bytePointer = (unsigned char*)&var;  
    for(int i = 0; i < sizeof(__m128i); i++) {  
        for(int j = 0; j < 8; j++) {  
            std::cerr << ((bytePointer[i] >> j) & 1);  
        }  
        std::cerr << " ";  
    }  
    std::cerr << "\n";  
}

void printBits(const uint64_t var){
    unsigned char* bytePointer = (unsigned char*)&var;  
    for(int i = sizeof(uint64_t) - 1; i >=0; i--) {  
        for(int j = 7; j >= 0; j--) {  
            std::cerr << ((bytePointer[i] >> j) & 1);  
        }  
        std::cerr << " ";  
    }  
    std::cerr << "\n";  
}


std::pair<DPFKeyPack, DPFKeyPack> keyGenDPF(int Bin, int Bout, GroupElement idx, GroupElement payload){

    // prepare: some blocks for bit extraction and mask.
    static const block notThreeBlock = toBlock(~0, ~3);
    static const block notOneBlock = toBlock(~0, ~1);
    static const block pt[2] = {ZeroBlock, OneBlock};

    // 0. initiate keys
    block *k0 = new block[Bin + 1]; // for CW^{0}, ..., CW^{n}.
    block *k1 = new block[Bin + 1];
    
    // 1. sample the random seeds.
    auto s = prng.get<std::array<block, 2>>(); // s[0] and s[1].
    // the last bit is for t^0, and set the t^0 different in s0 and s1.

    s[0] = (s[0] & notOneBlock) ^ ((s[1] & OneBlock) ^ OneBlock);
    k0[0] = s[0];
    k1[0] = s[1];
    block si[2][2]; // used for chained-seeds.

    // 2. generate CWs for each bit in idx.
    block ct[2]; // used to save the randomness.

    for(int i=0; i<Bin; i++){
        // get idx[i] to keep, idx[i]=1 meands keep=1; other wise keep=0.
        const u8 keep = static_cast<uint8_t>(idx.value >> (Bin - 1 - i)) & 1;
        auto idxi = toBlock(keep);

        // compute the random seeds.
        auto ss0 = s[0] & notThreeBlock;
        auto ss1 = s[1] & notThreeBlock;

        // generate randomness.
        AES ak0(ss0), ak1(ss1);
        ak0.ecbEncTwoBlocks(pt, ct);
        si[0][0] = ct[0]; si[0][1] = ct[1]; // randomness for party 0.
        ak1.ecbEncTwoBlocks(pt, ct);
        si[1][0] = ct[0]; si[1][1] = ct[1]; // randomness for party 1.

        // get the left and right info for correlated randomness.
        std::array<block, 2> siXOR{si[0][0] ^ si[1][0], si[0][1] ^ si[1][1]};
        std::array<block, 2> t{
            (OneBlock & siXOR[0]) ^ idxi ^ OneBlock,
            (OneBlock & siXOR[1]) ^ idxi
        };

        // get the scw by selecting left or right based on keep, here the first two bits are used for tl and tr.
        auto scw = siXOR[keep ^ 1] & notThreeBlock;
        k0[i+1] = k1[i+1] = scw ^ (t[0] << 1) ^ t[1]; //  the (i+1)th randomness.

        // update the chained seed.
        auto si0Keep = si[0][keep];
        auto si1Keep = si[1][keep];
        auto tKeep = t[keep];

        auto ti0 = lsb(s[0]);
        auto ti1 = lsb(s[1]);

        s[0] = si0Keep ^ (zeroAndAllOne[ti0] & (scw ^ tKeep));
        s[1] = si1Keep ^ (zeroAndAllOne[ti1] & (scw ^ tKeep));
    }

    // 3. compute the target group element.
    uint64_t s0_converted[1];
    uint64_t s1_converted[1];
    convert(Bout, 1, s[0] & notThreeBlock, s0_converted);
    convert(Bout, 1, s[1] & notThreeBlock, s1_converted);
    
    // std::cerr << "s0: " << s0_converted[0] << std::endl;
    // std::cerr << "s1: " << s1_converted[0] << std::endl;

    GroupElement *g0 = new GroupElement[1];
    g0[0] = s1_converted[0] - s0_converted[0] + payload;
    if(lsb(s[1]) == 1) g0[0] = g0[0] * -1;

    // std::cerr << "g0: " << g0[0] << std::endl;
    
    // 4. generate the corresponding keys.
    return std::make_pair(DPFKeyPack(Bin, Bout, 1, k0, g0), DPFKeyPack(Bin, Bout, 1, k1, g0));
}


void evalDPF(int party, GroupElement *res, GroupElement idx, const DPFKeyPack &key){

    // prepare: some blocks for bit extraction and mask.
    static const block notThreeBlock = toBlock(~0, ~3);
    static const block notOneBlock = toBlock(~0, ~1);
    static const block TwoBlock = toBlock(0, 2);
    static const block pt[2] = {ZeroBlock, OneBlock};

    // 1. parse the keys.
    block* cws = key.k;
    GroupElement g = *(key.g);
    auto cw0 = cws[0];
    auto s = cw0 & notThreeBlock; // extract the scw party.
    u8 t_prev = lsb(cw0);

    // 2. bitwise parse the keys and iterate the path.
    block ct[2];
    for(int i=0; i<key.Bin; i++){

        // get the bit in the path.
        const u8 keep = static_cast<uint8_t>(idx.value >> (key.Bin - 1 - i)) & 1;
        auto idxi = toBlock(keep);

        // get the corr-randomness.
        auto cwi = cws[i+1];
        auto si = cwi & notThreeBlock;
        block tsi[] = {((cwi >> 1) & OneBlock), (cwi & OneBlock)};

        AES ak(s);
        ak.ecbEncTwoBlocks(pt, ct); // ct: tL, sL, tR, sR.

        // update s and t.
        auto mask = zeroAndAllOne[t_prev];
        auto scw = ((si ^ tsi[keep]) & mask) ^ ct[keep];
        // auto scw = (si & mask) ^ ct[keep];
        s = scw & notThreeBlock;
        t_prev = lsb(scw);
    }

    // 3. compute the final value.
    uint64_t s_converted[1];
    convert(key.Bout, 1, s & notThreeBlock, s_converted);

    // std::cerr << "sc: " << s_converted[0] << std::endl;
    // std::cerr << "g: " << g << std::endl;

    GroupElement final_term = s_converted[0];
    if(t_prev == 1) final_term = final_term + g;
    else final_term = final_term;
    GroupElement res_ = (party == 0) ? final_term : -1 * final_term;
    res->value = res_.value;
}