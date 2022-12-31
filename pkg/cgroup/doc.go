package cgroup

/*
cgroup package provides functions to inspect the cgroup hierarchy.

file: /proc/self/cgroup
description: cgroup information for the current process, it has the following format:
	14:name=systemd:/docker/containerID
	13:rdma:/
	12:pids:/docker/containerID
	11:hugetlb:/docker/containerID
	10:net_prio:/docker/containerID
	9:perf_event:/docker/containerID
	8:net_cls:/docker/containerID
	7:freezer:/docker/containerID
	6:devices:/docker/containerID
	5:memory:/docker/containerID
	4:blkio:/docker/containerID
	3:cpuacct:/docker/containerID
	2:cpu:/docker/containerID
	1:cpuset:/docker/32bbdaa5b4362d8df7a98d6e6c800d2e7f68907ff235d334808d7c13fd000eec

	Each line represents a single cgroup. The fields are:

	1. hierarchy ID number
	2. set of subsystems bound to the hierarchy
	3. control group in the hierarchy to which the process belongs

file: "/proc/self/attr/current"
description: apparmor profile for the current process, it has the following format:
	/usr/sbin/ntpd (enforce)

file: "/run/systemd/container"
description: container runtime for the current process, it has the following format:
	docker

file: "/proc/self/uid_map"
description: user namespace mappings for the current process, if a docker container is running with the --userns option, it has the following format:
	0 0 4294967295
	1 100000 65536

	Each line represents a single mapping. The fields are:

	1. container ID
	2. host ID
	3. range

file: "/proc/self/status"
description: status information for the current process, it has the following format:
	Name:   cat  			// process name
	Umask:  0022			// umask, used
	State:  R (running)     // process state, R is running, S is sleeping, D is sleeping in an uninterruptible wait, Z is zombie, T is traced or stopped
	Tgid:   9
	Ngid:   0
	Pid:    9
	PPid:   1
	TracerPid:      0
	Uid:    0       0       0       0
	Gid:    0       0       0       0
	FDSize: 64
	Groups: 0 1 2 3 4 6 10 11 20 26 27
	NStgid: 9
	NSpid:  9
	NSpgid: 9
	NSsid:  1
	VmPeak:     1648 kB
	VmSize:     1648 kB
	VmLck:         0 kB
	VmPin:         0 kB
	VmHWM:         4 kB
	VmRSS:         4 kB
	RssAnon:               4 kB
	RssFile:               0 kB
	RssShmem:              0 kB
	VmData:       88 kB
	VmStk:       132 kB
	VmExe:       612 kB
	VmLib:       296 kB
	VmPTE:        40 kB
	VmSwap:        0 kB
	HugetlbPages:          0 kB
	CoreDumping:    0
	THP_enabled:    1
	Threads:        1
	SigQ:   1/7399
	SigPnd: 0000000000000000
	ShdPnd: 0000000000000000
	SigBlk: 0000000000000000
	SigIgn: 0000000000000000
	SigCgt: 0000000000000000
	CapInh: 00000000a80425fb
	CapPrm: 00000000a80425fb
	CapEff: 00000000a80425fb
	CapBnd: 00000000a80425fb
	CapAmb: 0000000000000000
	NoNewPrivs:     0
	Seccomp:        2            // seccomp mode, 0 is disabled, 1 is strict, 2 is filter, see https://www.kernel.org/doc/Documentation/prctl/seccomp_filter.txt
	Seccomp_filters:        1    // number of seccomp filters
	Speculation_Store_Bypass:       vulnerable
	Cpus_allowed:   3f
	Cpus_allowed_list:      0-5
	Mems_allowed:   1
	Mems_allowed_list:      0
	voluntary_ctxt_switches:        0
	nonvoluntary_ctxt_switches:     0

file: "/proc/self/cmdline"
description: command line arguments for the current process, it has the following format:
	/usr/bin/cat /proc/self/status

file: "/proc/self/environ"
description: environment variables for the current process, it has the following format:
	TERM=xterm-256color
	USER=root
	PATH

file "/proc/self/cwd"
description: current working directory for the current process, it has the following format:
	/path/to/workspace


*/
