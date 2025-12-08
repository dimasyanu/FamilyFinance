package repositories

import (
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"gorm.io/gorm"
)

type CategoryRepository struct {
	db *gorm.DB
}

func NewCategoryRepository(db *gorm.DB) *CategoryRepository {
	return &CategoryRepository{db: db}
}

func (cr *CategoryRepository) ListAll() (*[]models.Category, error) {
	categories := &[]models.Category{}
	result := cr.db.Find(categories)
	if result.Error != nil {
		return nil, result.Error
	}
	return categories, nil
}

func (cr *CategoryRepository) List(filter *filter.CategoryListFilter) (*[]models.Category, int64) {
	categories := &[]models.Category{}
	total := int64(0)

	query := cr.db.Model(&models.Category{})

	if filter.Name != "" {
		query = query.Where("name LIKE ?", "%"+filter.Name+"%")
	}

	query.Count(&total)

	if filter.Limit > 0 {
		query = query.Limit(filter.Limit)
	}
	if filter.Offset > 0 {
		query = query.Offset(filter.Offset)
	}

	query.Find(categories)

	return categories, total
}

func (cr *CategoryRepository) GetByID(id uint) (*models.Category, error) {
	var category models.Category
	result := cr.db.First(&category, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &category, nil
}

func (cr *CategoryRepository) Create(category *models.Category) (uint, error) {
	result := cr.db.Create(category)
	if result.Error != nil {
		return 0, result.Error
	}
	return category.ID, nil
}

func (cr *CategoryRepository) Update(category *models.Category) error {
	result := cr.db.Save(category)
	return result.Error
}

func (cr *CategoryRepository) Delete(id uint) error {
	result := cr.db.Delete(&models.Category{}, id)
	return result.Error
}
