# get all tracers, different tracers have different options
trace-cmd list -t

# get all trace points
trace-cmd list -e

# get trace point with specific name
trace-cmd list -e sched_switch

# get all traceable kernel functions
trace-cmd list -f

# get all traceable kernel functions with specific name
trace-cmd list -f 'alloc_fd'

# trace syscalls trace point event
# -F means filter only on the specified process
# -P do the same thing as -F, but it's indicated by PID
trace-cmd record -e syscalls -F ./path/to/bin

# trace switch event
trace-cmd record -e sched_switch -e sched_wakeup -e sys_enter_write ./path/to/bin

# NOTE: trace-cmd record -p xxx -e xxx will record both function trace and event trace
# trace syscalls trace point event with function call graph
# first defined the tracer type to function_graph
# then trace the syscalls trace point event, trigger tracer when the event syscalls occurs
trace-cmd record -p function_graph --max-graph-depth 1 -e syscalls -F ./path/to/bin

# trace syscalls trace point event with function call graph with specific syscall name
trace-cmd record -p function_graph --max-graph-depth 1 -e syscalls:sys_enter_write -F ./path/to/bin

# trace kernel function with function call graph
trace-cmd record -p function_graph -g __x64_sys_write -F ./path/to/bin

# trace kernel function with function call graph and ignore the verifiers
trace-cmd record -p function_graph -g __x64_sys_write  -n rw_verify_area -F ./path/to/bin

# trace kernel function with function call graph and ignore the verifiers and ignore the interupts
trace-cmd record -p function_graph -g __x64_sys_write  -n rw_verify_area -O nofuncgraph-interrupt -F ./path/to/bin

# report the trace
trace-cmd report

# stop tracing
trace-cmd stop
