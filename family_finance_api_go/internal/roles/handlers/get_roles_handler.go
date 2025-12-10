package handlers

import (
	"context"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	common "github.com/dimasyanu/family-finance-go/internal/common/models"
	"github.com/dimasyanu/family-finance-go/internal/roles/models"
	"github.com/dimasyanu/family-finance-go/internal/roles/repositories"
)

type GetRolesHandler[TResult []models.Role] struct {
	abstractions.AuthorizedUser

	Filter     *models.RoleListFilter `json:"filter"`
	SortOption *common.SortingOption  `json:"sort_option"`

	repo *repositories.RoleRepository
}

func (h *GetRolesHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}

	h.repo = ctx.Value(constants.RoleRepositoryKey).(*repositories.RoleRepository)
	return nil
}

func (h *GetRolesHandler[TResult]) Handle() (*TResult, error) {
	roleEntities, _ := h.repo.List(h.Filter, h.SortOption)

	roles := models.FromEntities(*roleEntities)
	result := TResult(*roles)
	return &result, nil
}

func NewGetRolesHandler(f *models.RoleListFilter, so *common.SortingOption) contracts.IRequestHandler[[]models.Role] {
	return &GetRolesHandler[[]models.Role]{
		Filter:     f,
		SortOption: so,
	}
}
