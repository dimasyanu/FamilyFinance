package repositories

import (
	"fmt"
	"strings"

	"github.com/dimasyanu/family-finance-go/internal/roles/entities"
	"github.com/dimasyanu/family-finance-go/internal/roles/models"
	"github.com/dimasyanu/family-finance-go/internal/roles/valueobjects"
	"gorm.io/gorm"

	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
	"github.com/dimasyanu/family-finance-go/internal/common/utils"
)

var orderFields = []string{
	"id",
	"name",
	"created_at",
	"updated_at",
}

type RoleRepository struct {
	db *gorm.DB
}

func NewRoleRepository(db *gorm.DB) *RoleRepository {
	return &RoleRepository{db: db}
}

// Lists all roles without any filtering
func (r *RoleRepository) ListAll() (*[]entities.RoleEntity, error) {
	roles := &[]entities.RoleEntity{}
	result := r.db.Order("name asc").Find(roles)
	if result.Error != nil {
		return nil, result.Error
	}
	return roles, nil
}

// Retrieves roles based on the provided filter with pagination
func (r *RoleRepository) List(f *models.RoleListFilter, so *commonModels.SortingOption) (*[]entities.RoleEntity, int16) {
	roles := &[]entities.RoleEntity{}
	var total int64

	if f == nil {
		f = &models.RoleListFilter{
			ListFilter: commonModels.ListFilter{
				Limit:  10,
				Offset: 0,
			},
		}
	}

	query := r.db.Model(&entities.RoleEntity{})

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

	result := query.Order(fmt.Sprintf("%s %s", so.Field, so.Direction)).Limit(f.Limit).Offset(f.Offset).Find(roles)
	if result.Error != nil {
		return &[]entities.RoleEntity{}, 0
	}

	return roles, int16(total)
}

// Retrieves a role by its ID
func (r *RoleRepository) GetByID(id valueobjects.RoleId) (*entities.RoleEntity, error) {
	var role entities.RoleEntity
	result := r.db.First(&role, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &role, nil
}

// Retrieves a role by its name
func (r *RoleRepository) GetByName(name string) (*entities.RoleEntity, error) {
	var role entities.RoleEntity
	result := r.db.Where("name = ?", name).First(&role)
	if result.Error != nil {
		return nil, result.Error
	}
	return &role, nil
}

// Creates a new role in the database
func (r *RoleRepository) Create(role *entities.RoleEntity) error {
	return r.db.Create(role).Error
}

// Creates a role if it does not already exist
func (r *RoleRepository) CreateIfNotExists(name string) error {
	var count int64
	r.db.Model(&entities.RoleEntity{}).Where("name = ?", name).Count(&count)
	if count <= 0 {
		return r.Create(&entities.RoleEntity{Name: name})
	}
	return nil
}

// Updates an existing role in the database
func (r *RoleRepository) Update(role *entities.RoleEntity) error {
	return r.db.Save(role).Error
}

// Deletes a role from the database by ID
func (r *RoleRepository) Delete(id int64) error {
	return r.db.Delete(&entities.RoleEntity{}, id).Error
}
