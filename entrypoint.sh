#!/bin/bash

# Usage:
# export WAIT_MACVLAN=1
# [export IP_PREFIX_PATTERN="^10\."]
# [export INTERVAL=1]
# [export MAX_RETRY=60]
# /entrypoint.sh

wait_macvlan() {
    prefix=${IP_PREFIX_PATTERN}
    interval=${INTERVAL:-1}
    max_retry=${MAX_RETRY:-60}

    for i in `seq $max_retry`; do
        address=`ip route get 8.8.8.8 | head -1 | awk '{print $7}'`
        if [[ -z "${prefix}" ]]; then
            echo $address | grep -v -E "^172\." 2>&1 > /dev/null
        else
            echo $address | grep -E "$prefix" 2>&1 > /dev/null
        fi
        matched=$?
        if [[ $matched -eq 0 ]]; then
            echo "IP Address matched: ${address}"
            return 0
        else
            echo "IP Address with pattern \`${prefix:-^(!?172)}\` not found. Default gateway src is $address. Sleepping ${interval}s for retry. (${i}/${max_retry})"
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
