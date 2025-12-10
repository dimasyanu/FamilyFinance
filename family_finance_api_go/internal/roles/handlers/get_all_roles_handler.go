package handlers

import (
	"context"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	"github.com/dimasyanu/family-finance-go/internal/roles/models"
	"github.com/dimasyanu/family-finance-go/internal/roles/repositories"
)

type GetAllRolesHandler[TResult []models.Role] struct {
	abstractions.AuthorizedUser

	repo repositories.RoleRepository
}

func (h *GetAllRolesHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}
	return nil
}

func (h *GetAllRolesHandler[TResult]) Handle() (*TResult, error) {
	roleEntities, _ := h.repo.ListAll()

	roles := models.FromEntities(*roleEntities)
	result := TResult(*roles)
	return &result, nil
}

func NewGetAllRolesHandler() contracts.IRequestHandler[[]models.Role] {
	return &GetAllRolesHandler[[]models.Role]{}
}
