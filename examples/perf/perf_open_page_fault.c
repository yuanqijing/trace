#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/ioctl.h>
#include <linux/perf_event.h>
#include <asm/unistd.h>

#include <stdint.h>
#include <string.h>
#include <inttypes.h>
#include <errno.h>

// The perf_event_open syscall number
#define __NR_perf_event_open  298

// Helper function to call the perf_event_open syscall
static long perf_event_open(struct perf_event_attr *hw_event, pid_t pid,
                            int cpu, int group_fd, unsigned long flags)
{
    return syscall(__NR_perf_event_open, hw_event, pid, cpu, group_fd, flags);
}

int main(int argc, char **argv)
{
    // Set up the perf_event_attr struct
    struct perf_event_attr pe;
    memset(&pe, 0, sizeof(struct perf_event_attr));
    pe.type = PERF_TYPE_SOFTWARE;
    pe.size = sizeof(struct perf_event_attr);
    pe.config = PERF_COUNT_SW_PAGE_FAULTS;
    pe.disabled = 1;

    // Open the event
    int fd = perf_event_open(&pe, 0, -1, -1, 0);
    if (fd == -1) {
        fprintf(stderr, "Error opening event: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    // Enable the event
    ioctl(fd, PERF_EVENT_IOC_RESET, 0);
    ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);

    // Do some work that triggers page faults (e.g. malloc)
    int *x = malloc(1000000 * sizeof(int));
    *x = 0;

    sleep(1);

    // Read the event count
    uint64_t count;

    ssize_t ret = read(fd, &count, sizeof(uint64_t));
    if (ret == -1) {
        // Handle the error
        fprintf(stderr, "Error reading event: %s\n", strerror(errno));
    } else if (ret != sizeof(uint64_t)) {
        // Handle the case where not enough data was read
        fprintf(stderr, "Unexpected number of bytes read from event\n");
    }
    printf("page fault count: %" PRIu64 "\n", count);

    // Close the event
    close(fd);

    return 0;
}
