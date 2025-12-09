package queries

import (
	common "github.com/dimasyanu/family-finance-go/internal/common/models"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
)

type GetUsersQuery[TResult common.Paginated[models.User]] struct {
	Filter        *models.UserFilter    `json:"filter"`
	SortingOption *common.SortingOption `json:"sorting_option"`
}

func NewGetUsersQuery(filter *models.UserFilter, sortingOption *common.SortingOption) *GetUsersQuery[common.Paginated[models.User]] {
	return &GetUsersQuery[common.Paginated[models.User]]{
		Filter:        filter,
		SortingOption: sortingOption,
	}
}
