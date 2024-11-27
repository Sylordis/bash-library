#! /usr/bin/env bash

COUNT=1

title() {
  echo -e "\e[33m==> Case $COUNT : $*\e[0m"
  ((COUNT++))
}

source "$SH_PATH_ANIM/animation_progress_bar.sh"

tput civis

title "Arguments"
animation_progress_bar
title "Arguments 2"
animation_progress_bar a b
title "All wrong"
animation_progress_bar "a" "a" "a" "a"
title "Wrong numbers"
animation_progress_bar "[=]" -1 .5 1
title "Wrong size with prefix"
animation_progress_bar -p "   hello " "[=]" 5 10 10

values=(0 25 33 40 50 66 75 100 150)
for v in "${values[@]}"; do
  title "Real $v%"
  animation_progress_bar "[=]" "$v" 100 80
  [[ $v -lt 100 ]] && echo
done

title "Animated!"
for v in $(seq 1 10); do
  animation_progress_bar "[=]" $(("$v" * 10)) 100 80
  sleep 0.01
done

for v in "${values[@]}"; do
  title "Real $v% with prefix"
  animation_progress_bar -p "   my file " "[=]" "$v" 100 70
  [[ $v -lt 100 ]] && echo
done

title "Animated with prefix!"
for v in $(seq 1 10); do
  animation_progress_bar -p "   my file " "[=]" $(("$v" * 10)) 100 70
  sleep 0.01
done

values=($(seq 10 54 300) 300)
for v in "${values[@]}"; do
  title "Real $v/300 with prefix and percentages"
  animation_progress_bar -% -p "   operation " "[=]" "$v" 300 80
  [[ $v -lt 300 ]] && echo
done

title "Animated with prefix and percentages!"
for v in "${values[@]}"; do
  animation_progress_bar -% -p "   operation " "[=]" "$v" 300 80
  sleep 0.01
done

title "Colored prefix"
animation_progress_bar -p " \e[31mHello\e[0m      " "[=]" 66 100 80
echo

title "Full length ($(tput cols)) with two fillings 66%"
animation_progress_bar "[#-]" 66 100
echo

title "Full length ($(tput cols)) with two fillings and percentages"
animation_progress_bar -% "[#-]" 66 100
echo

title "The whole shebang (length=$(tput cols))"
items=("/zabc/lib/long.avif" "/thevar/log/brr_suddenly.log" "/flopt/sbin/unto.map")
for item in "${items[@]}"; do
  current_index=0
  max_index=$((100 + $RANDOM % 100))
  while [[ $current_index -lt $max_index ]]; do
    animation_progress_bar -i "$item" -p "current" -cp "107;97" -cf "90" -c -% "|.-|" $current_index $max_index 80
    sleep 0.0001
    current_index=$(( current_index + $RANDOM % (max_index / 2)))
  done
  animation_progress_bar -i "$item" -p "done" -cp "107;97" -cf "90" -c -% "|.-|" $max_index $max_index 80
done
tput cnorm
