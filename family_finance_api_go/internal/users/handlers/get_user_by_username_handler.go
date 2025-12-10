package handlers

import (
	"context"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
	"github.com/dimasyanu/family-finance-go/internal/users/repositories"
)

type GetUserByUsernameHandler[TResult models.User] struct {
	abstractions.AuthorizedUser

	Username string `json:"username"`

	repo *repositories.UserRepository
}

func (h *GetUserByUsernameHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}

	h.repo = ctx.Value(constants.UserRepositoryKey).(*repositories.UserRepository)
	return nil
}

func (h *GetUserByUsernameHandler[TResult]) Handle() (*TResult, error) {
	userEntity, err := h.repo.GetByUsername(h.Username)
	if err != nil {
		return nil, err
	}
	user := *models.FromEntity(userEntity)

	result := TResult(user)
	return &result, nil
}

func NewGetUserByUsernameHandler(username string) contracts.IRequestHandler[models.User] {
	return &GetUserByUsernameHandler[models.User]{
		Username: username,
	}
}
