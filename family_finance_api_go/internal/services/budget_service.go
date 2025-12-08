package services

import (
	"errors"
	"time"

	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/repositories"
	"gorm.io/gorm"
)

type BudgetService struct {
	repo *repositories.BudgetRepository
}

func NewBudgetService(repo *repositories.BudgetRepository) *BudgetService {
	return &BudgetService{repo: repo}
}

func (bs *BudgetService) List(f *filter.BudgetListFilter) (*response.Paginated[models.Budget], error) {
	budgets, total := bs.repo.List(f)
	return &response.Paginated[models.Budget]{Items: budgets, Total: total}, nil
}

func (bs *BudgetService) GetByID(id uint) (*models.Budget, error) {
	budget, err := bs.repo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return budget, nil
}

func (bs *BudgetService) Create(payload *request.SaveBudgetRequest) (uint, error) {
	const layout = "2006-01-02"
	startDate, err := time.Parse(layout, payload.StartDate)
	if err != nil {
		return 0, err
	}
	endDate, err := time.Parse(layout, payload.EndDate)
	if err != nil {
		return 0, err
	}

	budget := &models.Budget{
		Amount:     payload.Amount,
		StartDate:  startDate,
		EndDate:    endDate,
		CategoryID: payload.CategoryID,

		Model: gorm.Model{
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		},
	}

	id, err := bs.repo.Create(budget)
	if err != nil {
		return 0, err
	}

	return id, nil
}

func (bs *BudgetService) Update(id uint, payload *request.SaveBudgetRequest) (uint, error) {
	budget, err := bs.repo.GetByID(id)
	if err != nil {
		return 0, err
	}

	budget.Amount = payload.Amount
	budget.CategoryID = payload.CategoryID

	const layout = "2006-01-02"
	budget.StartDate, err = time.Parse(layout, payload.StartDate)
	if err != nil {
		return 0, errors.New("invalid date format")
	}
	budget.EndDate, err = time.Parse(layout, payload.EndDate)
	if err != nil {
		return 0, errors.New("invalid date format")
	}

	err = bs.repo.Update(budget)
	if err != nil {
		return 0, err
	}

	return id, nil
}

func (bs *BudgetService) Delete(id uint) error {
	budget, err := bs.repo.GetByID(id)
	if err != nil {
		return err
	}

	err = bs.repo.Delete(budget)
	if err != nil {
		return err
	}

	return nil
}
