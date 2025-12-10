package services

import (
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/roles/repositories"

	"github.com/dimasyanu/family-finance-go/internal/roles/models"
)

type RoleService struct {
	repo *repositories.RoleRepository
}

func NewRoleService(repo *repositories.RoleRepository) *RoleService {
	return &RoleService{repo: repo}
}

// Creates default roles if they do not already exist
func (rs *RoleService) CreateDefaultRoles() {
}

// Lists all roles without any filtering
func (rs *RoleService) ListAllRoles() (*[]models.Role, error) {
	return rs.repo.ListAll()
}

// Lists roles based on the provided filter with pagination
func (rs *RoleService) ListRoles(filter *filter.RoleListFilter) (*response.Paginated[models.Role], error) {
	items, total := rs.repo.List(filter)
	return &models.Paginated[models.Role]{Items: items, Total: total}, nil
}

// Retrieves a role by its ID
func (rs *RoleService) GetRoleByID(id int64) (*models.Role, error) {
	return rs.repo.GetByID(id)
}

// Get a role by its name
func (rs *RoleService) GetRoleByName(name string) (*models.Role, error) {
	return rs.repo.GetByName(name)
}

// Creates a new role
func (rs *RoleService) CreateRole(role *models.Role) error {
	return rs.repo.Create(role)
}

// Updates an existing role
func (rs *RoleService) UpdateRole(role *models.Role) error {
	return rs.repo.Update(role)
}

// Deletes a role by its ID
func (rs *RoleService) DeleteRole(id int64) error {
	return rs.repo.Delete(id)
}
