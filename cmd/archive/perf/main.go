package main

import "syscall"

func main() {
	// Define the perf event to collect the call stack of a pid.
	// This example uses the PERF_COUNT_SW_DUMMY type, which is a
	// dummy hardware-independent event that can be used for testing.
	// In practice, you would probably want to use a different event
	// type that is more specific to your needs.
	eventAttr := syscall.PerfEventAttr{}
}
