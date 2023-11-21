
logPrefix=$1

# compile the cpp file.
g++ -O3 -pthread -std=c++17 "-I../../../FSS/build/install/include" "main.cpp" "../../../FSS/build/install/lib/libfss.a" -o "main.out"

# execute dealer
echo -n "[+] running dealer..."
./main.out r=1 file=1 2> $logPrefix"_dealer.txt"
echo "done"

# execute client and server.
echo -n "[+] running p1..."
cat ./input/input1.txt | ./main.out r=2 file=1 > ./output/tmp_output1.txt 2> $logPrefix"_server.txt" &
p1pid=$!
echo "done (PID = $p1pid)"

echo -n "[+] running p2..."
cat ./input/input2.txt | ./main.out r=3 file=1 > ./output/tmp_output2.txt 2> $logPrefix"_client.txt"
echo "done"
echo -n "[+] waiting for p1..."
wait $p1pid
echo "done"
