package dbengines

import (
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func NewPostgresEngine(dbHost string, dbUser string, dbPassword string, dbPort string, dbName string, ssl bool) (*gorm.DB, error) {
	sslMode := "disable"
	if ssl {
		sslMode = "enable"
	}
	db, err := gorm.Open(postgres.Open("host="+dbHost+" user="+dbUser+" password="+dbPassword+" dbname="+dbName+" port="+dbPort+" sslmode="+sslMode), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
		return nil, err
	}
	return db, err
}
