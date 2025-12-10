package handlers

import (
	"context"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
	roleEntities "github.com/dimasyanu/family-finance-go/internal/roles/entities"
	roleRepo "github.com/dimasyanu/family-finance-go/internal/roles/repositories"
	roleVobj "github.com/dimasyanu/family-finance-go/internal/roles/valueobjects"
	"github.com/dimasyanu/family-finance-go/internal/users/entities"
	"github.com/dimasyanu/family-finance-go/internal/users/repositories"
	vobj "github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
)

type CreateUserHandler[TResult vobj.UserId] struct {
	abstractions.AuthorizedUser

	Name           string            `json:"name" binding:"required"`
	Username       string            `json:"username" binding:"required"`
	EmailAddress   vobj.EmailAddress `json:"email" binding:"required,email"`
	Roles          []roleVobj.RoleId `json:"roles" binding:"required,min=1,dive,gt=0"`
	Password       string            `json:"password" binding:"required,min=8"`
	PasswordRepeat string            `json:"password_repeat" binding:"required,eqfield=Password"`

	repo           *repositories.UserRepository
	roleRepo       *roleRepo.RoleRepository
	hashingService contracts.IHashingService
}

func (h *CreateUserHandler[TResult]) Init(ctx context.Context) error {
	if err := h.AuthorizedUser.Init(ctx); err != nil {
		return err
	}

	h.repo = ctx.Value(constants.UserRepositoryKey).(*repositories.UserRepository)
	h.roleRepo = ctx.Value(constants.RoleRepositoryKey).(*roleRepo.RoleRepository)
	h.hashingService = ctx.Value(constants.HashingServiceKey).(contracts.IHashingService)
	return nil
}

func (h *CreateUserHandler[TResult]) Handle() (*TResult, error) {
	roleEntities, err := h.findRoleEntitiesByIds(h.Roles)
	if err != nil {
		return nil, err
	}

	newEntity := &entities.UserEntity{
		Name:         h.Name,
		Username:     h.Username,
		EmailAddress: h.EmailAddress,
		Roles:        roleEntities,
		Timestamp:    commonModels.CreateTimestamp(h.User.Username),
		PasswordHash: h.hashingService.Hash(h.Password),
	}

	id, err := h.repo.Create(newEntity)
	if err != nil {
		return nil, err
	}

	result := TResult(id)
	return &result, nil
}

func (h *CreateUserHandler[TResult]) findRoleEntitiesByIds(roleIds []roleVobj.RoleId) (*[]roleEntities.RoleEntity, error) {
	var roles []roleEntities.RoleEntity
	for _, roleId := range roleIds {
		roleEntity, err := h.roleRepo.GetByID(roleId)
		if err != nil {
			return nil, err
		}
		roles = append(roles, *roleEntity)
	}
	return &roles, nil
}
