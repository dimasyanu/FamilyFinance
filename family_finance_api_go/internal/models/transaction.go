package models

import (
	"time"

	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Transaction struct {
	ID uuid.UUID `gorm:"type:uuid;primarykey"`

	TransactionType int       `gorm:"column:transaction_type;type:integer;not null"` // -1 for expense, 1 for income, 0 for transfer
	Description     string    `gorm:"column:description;type:text"`
	Date            time.Time `gorm:"column:date;type:timestamp;not null;index"`
	Amount          float64   `gorm:"column:amount;type:decimal(18,2);not null"`
	CategoryID      uint      `gorm:"column:category_id;index"`
	AccountID       uint      `gorm:"column:account_id;not null;index"`
	TargetAccountID uint      `gorm:"column:target_account_id;type:integer;index"` // for transfer transactions

	CreatedAt time.Time      `gorm:"column:created_at;type:timestamp;not null;default:current_timestamp"`
	CreatedBy uint           `gorm:"column:created_by;type:integer;not null"`
	UpdatedAt time.Time      `gorm:"column:updated_at;type:timestamp;not null;default:current_timestamp"`
	UpdatedBy uint           `gorm:"column:updated_by;type:integer;not null"`
	DeletedAt gorm.DeletedAt `gorm:"index;column:deleted_at;type:timestamp"`
	DeletedBy uint           `gorm:"column:deleted_by;type:integer"`

	Account       *Account  `gorm:"foreignKey:AccountID;references:ID"`
	Category      *Category `gorm:"foreignKey:CategoryID;references:ID"`
	TargetAccount *Account  `gorm:"foreignKey:TargetAccountID;references:ID"`

	gorm.Model
}

func FromCreateTransactionRequest(payload *request.SaveTransactionRequest, userId uint) *Transaction {
	dt, _ := time.Parse("2006-01-02", payload.Date)
	return &Transaction{
		ID:              uuid.New(),
		TransactionType: payload.TransactionType,
		Description:     payload.Description,
		Date:            dt,
		Amount:          payload.Amount,
		CategoryID:      payload.CategoryID,
		AccountID:       payload.AccountID,
		TargetAccountID: payload.TargetAccountID,
		CreatedAt:       time.Now(),
		CreatedBy:       userId,
		UpdatedAt:       time.Now(),
		UpdatedBy:       userId,
	}
}
