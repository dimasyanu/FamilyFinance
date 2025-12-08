package main

import (
	"log"
	"net/http"

	"github.com/dimasyanu/family-finance-go/internal/handler"
)

func main() {
	handler, _ := handler.NewHandler()

	err := http.ListenAndServe(":8000", handler)
	if err != nil {
		log.Fatal(err)
	}
}
