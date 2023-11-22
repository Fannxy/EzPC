logPrefix=$1
logOutter=$logPrefix"_outter.txt"

# in the server end

# first compile the cpp file
start_time=$(date +%s.%N)
g++ -O3 -pthread -std=c++17 "-I../../../FSS/build/install/include" "main.cpp" "../../../FSS/build/install/lib/libfss.a" -o "main.out"
end_time=$(date +%s.%N)  
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Compiling Time: $elapsed_time seconds." >> $logOutter

# then execute dealer
echo -n "[+] running dealer..."
start_time=$(date +%s.%N)
./main.out r=1 file=1 2> $logPrefix"_dealer.txt"
end_time=$(date +%s.%N)  
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Dealer Time: $elapsed_time seconds." >> $logOutter
echo "done"

# echo -n "[+] data transfer..."
# start_time=$(date +%s.%N)
# # distribute the client data to client end
# # scp ./client.dat client:~/EzPC/FSS/tests/basic/
# # scp ./main.out client:~/EzPC/FSS/tests/basic/
# end_time=$(date +%s.%N)  
# elapsed_time=$(echo "$end_time - $start_time" | bc)
# echo "Data Trans Time: $elapsed_time seconds." >> $logOutter
# echo "done"


# execute the server code on its own end.
./exec/exec_server.sh $logPrefix $logOutter &

# execute the client code on the client side
# ssh client "cd ~/EzPC/FSS/tests/basic/; sh ./exec/exec_client.sh"
start_time=$(date +%s.%N)
./exec/exec_client.sh $logPrefix $logOutter;
wait;
end_time=$(date +%s.%N)  
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Client Time: $elapsed_time seconds." >> $logOutter
