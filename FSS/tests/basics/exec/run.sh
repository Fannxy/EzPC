func=$1; size=$2; num_threads=$3;
output=false;
data=false;
program=true;
bitlen=64;

# generate the ezpc code and test data.
./exec/code_generation.sh $func $size $num_threads $output $data $bitlen $program;

# # compile the cpp file and run the code.
# ./exec/execute.sh ./log/$func
./exec/distribute_exec.sh ./log/$func-$size-$num_threads

# check the result if output is true.
if [ $output == true ]; then
    cmp -s ./output/tmp_output2.txt ./data/res.txt
    if [ $? -ne 0 ]; then
        echo "[-] test $func failed"
        exit 1
    fi
    echo "[+] test $func passed"
fi;