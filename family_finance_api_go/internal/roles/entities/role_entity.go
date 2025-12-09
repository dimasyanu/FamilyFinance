package entities

import (
	"time"
)

type RoleEntity struct {
	ID        int        `gorm:"primaryKey;autoIncrement;column:id;type:smallint" json:"id"`
	Name      string     `gorm:"column:name;type:varchar(100);not null;unique" json:"name"`
	CreatedAt time.Time  `gorm:"column:created_at;autoCreateTime" json:"created_at"`
	CreatedBy string     `gorm:"column:created_by;type:varchar(100);not null" json:"created_by"`
	UpdatedAt time.Time  `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`
	UpdatedBy string     `gorm:"column:updated_by;type:varchar(100);not null" json:"updated_by"`
	DeletedAt *time.Time `gorm:"column:deleted_at;index" json:"deleted_at,omitempty"`
	DeletedBy string     `gorm:"column:deleted_by;type:varchar(100)" json:"deleted_by"`
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
