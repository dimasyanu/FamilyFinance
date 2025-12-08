package models

import (
	"time"

	"gorm.io/gorm"
)

type Budget struct {
	StartDate time.Time `gorm:"column:start_date;type:date" json:"start_date"`
	EndDate   time.Time `gorm:"column:end_date;type:date" json:"end_date"`
	Amount    float64   `gorm:"column:amount;type:decimal(18,2)" json:"amount"`

	CategoryID uint `gorm:"column:category_id"`

	Category *Category `gorm:"foreignKey:CategoryID;references:ID"`

	gorm.Model
}
