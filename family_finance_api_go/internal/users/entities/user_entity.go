package entities

import (
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserEntity struct {
	gorm.Model

	Name         string `gorm:"column:name;type:varchar(100);not null" json:"name"`
	Username     string `gorm:"column:username;type:varchar(100);not null;unique" json:"username"`
	Email        string `gorm:"column:email;type:varchar(100);not null;unique" json:"email"`
	PasswordHash string `gorm:"column:password_hash;type:varchar(255);not null" json:"-"`
	CreatedBy    string `gorm:column:created_by;type:varchar(100);not null" json:"created_by"`
	UpdatedBy    string `gorm:column:updated_by;type:varchar(100);not null" json:"updated_by"`
	DeletedBy    string `gorm:column:deleted_by;type:varchar(100)" json:"deleted_by"`

	Roles []*Role `gorm:"many2many:user_roles;"`
}

func UserFromCreateRequest(req *request.CreateUserRequest) (*UserEntity, error) {
	hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}
	return &UserEntity{
		Name:     req.Name,
		Username: req.Username,
		Email:    req.Email,
		Password: string(hashed),
	}, nil
}

func (u *UserEntity) FromUpdateRequest(req *request.UpdateUserRequest) *UserEntity {
	if req.Name != "" {
		u.Name = req.Name
	}
	return u
}
