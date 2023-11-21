funcs=(add mul eq gt ge)
# size=(1000 1000000 10000000 100000000 1000000000)
# threads=(4 16 32 64)
sizes=(10 100)
threads=(1 4)

for func in "${funcs[@]}"; do  
  for s in "${sizes[@]}"; do  
    for t in "${threads[@]}"; do  
      echo "function: $func, size: $s, threads: $t"  
      ./exec/run.sh $func $s $t;
      sleep 3;
    done  
  done  
done 