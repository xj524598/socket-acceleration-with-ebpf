#!/bin/bash
set -x

# Detach and unload the bpf_redir program
 bpftool prog detach pinned /sys/fs/bpf/bpf_redir msg_verdict pinned /sys/fs/bpf/sock_ops_map
 rm /sys/fs/bpf/bpf_redir

# Detach and unload the bpf_sockops_v4 program
 bpftool cgroup detach /sys/fs/cgroup/unified/ sock_ops pinned /sys/fs/bpf/bpf_sockops
 rm /sys/fs/bpf/bpf_sockops

# Delete the map
 rm /sys/fs/bpf/sock_ops_map
