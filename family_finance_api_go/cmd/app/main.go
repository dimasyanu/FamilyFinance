package main

import (
	"log"
	"net/http"

	"github.com/dimasyanu/family-finance-go/internal/common"
)

func main() {
	handler, _ := common.InitializeServices()

	err := http.ListenAndServe(":8000", handler)
	if err != nil {
		log.Fatal(err)
	}
}
