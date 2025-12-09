package models

import "gorm.io/gorm"

type SoftDelete struct {
	DeletedBy string         `gorm:"column:deleted_by;type:varchar(100)" json:"deleted_by"`
	DeletedAt gorm.DeletedAt `gorm:"column:deleted_at;index" json:"deleted_at,omitempty"`
}
