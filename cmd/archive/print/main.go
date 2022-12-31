package main

import "runtime"

func main() {
	// bind to core 0
	runtime.GOMAXPROCS(1)
	runtime.LockOSThread()
	println("Hello, world!")
}
