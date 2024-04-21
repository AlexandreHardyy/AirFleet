package utils

import (
	"fmt"
	"math/rand"
	"time"
)

const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func GenerateRandomString() string {
	b := make([]byte, 12)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b) + "_" + fmt.Sprintf("%d", time.Now().Unix())
}

func ArrayContain(value string, array []string) bool {
	for _, item := range array {
		if item == value {
			return true
		}
	}
	return false

}
