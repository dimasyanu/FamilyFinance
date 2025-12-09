package repositories

import (
	"github.com/dimasyanu/family-finance-go/internal/users/entities"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Retrieves users based on the provided filter with pagination
func (ur *UserRepository) List(f *models.UserFilter) (*[]entities.UserEntity, int64) {
	users := &[]entities.UserEntity{}
	var total int64

	query := ur.db.Model(&entities.UserEntity{})

	if f.Name != "" {
		query = query.Where("name LIKE ?", "%"+f.Name+"%")
	}

	query.Count(&total)

	result := query.Limit(f.Limit).Offset(f.Offset).Find(users)
	if result.Error != nil {
		return &[]entities.UserEntity{}, 0
	}

	return users, total
}

// Retrieves a user by their ID
func (ur *UserRepository) GetByID(id int64) (*entities.UserEntity, error) {
	var user entities.UserEntity
	result := ur.db.First(&user, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

// Retrieves a user by their username
func (ur *UserRepository) GetByUsername(username string) *entities.UserEntity {
	var user entities.UserEntity
	result := ur.db.Where("username = ?", username).First(&user)
	if result.Error != nil {
		return nil
	}
	return &user
}

// Creates a new user in the database
func (ur *UserRepository) Create(user *entities.UserEntity) (int64, error) {
	result := ur.db.Create(user)
	return int64(user.Id), result.Error
}

// Updates an existing user in the database
func (ur *UserRepository) Update(user *entities.UserEntity) error {
	result := ur.db.Save(user)
	return result.Error
}
