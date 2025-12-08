package config

import (
	"os"

	"github.com/joho/godotenv"
)

const (
	InMemoryDB = "inmemory"
	MySQL      = "mysql"
	PostgreSQL = "postgresql"
	SQLite     = "sqlite"
)

type Config struct {
	DBEngine   string
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	JWTSecret  string
}

func LoadConfig(files ...string) *Config {
	godotenv.Load(files...)

	return &Config{
		DBEngine:   os.Getenv("DB_ENGINE"),
		DBHost:     os.Getenv("DB_HOST"),
		DBPort:     os.Getenv("DB_PORT"),
		DBUser:     os.Getenv("DB_USER"),
		DBPassword: os.Getenv("DB_PASSWORD"),
		DBName:     os.Getenv("DB_NAME"),

		JWTSecret: os.Getenv("JWT_SECRET"),
	}
}
