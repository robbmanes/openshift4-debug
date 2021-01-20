#!/bin/bash

trap signal EXIT
trap signal SIGINT

function signal()
{
        echo "Exited due to signal recieved."
        exit
}

function main()
{
        echo "Found hostname:"
        echo $(/usr/bin/hostname)

        echo "Checking collectl version:"
        /usr/bin/collectl -v

        echo "Current configuration:"
        CONFIG=$(egrep -v "\#|^$" /etc/collectl.conf)
        echo "$CONFIG"

        echo "Ensuring /var/log/collectl exists..."
        if [ ! -d /var/log/collectl ]
        then
                mkdir /var/log/collectl
        fi

        echo "Checking if collectl is already running on this node..."
        PID=$(pgrep -f '/usr/bin/perl -w /usr/bin/collectl')
        if [ ! -z "$PID" ]
        then
                echo "Host process $PID is already running collectl, exiting."
                exit
        fi

        echo "Starting collectl process..."
        /usr/bin/collectl -D /etc/collectl.conf
        PID=$(pgrep -f '/usr/bin/perl -w /usr/bin/collectl')

        echo "Monitoring PID $PID for exit..."
        while true
        do
                PID=$(pgrep -f '/usr/bin/perl -w /usr/bin/collectl')
                if [ $? -ne 0 ]
                then
                        echo "Could no longer find PID $PID, exiting..."
                        exit
                fi

                sleep 10
        done
}

main