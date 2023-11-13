#pragma once
#include "group_element.h"
#include "keypack.h"
#include <iostream>  
#include <nmmintrin.h> // for __m128i  


std::pair<DPFKeyPack, DPFKeyPack> keyGenDPF(int Bin, int Bout, GroupElement idx, GroupElement payload);

void evalDPF(int party, GroupElement *res, GroupElement idx, const DPFKeyPack &key);

void printBits(const __m128i var);

void printBits(const uint64_t var);