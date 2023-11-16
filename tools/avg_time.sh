#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Outputs the average time of the execution of a command a given number of time.
# Thanks to https://stackoverflow.com/a/54920339/1467837.
# Args:
#       $1      <retries>   Number of times to repeat the command
#       $2      <cmd>   Command to repeat
#------------------------------------------------------------------------------
avg_time() {
    n=$1; shift
    (($# > 0)) || return                   # bail if no command given
    for ((i = 0; i < n; i++)); do
        { time -p "$@" &>/dev/null; } 2>&1 # ignore the output of the command
                                            # but collect time's output in stdout
    done | awk '
        /real/ { real = real + $2; nr++ }
        /user/ { user = user + $2; nu++ }
        /sys/  { sys  = sys  + $2; ns++}
        END    {
                    if (nr>0) printf("real %f\n", real/nr);
                    if (nu>0) printf("user %f\n", user/nu);
                    if (ns>0) printf("sys %f\n",  sys/ns)
                }'
}
