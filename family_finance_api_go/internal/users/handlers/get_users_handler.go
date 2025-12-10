package handlers

import (
	"context"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	common "github.com/dimasyanu/family-finance-go/internal/common/models"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
	"github.com/dimasyanu/family-finance-go/internal/users/repositories"
)

type GetUsersHandler[TResult common.Paginated[models.User]] struct {
	abstractions.AuthorizedUser

	Filter        *models.UserFilter    `json:"filter"`
	SortingOption *common.SortingOption `json:"sorting_option"`

	repo *repositories.UserRepository
}

func (h *GetUsersHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}

	h.repo = ctx.Value(constants.UserRepositoryKey).(*repositories.UserRepository)
	return nil
}

func (h *GetUsersHandler[TResult]) Handle() (*TResult, error) {
	userEntities, total := h.repo.List(h.Filter, h.SortingOption)
	users, err := models.FromEntities(userEntities)
	if err != nil {
		return nil, err
	}
	return &TResult{
		Items: users,
		Total: total,
	}, nil
}

func NewGetUsersHandler(filter *models.UserFilter, sortingOption *common.SortingOption) contracts.IRequestHandler[common.Paginated[models.User]] {
	return &GetUsersHandler[common.Paginated[models.User]]{
		Filter:        filter,
		SortingOption: sortingOption,
	}
}
