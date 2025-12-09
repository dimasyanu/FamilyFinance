package entities

import (
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
	vobj "github.com/dimasyanu/family-finance-go/internal/roles/valueobjects"
)

type RoleEntity struct {
	Id   vobj.RoleId `gorm:"primaryKey;autoIncrement;column:id;type:smallint" json:"id"`
	Name string      `gorm:"column:name;type:varchar(100);not null;unique" json:"name"`

	commonModels.Timestamp
	commonModels.SoftDelete
}
