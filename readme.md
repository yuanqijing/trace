
tools:
  - name: strace
    description: strace is a diagnostic, debugging and instructional userspace utility for Linux. It is used to monitor and tamper with interactions between processes and the Linux kernel, which include system calls, signal deliveries, and changes of process state.
    url: https://man7.org/linux/man-pages/man1/strace.1.html
  - name: ltrace
    description: ltrace is a diagnostic, debugging and instructional userspace utility for Linux. It is used to monitor and tamper with interactions between processes and the shared libraries they call.
    url: https://man7.org/linux
  - name: ftrace
    description: ftrace is a official kernel tracing tool. It is used to monitor and tamper with interactions between processes and the Linux kernel, which include system calls, signal deliveries, and changes of process state.
    url: https://www.kernel.org/doc/html/latest/trace/ftrace.html
    install: sudo apt-get update && sudo apt-get install -y trace-cmd
