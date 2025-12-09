package models

import "time"

type Timestamp struct {
	CreatedAt time.Time  `gorm:"column:created_at;autoCreateTime" json:"created_at"`
	CreatedBy string     `gorm:"column:created_by;type:varchar(100);not null" json:"created_by"`
	UpdatedBy string     `gorm:"column:updated_by;type:varchar(100);not null" json:"updated_by"`
	UpdatedAt time.Time  `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`
	DeletedBy string     `gorm:"column:deleted_by;type:varchar(100)" json:"deleted_by"`
	DeletedAt *time.Time `gorm:"column:deleted_at;index" json:"deleted_at,omitempty"`
}
