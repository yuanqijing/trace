// +build linux

package perf

type Event struct {
	perfFd int

	att
}