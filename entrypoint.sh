#!/bin/sh

# Usage:
# export WAIT_MACVLAN=1
# [export IP_PREFIX_PATTERN="^10\."]
# [export INTERVAL=1]
# [export MAX_RETRY=60]
# /entrypoint.sh

# set -ex

wait_macvlan() {
    prefix=${IP_PREFIX_PATTERN}
    interval=${INTERVAL:-1}
    max_retry=${MAX_RETRY:-60}

    for i in `seq $max_retry`; do
        addresses=`ip a | grep inet | grep "scope global" | awk '{print $2}'`
        if [[ -z "${prefix}" ]]; then
            cmd='grep -v -E ^172|^10.255'
        else
            cmd='grep -E '$prefix
        fi

        matched_addr=''
        for addr in $addresses; do
            echo $addr | $cmd 2>&1 > /dev/null
            if [[ $? -eq 0 ]]; then
                matched_addr=$addr
                break
            fi
        done
        is_matched=$?
        if [[ $is_matched -eq 0 ]]; then
            echo "IP Address matched: ${matched_addr}"
            export MATCHED_IPADDRESS=$matched_addr
            return 0
        else
            echo "IP Address with pattern \`${prefix:-^((!?172.)|(!?10.255.))}\` not found. Now IP Addresses: [$address]. Sleepping ${interval}s for retry. (${i}/${max_retry})"
        fi
        sleep $interval
    done

    echo "Max retry exceeded"
    return 1
}

if [[ -n "$WAIT_MACVLAN" ]]; then
    wait_macvlan
fi
exec $@
