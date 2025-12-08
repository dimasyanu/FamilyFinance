package repositories

import (
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"gorm.io/gorm"
)

type BudgetRepository struct {
	db *gorm.DB
}

func NewBudgetRepository(db *gorm.DB) *BudgetRepository {
	return &BudgetRepository{db: db}
}

func (br *BudgetRepository) List(f *filter.BudgetListFilter) (*[]models.Budget, int64) {
	budgets := &[]models.Budget{}
	var total int64
	query := br.db.Model(&models.Budget{})

	if f.Category > 0 {
		query = query.Where("category_id = ?", f.Category)
	}

	if f.DateFrom != "" {
		query = query.Where("start_date >= ?", f.DateFrom)
	}

	if f.DateTo != "" {
		query = query.Where("end_date <= ?", f.DateTo)
	}

	query.Count(&total)

	if f.Limit > 0 {
		query = query.Limit(f.Limit)
	}

	if f.Offset > 0 {
		query = query.Offset(f.Offset)
	}

	query.Find(budgets)

	return budgets, total
}

func (br *BudgetRepository) GetByID(id uint) (*models.Budget, error) {
	var budget models.Budget
	result := br.db.First(&budget, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &budget, nil
}

func (br *BudgetRepository) Create(budget *models.Budget) (uint, error) {
	result := br.db.Create(budget)
	if result.Error != nil {
		return 0, result.Error
	}
	return budget.ID, nil
}

func (br *BudgetRepository) Update(budget *models.Budget) error {
	result := br.db.Save(budget)
	return result.Error
}

func (br *BudgetRepository) Delete(budget *models.Budget) error {
	result := br.db.Delete(budget)
	return result.Error
}
