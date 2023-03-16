#include "common.h"
#include "bpf_helpers.h"


char __license[] SEC("license") = "Dual MIT/GPL";


struct event {
	u32 pid;
	u8 comm[80];
	u8 buf[20];
};

struct {
	__uint(type, BPF_MAP_TYPE_RINGBUF);
	__uint(max_entries, 1 << 24);
} events SEC(".maps");

// filter pids
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 1 << 24);
    __type(key, u32);
    __type(value, u32);
} pids SEC(".maps");


const struct event *unused __attribute__((unused));


struct trace_event_raw_sys_enter_rw__stub {
    __u64 unused;
    long int id;
    __u64 fd;
    char* buf;
    __u64 size;
};


SEC("tracepoint/syscalls/sys_enter_write")
int bpf_prog1(struct trace_event_raw_sys_enter_rw__stub *ctx)
{
    u64 id   = bpf_get_current_pid_tgid();
    u32 pid  = id >> 32;

    // filter pids if exists in the map
    // do not process if not in the map

    u32 *val = bpf_map_lookup_elem(&pids, &pid);
    if (val != NULL) {
        return 0;
    }

    struct event *e;

    e = bpf_ringbuf_reserve(&events, sizeof(*e), 0);
    if (!e) {
        return 0;
    }

    e->pid = pid;
    bpf_get_current_comm(&e->comm, sizeof(e->comm));

    // copy the buffer data from the syscall args
    bpf_probe_read_str(e->buf, sizeof(e->buf), ctx->buf);

    bpf_ringbuf_submit(e, 0);

    return 0;
}
