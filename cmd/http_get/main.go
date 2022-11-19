package main

import (
	"net/http"
)

func main() {
	// http get www.baidu.com and print the response
	response, err := http.Get("http://www.baidu.com")
	if err != nil {
		panic(err)
	}
	defer response.Body.Close()
	println(response.Status)
}
