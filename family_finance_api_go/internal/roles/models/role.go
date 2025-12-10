package models

import (
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
	"github.com/dimasyanu/family-finance-go/internal/roles/entities"
)

type Role struct {
	ID   uint   `json:"id"`
	Name string `json:"name"`

	commonModels.Timestamp
	commonModels.SoftDelete
}

func FromEntities(entities []entities.RoleEntity) *[]Role {
	results := make([]Role, len(entities))
	for i, entity := range entities {
		results[i] = Role{
			ID:        uint(entity.Id),
			Name:      entity.Name,
			Timestamp: entity.Timestamp,
			SoftDelete: commonModels.SoftDelete{
				DeletedAt: entity.DeletedAt,
				DeletedBy: entity.DeletedBy,
			},
		}
	}

	return &results
}

const (
	RoleSuperAdmin = "super_admin"
	RoleAdmin      = "admin"
	RoleUser       = "user"
)

var DefaultRoles []string = []string{
	RoleSuperAdmin,
	RoleAdmin,
	RoleUser,
}
