package models

import (
	"time"

	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"gorm.io/gorm"
)

type Account struct {
	Name        string  `gorm:"column:name;type:varchar(100);not null"`
	Description string  `gorm:"column:description;type:text"`
	Color       string  `gorm:"column:color;type:varchar(20)"`
	Balance     float64 `gorm:"column:balance;type:decimal(18,2);not null;default:0"`
	UserID      uint    `gorm:"column:user_id;type:int;not null;index"`

	User *User `gorm:"foreignKey:UserID;references:ID"`

	gorm.Model
}

func FromCreateAccountRequest(payload *request.SaveAccountRequest) *Account {
	return &Account{
		UserID:      payload.UserID,
		Name:        payload.Name,
		Description: payload.Description,
		Color:       payload.Color,
		Balance:     payload.Balance,

		Model: gorm.Model{CreatedAt: time.Now(), UpdatedAt: time.Now()},
	}
}
