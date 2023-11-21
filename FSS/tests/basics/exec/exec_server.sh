logPrefix=$1

# execute client and server.
echo -n "[+] running p1..."
cat ./input/input1.txt | ./main.out r=2 file=1 > ./output/tmp_output1.txt 2> $logPrefix"_server.txt"
p1pid=$!
echo "done (PID = $p1pid)"