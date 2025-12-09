package models

import (
	"time"

	roleModels "github.com/dimasyanu/family-finance-go/internal/roles/models"
	"github.com/dimasyanu/family-finance-go/internal/users/entities"
	"github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
)

type User struct {
	Id           valueobjects.UserId       `json:"id"`
	Name         string                    `json:"name"`
	Username     string                    `json:"username"`
	EmailAddress valueobjects.EmailAddress `json:"email_address"`
	CreatedAt    time.Time                 `json:"created_at"`
	CreatedBy    string                    `json:"created_by"`
	UpdatedAt    time.Time                 `json:"updated_at"`
	UpdatedBy    string                    `json:"updated_by"`
	IsDeleted    bool                      `json:"is_deleted"`
	Roles        *[]roleModels.Role        `json:"roles,omitempty"`
}

func FromEntity(entity *entities.UserEntity) *User {
	return &User{
		Id:           entity.Id,
		Name:         entity.Name,
		Username:     entity.Username,
		EmailAddress: entity.EmailAddress,
		CreatedAt:    entity.CreatedAt,
		CreatedBy:    entity.CreatedBy,
		UpdatedAt:    entity.UpdatedAt,
		UpdatedBy:    entity.UpdatedBy,
		IsDeleted:    !entity.DeletedAt.Valid,
	}
}

func FromEntities(entities *[]entities.UserEntity) (*[]User, error) {
	users := make([]User, len(*entities))
	for i, entity := range *entities {
		user := FromEntity(&entity)
		users[i] = *user
	}
	return &users, nil
}
