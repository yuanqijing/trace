package main

import (
	"github.com/go-redis/redis"
)

func main() {
	// get key a from redis
	rdb := redis.NewClient(&redis.Options{
		Addr:     "10.10.101.172:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})
	defer rdb.Close()
	// get key a
	val, err := rdb.Get("a").Result()
	if err != nil {
		panic(err)
	}
	println(val)
}
