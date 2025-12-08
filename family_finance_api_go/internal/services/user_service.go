package services

import (
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/repositories"
)

type UserService struct {
	repo *repositories.UserRepository
}

func NewUserService(repo *repositories.UserRepository) *UserService {
	return &UserService{repo: repo}
}

// Get all users
func (us *UserService) List(f *filter.UserListFilter) response.Paginated[models.User] {
	users, total := us.repo.List(f)
	return response.Paginated[models.User]{Items: users, Total: total}
}

// Get user by ID
func (us *UserService) GetUserByID(id int64) *models.User {
	user, err := us.repo.GetByID(id)
	if err != nil {
		return nil
	}
	return user
}

func (us *UserService) GetByUsername(username string) *models.User {
	user := us.repo.GetByUsername(username)
	return user
}

// Create a new user
func (us *UserService) CreateUser(payload *request.CreateUserRequest) int64 {
	model, err := models.UserFromCreateRequest(payload)
	if err != nil {
		return 0
	}

	id, err := us.repo.Create(model)
	if err != nil {
		return 0
	}

	return id
}

// Update an existing user
func (us *UserService) UpdateUser(id int64, payload *request.UpdateUserRequest) (int64, error) {
	user, err := us.repo.GetByID(id)
	if err != nil {
		return 0, err
	}

	user = user.FromUpdateRequest(payload)
	err = us.repo.Update(user)
	if err != nil {
		return 0, err
	}

	return id, nil
}

// Delete a user
func (us *UserService) DeleteUser(id int64) error {
	err := us.repo.Delete(id)
	return err
}
