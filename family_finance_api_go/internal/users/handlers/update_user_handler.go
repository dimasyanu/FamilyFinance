package handlers

import (
	"context"
	"time"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	"github.com/dimasyanu/family-finance-go/internal/users/entities"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
	"github.com/dimasyanu/family-finance-go/internal/users/repositories"
	"github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
)

type UpdateUserHandler[TResult models.User] struct {
	abstractions.AuthorizedUser

	UserId valueobjects.UserId
	Name   string `json:"name" binding:"required"`

	repo *repositories.UserRepository
}

func (h *UpdateUserHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}

	h.repo = ctx.Value(constants.UserRepositoryKey).(*repositories.UserRepository)
	return nil
}

func (h *UpdateUserHandler[TResult]) Handle() (*TResult, error) {
	// Find existing user
	user, err := h.findUserById(h.UserId)
	if err != nil {
		return nil, err
	}

	// Update fields
	user.Name = h.Name
	user.UpdatedAt = time.Now()
	user.UpdatedBy = h.User.Username

	// Save updated user
	err = h.repo.Update(user)
	if err != nil {
		return nil, err
	}

	updatedUser := models.FromEntity(user)

	result := TResult(*updatedUser)
	return &result, nil
}

func (h *UpdateUserHandler[TResult]) findUserById(userId valueobjects.UserId) (*entities.UserEntity, error) {
	userEntity, err := h.repo.GetByID(userId)
	if err != nil {
		return nil, err
	}
	return userEntity, nil
}

func NewUpdateUserHandler(userId valueobjects.UserId) contracts.IRequestHandler[models.User] {
	return &UpdateUserHandler[models.User]{
		UserId: userId,
	}
}
