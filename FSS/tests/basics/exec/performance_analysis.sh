# funcs=(add mul eq gt ge)
# size=(1000 1000000 10000000 100000000 1000000000)
# threads=(4 16 32 64)

progress_log=./progress
funcs=(mul eq gt)
sizes=(10 12)
threads=(1 4)

total_tasks=$((${#funcs[@]} * ${#sizes[@]} * ${#threads[@]}))  
completed_tasks=0 

for s in "${sizes[@]}"; do 

  start_time=$(date +%s.%N)
  ./exec/data_generation.sh add $s 1 ./input/ true 64 false;
  end_time=$(date +%s.%N)  
  elapsed_time=$(echo "$end_time - $start_time" | bc) 
  echo "Data generation for $s. Time: $elapsed_time seconds." >> $progress_log

  for func in "${funcs[@]}"; do   
    for t in "${threads[@]}"; do  
      echo "function: $func, size: $s, threads: $t" >> $progress_log

      start_time=$(date +%s.%N)
      ./exec/run.sh $func $s $t;
      end_time=$(date +%s.%N)  
      elapsed_time=$(echo "$end_time - $start_time" | bc) 

      completed_tasks=$((completed_tasks + 1))  
      echo "Task $completed_tasks/$total_tasks completed. Exec time: $elapsed_time seconds." >> $progress_log

      sleep 3;
    done  
  done  
done 