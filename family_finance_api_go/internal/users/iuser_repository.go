package repository

import (
	"github.com/dimasyanu/family-finance-api/internal/users/models"
)

type IUserRepository interface {
	Create(user *models.UserEntity) (user *entities.UserEntity, error)
}
