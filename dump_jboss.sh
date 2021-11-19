#!/bin/bash
#JAVA_PATH=/usr/lib/jvm/jdk-8u77/jdk1.8.0_77

FORMAT=html
#FORMAT=jfr
PAUSE=20
COUNT_THREAD=540
PROFILE_ENV="-d 290 -e cpu"
#PROFILE_ENV="-d 290 -e cpu,alloc,lock"


DUMP_PATH=$(pwd)
#username=jbadmin
HOSTNAME=$(hostname --short)


catchInterrupt() {
  echo "Found interrupt...exiting"
  exit 0
}

catchError() {
  echo "Found error at Line $1...exiting"
  exit 1
}

trap "catchInterrupt" SIGHUP SIGINT SIGTERM
trap 'catchError $LINENO' ERR

while true; do

  #create folder
  DATETIMEFOLDER=$(date +"%d-%m-%Y.%H_%M_%S")
  DUMP_THREAD_PATH=$DUMP_PATH/threaddumps_$HOSTNAME.$DATETIMEFOLDER
  mkdir "$DUMP_THREAD_PATH"
  chmod -R 777 "$DUMP_THREAD_PATH"
  echo "Thread_dumps"
  echo "-------------------------------------------------------------------"
  #find PIDs
  PIDs=$(ps -ef | grep java | grep -e "Server:" -e "hazelcast" | grep -v grep | awk '{print $2}')
  for i in $(seq 1 $COUNT_THREAD); do
    DATETIME=$(date +"%d-%m-%Y.%H_%M_%S")

    #create dumps
    for pid in $PIDs; do
      SERVERNAME=$(ps -ef | grep $pid | grep -o "Server:.*.]" | cut -d ':' -f 2 | cut -d ']' -f 1)
      if [ -z "$SERVERNAME" ]; then
        SERVERNAME="hazelcast"
      fi
      username=$(ps -u -p "$pid" | awk 'NR>1{print $1}')
      top -b -n 1 -H -p "$pid" | sudo -u "$username" tee "$DUMP_THREAD_PATH/high-cpu.$HOSTNAME.$SERVERNAME.$DATETIME.out" >/dev/null
      sudo -u "$username" jstack -l "$pid" | sudo -u "$username" tee "$DUMP_THREAD_PATH/javacore.$HOSTNAME.$SERVERNAME.$DATETIME.txt" >/dev/null
      if ((i == 1 || i % 15 == 0)); then
        case $SERVERNAME in
        CBS*)
          sudo -u "$username" nohup "$DUMP_PATH/async-profiler/profiler.sh" $CBS_PROFILE_ENV -f "$DUMP_THREAD_PATH/profile.$HOSTNAME.$SERVERNAME.$DATETIME.$pid.$FORMAT" "$pid" >/dev/null 2>&1 &
          ;;
        FRONT*)
          sudo -u "$username" nohup "$DUMP_PATH/async-profiler/profiler.sh" $FRONT_PROFILE_ENV -f "$DUMP_THREAD_PATH/profile.$HOSTNAME.$SERVERNAME.$DATETIME.$pid.$FORMAT" "$pid" >/dev/null 2>&1 &
          ;;
        PLATFORM*)
          sudo -u "$username" nohup "$DUMP_PATH/async-profiler/profiler.sh" $PLATFORM_PROFILE_ENV -f "$DUMP_THREAD_PATH/profile.$HOSTNAME.$SERVERNAME.$DATETIME.$pid.$FORMAT" "$pid" >/dev/null 2>&1 &
          ;;
        hazelcast)
          sudo -u "$username" nohup "$DUMP_PATH/async-profiler/profiler.sh" $HAZEL_PROFILE_ENV -f "$DUMP_THREAD_PATH/profile.$HOSTNAME.$SERVERNAME.$DATETIME.$pid.$FORMAT" "$pid" >/dev/null 2>&1 &
          ;;
        *)
          sudo -u "$username" nohup "$DUMP_PATH/async-profiler/profiler.sh" $PROFILE_ENV -f "$DUMP_THREAD_PATH/profile.$HOSTNAME.$SERVERNAME.$DATETIME.$pid.$FORMAT" "$pid" >/dev/null 2>&1 &
          ;;
        esac
      fi
      unset SERVERNAME
    done
    sleep $PAUSE

  done
  sleep $PAUSE
  #archive folder
  tar cvzf "$DUMP_THREAD_PATH.tgz" -C "$DUMP_PATH/" "threaddumps_$HOSTNAME.$DATETIMEFOLDER"
  rm -rf "$DUMP_THREAD_PATH"
done
