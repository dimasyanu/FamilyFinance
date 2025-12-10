package handlers

import (
	"context"
	"time"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	"github.com/dimasyanu/family-finance-go/internal/users/repositories"
	"github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
	"gorm.io/gorm"
)

type TrashUserHandler[TResult bool] struct {
	abstractions.AuthorizedUser

	UserId valueobjects.UserId

	repo repositories.UserRepository
}

func (h *TrashUserHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}

	h.repo = ctx.Value(constants.UserRepositoryKey).(repositories.UserRepository)
	return nil
}

func (h *TrashUserHandler[TResult]) Handle() (*TResult, error) {
	// Get the user to ensure they exist before trashing
	userEntity, err := h.repo.GetByID(h.UserId)
	if err != nil {
		return nil, err
	}

	// Soft delete the user by setting DeletedAt and DeletedBy
	userEntity.DeletedAt = &gorm.DeletedAt{
		Time:  time.Now(),
		Valid: true,
	}
	userEntity.DeletedBy = &h.User.Username

	// Update the user entity in the database
	err = h.repo.Update(userEntity)
	if err != nil {
		return nil, err
	}

	result := TResult(true)
	return &result, nil
}

func NewTrashUserHandler(userId valueobjects.UserId) contracts.IRequestHandler[bool] {
	return &TrashUserHandler[bool]{
		UserId: userId,
	}
}
