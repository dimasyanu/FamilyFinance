package models

import (
	common "github.com/dimasyanu/family-finance-go/internal/common/models"
)

type TransactionListFilter struct {
	UserID     uint    `form:"user_id" binding:"omitempty,gt=0"`
	AccountID  uint    `form:"account_id" binding:"omitempty,gt=0"`
	CategoryID uint    `form:"category_id" binding:"omitempty,gt=0"`
	MinAmount  float64 `form:"min_amount" binding:"omitempty,gt=0"`
	MaxAmount  float64 `form:"max_amount" binding:"omitempty,gt=0"`
	DateFrom   string  `form:"date_from" binding:"omitempty,datetime=2006-01-02"`
	DateTo     string  `form:"date_to" binding:"omitempty,datetime=2006-01-02"`

	common.ListFilter
}
