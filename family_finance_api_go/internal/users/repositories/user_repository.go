package repositories

import (
	"fmt"
	"strings"

	common "github.com/dimasyanu/family-finance-go/internal/common/models"
	"github.com/dimasyanu/family-finance-go/internal/common/utils"
	"github.com/dimasyanu/family-finance-go/internal/users/entities"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
	"github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
	"gorm.io/gorm"
)

var orderFields = []string{
	"id",
	"username",
	"name",
	"email",
	"created_at",
	"updated_at",
}

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Retrieves users based on the provided filter with pagination
func (ur *UserRepository) List(f *models.UserFilter, so *common.SortingOption) (*[]entities.UserEntity, int64) {
	users := &[]entities.UserEntity{}
	var total int64

	query := ur.db.Model(&entities.UserEntity{})

	if f.Name != "" {
		query = query.Where("name LIKE ?", "%"+f.Name+"%")
	}

	query.Count(&total)

	so.Field = strings.ToLower(so.Field)
	if so.Field == "" || !utils.InArray(orderFields, so.Field) {
		so.Field = "updated_at"
		so.Direction = "desc"
	} else if so.Direction == "" {
		so.Direction = "asc"
	}

	result := query.Order(fmt.Sprintf("%s %s", so.Field, so.Direction)).Limit(f.Limit).Offset(f.Offset).Find(users)
	if result.Error != nil {
		return &[]entities.UserEntity{}, 0
	}

	return users, total
}

// Retrieves a user by their ID
func (ur *UserRepository) GetByID(id valueobjects.UserId) (*entities.UserEntity, error) {
	var user entities.UserEntity
	result := ur.db.First(&user, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

// Retrieves a user by their username
func (ur *UserRepository) GetByUsername(username string) (*entities.UserEntity, error) {
	var user entities.UserEntity
	result := ur.db.Where("username = ?", username).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

// Creates a new user in the database
func (ur *UserRepository) Create(user *entities.UserEntity) (valueobjects.UserId, error) {
	result := ur.db.Create(user)
	return user.Id, result.Error
}

// Updates an existing user in the database
func (ur *UserRepository) Update(user *entities.UserEntity) error {
	result := ur.db.Save(user)
	return result.Error
}
