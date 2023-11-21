logPrefix=$1

# in the server end

# first compile the cpp file
g++ -O3 -pthread -std=c++17 "-I../../../FSS/build/install/include" "main.cpp" "../../../FSS/build/install/lib/libfss.a" -o "main.out"

# then execute dealer
echo -n "[+] running dealer..."
./main.out r=1 file=1 2> $logPrefix"_dealer.txt"
echo "done"

# distribute the client data to client end
# scp ./client.dat client:~/EzPC/FSS/tests/basic/
# scp ./main.out client:~/EzPC/FSS/tests/basic/

# execute the server code on its own end.
./exec/exec_server.sh $logPrefix &

# execute the client code on the client side
# ssh client "cd ~/EzPC/FSS/tests/basic/; sh ./exec/exec_client.sh"
./exec/exec_client.sh $logPrefix;
wait;
