package models

import "gorm.io/gorm"

type Role struct {
	gorm.Model

	Name string `gorm:"column:name;type:varchar(100);not null;unique" json:"name"`

	Users []*User `gorm:"many2many:user_roles;"`
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
