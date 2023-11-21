logPrefix=$1

echo -n "[+] running p2..."
cat ./input/input2.txt | ./main.out r=3 file=1 > ./output/tmp_output2.txt 2> $logPrefix"_client.txt"
echo "done"
echo -n "[+] waiting for p1..."
echo "done"