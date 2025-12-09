package models

import (
	"github.com/dimasyanu/family-finance-go/internal/common/models"
)

type UserFilter struct {
	Name string `form:"name"`

	models.ListFilter
}
