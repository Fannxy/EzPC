bitlen=$1; num_threads=$2

echo -n "[+] compiling test...";
current_dir=$(pwd -P)
cd ~/EzPC/FSS/build/; make install;
cd $current_dir;

fssc --bitlen ${BITLENGTH:=$bitlen} --num_threads ${NUM_THREADS:=$num_threads} main.ezpc 2> ./error/compile.log