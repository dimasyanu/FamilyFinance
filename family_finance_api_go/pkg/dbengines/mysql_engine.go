package dbengines

import (
	"log"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func NewMySQLEngine(dbUser string, dbPassword string, dbHost string, dbPort string, dbName string) (*gorm.DB, error) {
	db, err := gorm.Open(mysql.Open(dbUser+":"+dbPassword+"@tcp("+dbHost+":"+dbPort+")/"+dbName), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
		return nil, err
	}
	return db, nil
}
