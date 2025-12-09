package entities

import (
	"time"

	accountEntities "github.com/dimasyanu/family-finance-go/internal/accounts/entities"
	categoryEntities "github.com/dimasyanu/family-finance-go/internal/categories/entities"
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"

	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/google/uuid"
)

type TransactionEntity struct {
	ID uuid.UUID `gorm:"type:uuid;primarykey"`

	TransactionType int       `gorm:"column:transaction_type;type:integer;not null"` // -1 for expense, 1 for income, 0 for transfer
	Description     string    `gorm:"column:description;type:text"`
	Date            time.Time `gorm:"column:date;type:timestamp;not null;index"`
	Amount          float64   `gorm:"column:amount;type:decimal(18,2);not null"`
	CategoryID      uint      `gorm:"column:category_id;index"`
	AccountID       uint      `gorm:"column:account_id;not null;index"`
	TargetAccountID uint      `gorm:"column:target_account_id;type:integer;index"` // for transfer transactions

	Account       *accountEntities.AccountEntity   `gorm:"foreignKey:AccountID;references:ID"`
	Category      *categoryEntities.CategoryEntity `gorm:"foreignKey:CategoryID;references:ID"`
	TargetAccount *accountEntities.AccountEntity   `gorm:"foreignKey:TargetAccountID;references:ID"`

	commonModels.Timestamp
}

func FromCreateTransactionRequest(payload *request.SaveTransactionRequest, username string) *TransactionEntity {
	dt, _ := time.Parse("2006-01-02", payload.Date)
	return &TransactionEntity{
		ID:              uuid.New(),
		TransactionType: payload.TransactionType,
		Description:     payload.Description,
		Date:            dt,
		Amount:          payload.Amount,
		CategoryID:      payload.CategoryID,
		AccountID:       payload.AccountID,
		TargetAccountID: payload.TargetAccountID,
		Timestamp: commonModels.Timestamp{
			CreatedAt: time.Now(),
			CreatedBy: username,
			UpdatedAt: time.Now(),
			UpdatedBy: username,
		},
	}
}
