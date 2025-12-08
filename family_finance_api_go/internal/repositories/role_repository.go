package repositories

import (
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"gorm.io/gorm"
)

type RoleRepository struct {
	db *gorm.DB
}

func NewRoleRepository(db *gorm.DB) *RoleRepository {
	return &RoleRepository{db: db}
}

// Lists all roles without any filtering
func (r *RoleRepository) ListAll() (*[]models.Role, error) {
	roles := &[]models.Role{}
	result := r.db.Find(roles)
	if result.Error != nil {
		return nil, result.Error
	}
	return roles, nil
}

// Retrieves roles based on the provided filter with pagination
func (r *RoleRepository) List(f *filter.RoleListFilter) (*[]models.Role, int64) {
	roles := &[]models.Role{}
	var total int64

	if f == nil {
		f = &filter.RoleListFilter{
			ListFilter: filter.ListFilter{
				Limit:  10,
				Offset: 0,
			},
		}
	}

	query := r.db.Model(&models.Role{})

	if f.Name != "" {
		query = query.Where("name LIKE ?", "%"+f.Name+"%")
	}

	query.Count(&total)

	result := query.Limit(f.Limit).Offset(f.Offset).Find(roles)
	if result.Error != nil {
		return &[]models.Role{}, 0
	}

	return roles, total
}

// Retrieves a role by its ID
func (r *RoleRepository) GetByID(id int64) (*models.Role, error) {
	var role models.Role
	result := r.db.First(&role, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &role, nil
}

// Retrieves a role by its name
func (r *RoleRepository) GetByName(name string) (*models.Role, error) {
	var role models.Role
	result := r.db.Where("name = ?", name).First(&role)
	if result.Error != nil {
		return nil, result.Error
	}
	return &role, nil
}

// Creates a new role in the database
func (r *RoleRepository) Create(role *models.Role) error {
	return r.db.Create(role).Error
}

// Creates a role if it does not already exist
func (r *RoleRepository) CreateIfNotExists(name string) error {
	var count int64
	r.db.Model(&models.Role{}).Where("name = ?", name).Count(&count)
	if count <= 0 {
		return r.Create(&models.Role{Name: name})
	}
	return nil
}

// Updates an existing role in the database
func (r *RoleRepository) Update(role *models.Role) error {
	return r.db.Save(role).Error
}

// Deletes a role from the database by ID
func (r *RoleRepository) Delete(id int64) error {
	return r.db.Delete(&models.Role{}, id).Error
}
