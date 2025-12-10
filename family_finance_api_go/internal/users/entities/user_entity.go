package entities

import (
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
	roleEntities "github.com/dimasyanu/family-finance-go/internal/roles/entities"
	userVobj "github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
)

type UserEntity struct {
	Id           userVobj.UserId       `gorm:"primaryKey;autoIncrement;column:id;type:int" json:"id"`
	Name         string                `gorm:"column:name;type:varchar(100);not null" json:"name"`
	Username     string                `gorm:"column:username;type:varchar(100);not null;unique" json:"username"`
	EmailAddress userVobj.EmailAddress `gorm:"column:email;type:varchar(100);not null;unique" json:"email"`
	PasswordHash string                `gorm:"column:password_hash;type:varchar(255);not null" json:"-"`

	Roles *[]roleEntities.RoleEntity `gorm:"many2many:user_roles;"`

	commonModels.Timestamp
	commonModels.SoftDelete
}
