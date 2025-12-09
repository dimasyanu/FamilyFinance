package models

import (
	common "github.com/dimasyanu/family-finance-go/internal/common/models"
)

type BudgetFilter struct {
	DateFrom string `form:"date_from" binding:"omitempty,datetime=2006-01-02"`
	DateTo   string `form:"date_to" binding:"omitempty,datetime=2006-01-02"`
	Category uint   `form:"category" binding:"omitempty,gt=0"`

	common.ListFilter
}
