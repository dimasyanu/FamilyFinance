package dbengines

import (
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func NewInMemoryEngine() (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
		return nil, err
	}
	return db, nil
}
