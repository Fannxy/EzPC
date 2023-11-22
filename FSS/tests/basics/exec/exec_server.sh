logPrefix=$1; logOutter=$2

# execute client and server.
echo -n "[+] running p1..."
start_time=$(date +%s.%N)

cat ./input/input1.txt | ./main.out r=2 file=1 > ./output/tmp_output1.txt 2> $logPrefix"_server.txt"

end_time=$(date +%s.%N)  
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Server Time: $elapsed_time seconds." >> $logOutter

p1pid=$!
echo "done (PID = $p1pid)"