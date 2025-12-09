package models

import (
	common "github.com/dimasyanu/family-finance-go/internal/common/models"
)

type Account struct {
	Id          int64  `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`

	common.Timestamp
	common.SoftDelete
}
