#!/usr/bin/env bash

load_averages=$(uptime | awk '{print "load_1_min="$(NF-2)",load_average_5_min="$(NF-1)",load_average_15_min="$NF}')


ts_secs=$(date +%s)
ts_nano="$(($ts_secs * 1000000000))"

echo host_metrics,host=$(hostname) $load_averages $ts_nano


