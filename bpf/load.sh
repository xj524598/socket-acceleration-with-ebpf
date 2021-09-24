#!/bin/bash

# enable debug output for each executed command, to disable: set +x
set -x

# exit if any command fails
set -e

# Mount the bpf filesystem
 mount -t bpf bpf /sys/fs/bpf/

# Compile the bpf_sockops program
clang -O2 -g -target bpf -c bpf_sockops.c -o bpf_sockops.o

# Load and attach the bpf_sockops program
 bpftool prog load bpf_sockops.o /sys/fs/bpf/bpf_sockops
 bpftool cgroup attach /sys/fs/cgroup/unified/ sock_ops pinned /sys/fs/bpf/bpf_sockops

# Extract the id of the sockhash map used by the bpf_sockops program
# This map is then pinned to the bpf virtual file system
MAP_ID=$( bpftool prog show pinned /sys/fs/bpf/bpf_sockops | grep -o -E 'map_ids [0-9]+' | cut -d ' ' -f2-)
 bpftool map pin id $MAP_ID /sys/fs/bpf/sock_ops_map

# Load and attach the bpf_redir program to the sock_ops_map
clang -O2 -g -Wall -target bpf -c bpf_redir.c -o bpf_redir.o

 bpftool prog load bpf_redir.o /sys/fs/bpf/bpf_redir map name sock_ops_map pinned /sys/fs/bpf/sock_ops_map
 bpftool prog attach pinned /sys/fs/bpf/bpf_redir msg_verdict pinned /sys/fs/bpf/sock_ops_map
