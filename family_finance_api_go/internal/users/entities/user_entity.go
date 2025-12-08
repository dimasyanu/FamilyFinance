package entities

import valueobjects "github.com/dimasyanu/faimly-finance-api/internal/users/valueobjects"

type UserEntity struct {
	Id       uuid
	Name     string
	Username string
	Email    valueobjects.Email
}
