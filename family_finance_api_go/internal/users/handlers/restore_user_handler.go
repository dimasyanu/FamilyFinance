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

type RestoreUserHandler[TResult models.User] struct {
	abstractions.AuthorizedUser

	UserId valueobjects.UserId

	repo repositories.UserRepository
}

func (h *RestoreUserHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}

	h.repo = ctx.Value(constants.UserRepositoryKey).(repositories.UserRepository)
	return nil
}

func (h *RestoreUserHandler[TResult]) Handle() (*TResult, error) {
	// Get the user to ensure they exist before trashing
	userEntity, err := h.repo.GetByID(h.UserId)
	if err != nil {
		return nil, err
	}

	// Soft delete the user by setting DeletedAt and DeletedBy
	userEntity.DeletedAt = nil
	userEntity.DeletedBy = nil

	// Update the user entity in the database
	err = h.repo.Update(userEntity)
	if err != nil {
		return nil, err
	}

	user := models.FromEntity(userEntity)
	result := TResult(*user)
	return &result, nil
}

func NewRestoreUserHandler(userId valueobjects.UserId) contracts.IRequestHandler[models.User] {
	return &RestoreUserHandler[models.User]{
		UserId: userId,
	}
}
