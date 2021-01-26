#!/bin/bash

trap signal EXIT
trap signal SIGINT


function signal()
{
    echo "Exited due to signal recieved."
    exit 1
}

function main()
{
    echo "Executing tcpdump utility on ${HOSTNAME}..."

    # Parse script options
    if [ -z ${SNAPLEN} ]; then
        SNAPLEN=0
    fi

    if [ -z ${FILESIZE_MB} ]; then
        FILESIZE_MB=1000
    fi

    if [ -z ${WRITEDIR} ]; then
        WRITEDIR="/var/log/tcpdump"
    fi

    if [ ! -d $WRITEDIR ]; then
        mkdir -p $WRITEDIR
    fi

    # These lines are taken from
    # https://access.redhat.com/solutions/3393831
    #
    # /proc/net/dev has 2 header lines, separated by ':", leading spaces before iface name.
    # first tail handles 2 header lines
    # second awk gets iface name
    # third awk removes leading spaces using default space separator
    # then sort.
    IFACES=$(cat /proc/net/dev | tail -n +3 | awk -F: '{print $1}' | awk '{$1=$1};1' | sort)
    DATE=$(date +%Y%m%d%H%M%S)

    echo "Found the following interfaces:"
    echo $IFACES

    # Actually run the tcpdump now on every interface
    for i in $IFACES; do
        CMD="tcpdump -s $SNAPLEN -i $i -C $FILESIZE_MB -Z root -w /$WRITEDIR/tcpdump-$HOSTNAME-$i-$DATE.pcap"
        echo "Executing ${CMD}"
        $($CMD) &
    done

    # Monitor for the last tcpdump to exit
    echo "Monitoring tcpdump processes for exit..."
    while true
    do
            PIDS=$(pgrep tcpdump)
            if [ $? -ne 0 ]
            then
                    echo "Could no longer find any tcpdump processes running on the node, exiting..."
                    exit
            fi

            sleep 10
    done
}

main