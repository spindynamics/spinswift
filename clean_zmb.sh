#!/bin/bash

# Find and kill parent processes of all zombie processes
for ppid in $(ps -eo ppid,state | grep 'Z' | awk '{print $1}' | sort -u); do
    echo "Killing parent process: $ppid"
    kill -9 $ppid
done

echo "All zombie processes should now be cleaned up."

