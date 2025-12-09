package models

import (
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
)

type Role struct {
	ID   uint   `json:"id"`
	Name string `json:"name"`

	commonModels.Timestamp
	commonModels.SoftDelete
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
