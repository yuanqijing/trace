package main

import (
	"fmt"
	"github.com/iovisor/gobpf/bcc"
)

const source string = `
int kprobe__sys_clone(struct pt_regs *ctx) {
  bpf_trace_printk("Hello, ebpf!\\n");
  return 0;
}
`

func main() {
	m := bcc.NewModule(source, []string{})
	defer m.Close()

	kprobe, err := m.LoadKprobe("kprobe__sys_clone")
	if err != nil {
		fmt.Println(err)
		return
	}

	err = m.AttachKprobe("sys_clone", kprobe, -1)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Output the ebpf trace messages
	ch := make(chan []byte)
	go func() {
		for msg := range ch {
			fmt.Printf("%s", msg)
		}
	}()

	select {}
}
