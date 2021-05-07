#! /bin/bash

#echo "Hello World, I am $USER at $HOST, nice to meet you!"
COUNT=1

title() {
  echo -e "\e[33m==> Case $COUNT : $*\e[0m"
  ((COUNT++))
}

source "$SH_PATH_ANIM/src/animation_progress_bar.sh"

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
for v in $(seq 1 100); do
  animation_progress_bar "[=]" "$v" 100 80
  sleep 0.01
done
for v in "${values[@]}"; do
  title "Real $v% with prefix"
  animation_progress_bar -p "   my file " "[=]" "$v" 100 70
  [[ $v -lt 100 ]] && echo
done
title "Animated with prefix!"
for v in $(seq 1 100); do
  animation_progress_bar -p "   my file " "[=]" "$v" 100 70
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

tput cnorm
