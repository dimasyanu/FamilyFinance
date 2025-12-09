package entities

import (
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	roleEntities "github.com/dimasyanu/family-finance-go/internal/roles/entities"
	userVobj "github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
	"golang.org/x/crypto/bcrypt"
)

type UserEntity struct {
	Id           userVobj.UserId       `gorm:"primaryKey;autoIncrement;column:id;type:int" json:"id"`
	Name         string                `gorm:"column:name;type:varchar(100);not null" json:"name"`
	Username     string                `gorm:"column:username;type:varchar(100);not null;unique" json:"username"`
	EmailAddress userVobj.EmailAddress `gorm:"column:email;type:varchar(100);not null;unique" json:"email"`
	PasswordHash string                `gorm:"column:password_hash;type:varchar(255);not null" json:"-"`

	Roles []*roleEntities.RoleEntity `gorm:"many2many:user_roles;"`
}

func UserFromCreateRequest(req *request.CreateUserRequest) (*UserEntity, error) {
	hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}
	return &UserEntity{
		Name:         req.Name,
		Username:     req.Username,
		EmailAddress: req.Email,
		PasswordHash: string(hashed),
	}, nil
}

func (u *UserEntity) FromUpdateRequest(req *request.UpdateUserRequest) *UserEntity {
	if req.Name != "" {
		u.Name = req.Name
	}
	return u
}
