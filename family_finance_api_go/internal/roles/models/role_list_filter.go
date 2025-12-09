package models

import (
	common "github.com/dimasyanu/family-finance-go/internal/common/models"
)

type RoleListFilter struct {
	Name string `form:"name"`

	common.ListFilter
}
