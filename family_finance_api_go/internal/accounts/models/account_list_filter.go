package models

import (
	common "github.com/dimasyanu/family-finance-go/internal/common/models"
)

type AccountListFilter struct {
	Search string `form:"search"`

	common.ListFilter
}
