#!/usr/bin/env bash

#load shell lib
. ./script_template.sh


set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)


parse_params "$@"
setup_colors

# script logic here
  echo "hello, you are in $script_dir"

# # script logic
# echo "Hello, you are in $script_dir"
# FORMAT=html
# #FORMAT=jfr
# PAUSE=20
# COUNT_THREAD=540
# PROFILE_ENV="-d 290 -e cpu"
# #PROFILE_ENV="-d 290 -e cpu,alloc,lock"


# DUMP_PATH=script_dir
# #username=jbadmin
# HOSTNAME=$(hostname --short)

# while true; do

#   #create folder
#   DATETIMEFOLDER=$(date +"%d-%m-%Y.%H_%M_%S")
#   DUMP_THREAD_PATH=$DUMP_PATH/threaddumps_$HOSTNAME.$DATETIMEFOLDER
#   mkdir "$DUMP_THREAD_PATH"
#   chmod -R 777 "$DUMP_THREAD_PATH"
#   echo "Thread_dumps"
#   echo "-------------------------------------------------------------------"
#   #find PIDs
#   PIDs=$(ps -ef | grep java | grep -e "Server:" -e "hazelcast" | grep -v grep | awk '{print $2}')
#   for i in $(seq 1 $COUNT_THREAD); do
#     DATETIME=$(date +"%d-%m-%Y.%H_%M_%S")

#     #create dumps
#     for pid in $PIDs; do
#       SERVERNAME=$(ps -ef | grep $pid | grep -o "Server:.*.]" | cut -d ':' -f 2 | cut -d ']' -f 1)
#       if [ -z "$SERVERNAME" ]; then
#         SERVERNAME="hazelcast"
#       fi
#       username=$(ps -u -p "$pid" | awk 'NR>1{print $1}')
#       top -b -n 1 -H -p "$pid" | sudo -u "$username" tee "$DUMP_THREAD_PATH/high-cpu.$HOSTNAME.$SERVERNAME.$DATETIME.out" >/dev/null
#       sudo -u "$username" jstack -l "$pid" | sudo -u "$username" tee "$DUMP_THREAD_PATH/javacore.$HOSTNAME.$SERVERNAME.$DATETIME.txt" >/dev/null
#       if ((i == 1 || i % 15 == 0)); then
#           sudo -u "$username" nohup "$DUMP_PATH/async-profiler/profiler.sh" $PROFILE_ENV -f \
#           "$DUMP_THREAD_PATH/profile.$HOSTNAME.$SERVERNAME.$DATETIME.$pid.$FORMAT" "$pid" >/dev/null 2>&1 &
#       fi
#       unset SERVERNAME
#     done
#     sleep $PAUSE

#   done
#   sleep $PAUSE
#   #archive folder
#   tar cvzf "$DUMP_THREAD_PATH.tgz" -C "$DUMP_PATH/" "threaddumps_$HOSTNAME.$DATETIMEFOLDER"
#   rm -rf "$DUMP_THREAD_PATH"
# done

msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"
