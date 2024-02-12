#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <initial_input_file.json>"
  exit 1
fi

initial_input_file="$1"
prefix=$(echo $initial_input_file | sed -E 's/(MAI_rech[0-9]+).*/\1/')
num=$(echo $prefix | grep -o -E '[0-9]+$')
input_files=($(ls ${prefix}*inputs.json | sort))
start_index=0

for i in "${!input_files[@]}"; do
   if [[ "${input_files[$i]}" = "${initial_input_file}" ]]; then
       start_index=$i
       break
   fi
done

for (( i=$start_index; i<${#input_files[@]}; i++ )); do
  input_file="${input_files[$i]}"
  log_file="${input_file%_inputs.json}.log"
  echo "Monitoring $log_file for 'Succeeded'"
  tail -f "$log_file" | awk '/Succeeded/ {exit} {print}'
  echo "'Succeeded' found in $log_file. Moving to the next log file..."
done

echo "Monitoring completed."

