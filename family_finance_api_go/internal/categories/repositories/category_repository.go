package repositories

import (
	"github.com/dimasyanu/family-finance-go/internal/categories/entities"
	"github.com/dimasyanu/family-finance-go/internal/categories/models"
	"gorm.io/gorm"
)

type CategoryRepository struct {
	db *gorm.DB
}

func NewCategoryRepository(db *gorm.DB) *CategoryRepository {
	return &CategoryRepository{db: db}
}

func (cr *CategoryRepository) ListAll() (*[]entities.CategoryEntity, error) {
	categories := &[]entities.CategoryEntity{}
	result := cr.db.Find(categories)
	if result.Error != nil {
		return nil, result.Error
	}
	return categories, nil
}

func (cr *CategoryRepository) List(filter *models.CategoryListFilter) (*[]entities.CategoryEntity, int64) {
	categories := &[]entities.CategoryEntity{}
	total := int64(0)

	query := cr.db.Model(&entities.CategoryEntity{})

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

func (cr *CategoryRepository) GetByID(id uint) (*entities.CategoryEntity, error) {
	var category entities.CategoryEntity
	result := cr.db.First(&category, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &category, nil
}

func (cr *CategoryRepository) Create(category *entities.CategoryEntity) (uint, error) {
	result := cr.db.Create(category)
	if result.Error != nil {
		return 0, result.Error
	}
	return category.ID, nil
}

func (cr *CategoryRepository) Update(category *entities.CategoryEntity) error {
	result := cr.db.Save(category)
	return result.Error
}

func (cr *CategoryRepository) Delete(id uint) error {
	result := cr.db.Delete(&entities.CategoryEntity{}, id)
	return result.Error
}
