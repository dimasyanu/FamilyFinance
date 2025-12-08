package repositories

import (
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Retrieves users based on the provided filter with pagination
func (ur *UserRepository) List(f *filter.UserListFilter) (*[]models.User, int64) {
	users := &[]models.User{}
	var total int64

	query := ur.db.Model(&models.User{})

	if f.Name != "" {
		query = query.Where("name LIKE ?", "%"+f.Name+"%")
	}

	query.Count(&total)

	result := query.Limit(f.Limit).Offset(f.Offset).Find(users)
	if result.Error != nil {
		return &[]models.User{}, 0
	}

	return users, total
}

// Retrieves a user by their ID
func (ur *UserRepository) GetByID(id int64) (*models.User, error) {
	var user models.User
	result := ur.db.First(&user, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

// Retrieves a user by their username
func (ur *UserRepository) GetByUsername(username string) *models.User {
	var user models.User
	result := ur.db.Where("username = ?", username).First(&user)
	if result.Error != nil {
		return nil
	}
	return &user
}

// Creates a new user in the database
func (ur *UserRepository) Create(user *models.User) (int64, error) {
	result := ur.db.Create(user)
	return int64(user.ID), result.Error
}

// Updates an existing user in the database
func (ur *UserRepository) Update(user *models.User) error {
	result := ur.db.Save(user)
	return result.Error
}

// Deletes a user from the database by ID
func (ur *UserRepository) Delete(id int64) error {
	result := ur.db.Delete(&models.User{}, id)
	return result.Error
}
