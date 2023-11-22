# generate the ezpc code and test data.
func=$1; size=$2; num_threads=$3;
output=$4; data=$5; bitlen=$6;
program=$7;

python3 ./exec/test_basic.py --func $func --num_threads $num_threads --output $output --data_generation $data --size $size --bitlen $bitlen --program_generation $program