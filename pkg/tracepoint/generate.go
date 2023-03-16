package tracepoint

import (
	"bytes"
	"encoding/binary"
	"errors"
	"fmt"
	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/ringbuf"
	"github.com/cilium/ebpf/rlimit"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	_ "net/http/pprof"
)

//go:generate go run github.com/cilium/ebpf/cmd/bpf2go -cc $BPF_CLANG -cflags $BPF_CFLAGS -type event bpf ./syscall.c -- -I../../include

func Run() {

	go func() {
		fmt.Printf("yes")
		log.Println(http.ListenAndServe(":6060", nil))
	}()

	// Subscribe to signals for terminating the program.
	stopper := make(chan os.Signal, 1)
	signal.Notify(stopper, os.Interrupt, syscall.SIGTERM)

	// Allow the current process to lock memory for eBPF resources
	if err := rlimit.RemoveMemlock(); err != nil {
		panic(err)
	}

	objs := bpfObjects{}
	if err := loadBpfObjects(&objs, nil); err != nil {
		panic(err)
	}
	defer objs.Close()

	// Link to tp
	readLink, err := link.Tracepoint("syscalls", "sys_enter_write", objs.BpfProg1, nil)
	if err != nil {
		panic(err)
	}
	defer readLink.Close()

	// get my pid
	pid := os.Getpid()

	// add to filter map
	if err := objs.Pids.Put(uint32(pid), uint32(1)); err != nil {
		panic(err)
	}

	// Open a ringbuf reader from userspace RINGBUF map described in the
	// eBPF C program.
	rd, err := ringbuf.NewReader(objs.Events)
	if err != nil {
		panic(err)
	}
	defer rd.Close()

	// Read events from the ring buffer
	var event bpfEvent
	go func() {
		for {
			record, err := rd.Read()
			if err != nil {
				if errors.Is(err, ringbuf.ErrClosed) {
					break
				}
				panic(err)
			}
			if err := binary.Read(bytes.NewReader(record.RawSample), binary.LittleEndian, &event); err != nil {
				panic(err)
			}
			//// convert Comm to string
			//comm := string(event.Comm[:bytes.IndexByte(event.Comm[:], 0)])
			//// convert data to string
			//data := string(event.Buf[:bytes.IndexByte(event.Buf[:], 0)])
			//fmt.Printf("pid: %d, comm: %s, data: %s\n", event.Pid, comm, data)
		}
	}()

	<-stopper
	if err := rd.Close(); err != nil {
		panic(err)
	}
	fmt.Printf("exit")
}
