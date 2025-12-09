package entities

import (
	"time"

	categoryEntities "github.com/dimasyanu/family-finance-go/internal/categories/entities"
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
)

type BudgetEntity struct {
	Id        uint      `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	StartDate time.Time `gorm:"column:start_date;type:date" json:"start_date"`
	EndDate   time.Time `gorm:"column:end_date;type:date" json:"end_date"`
	Amount    float64   `gorm:"column:amount;type:decimal(18,2)" json:"amount"`
	CretedAt  time.Time `gorm:"column:created_at;autoCreateTime" json:"created_at"`

	CategoryID uint `gorm:"column:category_id"`

	Category *categoryEntities.CategoryEntity `gorm:"foreignKey:CategoryID;references:ID"`

	commonModels.Timestamp
}
