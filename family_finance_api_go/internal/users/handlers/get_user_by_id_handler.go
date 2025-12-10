package handlers

import (
	"context"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
	"github.com/dimasyanu/family-finance-go/internal/users/repositories"
	"github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
)

type GetUserByIdHandler[TResult models.User] struct {
	abstractions.AuthorizedUser

	UserId valueobjects.UserId `json:"user_id"`

	repo *repositories.UserRepository
}

func (h *GetUserByIdHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}

	h.repo = ctx.Value(constants.UserRepositoryKey).(*repositories.UserRepository)
	return nil
}

func (h *GetUserByIdHandler[TResult]) Handle() (*TResult, error) {
	userEntity, err := h.repo.GetByID(h.UserId)
	if err != nil {
		return nil, err
	}
	user := *models.FromEntity(userEntity)

	result := TResult(user)
	return &result, nil
}

func NewGetUserByIdHandler(userId valueobjects.UserId) contracts.IRequestHandler[models.User] {
	return &GetUserByIdHandler[models.User]{
		UserId: userId,
	}
}
