#!/usr/bin/bash
# Outputs: cpu_pct|mem_pct|temp_celsius every ~2s
while true; do
    IFS=' ' read -r _ u ni sy id io irq si st _ < /proc/stat
    t1=$((u+ni+sy+id+io+irq+si+st)); i1=$id
    sleep 0.4
    IFS=' ' read -r _ u ni sy id io irq si st _ < /proc/stat
    t2=$((u+ni+sy+id+io+irq+si+st)); i2=$id
    cpu=$(awk -v i1="$i1" -v i2="$i2" -v t1="$t1" -v t2="$t2" \
        'BEGIN{dt=t2-t1; if(dt>0) printf "%.0f",(1-(i2-i1)/dt)*100; else print 0}')
    mem=$(free | awk '/^Mem/{printf "%.0f",$3/$2*100}')
    temp=$(awk '{printf "%.0f",$1/1000}' /sys/class/hwmon/hwmon7/temp1_input 2>/dev/null || echo "?")
    echo "${cpu}|${mem}|${temp}"
    sleep 1.6
done
