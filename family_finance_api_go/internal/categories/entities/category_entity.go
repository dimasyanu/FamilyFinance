package entities

import (
	"time"

	"github.com/dimasyanu/family-finance-go/internal/models/request"
	userEntities "github.com/dimasyanu/family-finance-go/internal/users/entities"
	"gorm.io/gorm"
)

type CategoryEntity struct {
	Name        string `gorm:"column:name;type:varchar(100);not null;unique" json:"name"`
	Description string `gorm:"column:description;type:text" json:"description"`
	Icon        int    `gorm:"column:icon;type:int" json:"icon"`
	Color       string `gorm:"column:color;type:varchar(10)" json:"color"`
	UserID      uint   `gorm:"column:user_id;not null" json:"user_id"`

	User *userEntities.UserEntity `gorm:"references:ID"`

	gorm.Model
}

func FromCreateCategoryRequest(payload *request.SaveCategoryRequest) *CategoryEntity {
	return &CategoryEntity{
		UserID:      payload.UserId,
		Name:        payload.Name,
		Description: payload.Description,
		Icon:        payload.Icon,
		Color:       payload.Color,

		Model: gorm.Model{CreatedAt: time.Now(), UpdatedAt: time.Now()},
	}
}
