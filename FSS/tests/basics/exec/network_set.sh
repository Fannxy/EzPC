bandwidth=$1; latency=$2;

# setup the network
tc qdisc add dev eth0 handle 1: ingress;
tc filter add dev eth0 parent 1: protocol ip prio 50 u32 match ip src 0.0.0.0/0 flowid :1;
tc qdisc add dev eth0 root tbf rate ${bandwidth}mbit latency ${latency}ms burst ${bandwidth}mbit;
ssh ezpc1 "tc qdisc add dev eth0 handle 1: ingress; tc filter add dev eth0 parent 1: protocol ip prio 50 u32 match ip src 0.0.0.0/0 flowid :1; tc qdisc add dev eth0 root tbf rate "${bandwidth}"mbit latency "${latency}"ms burst "${bandwidth}"Mb";
