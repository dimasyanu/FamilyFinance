package services

import (
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/repositories"
)

type CategoryService struct {
	repo *repositories.CategoryRepository
}

func NewCategoryService(repo *repositories.CategoryRepository) *CategoryService {
	return &CategoryService{repo: repo}
}

func (cs *CategoryService) List(f *filter.CategoryListFilter) (*response.Paginated[models.Category], error) {
	items, total := cs.repo.List(f)
	return &response.Paginated[models.Category]{Items: items, Total: total}, nil
}

func (cs *CategoryService) GetByID(id uint) (*models.Category, error) {
	category, err := cs.repo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return category, nil
}

func (cs *CategoryService) Create(payload *request.SaveCategoryRequest) (uint, error) {
	model := models.FromCreateCategoryRequest(payload)

	id, err := cs.repo.Create(model)
	if err != nil {
		return 0, err
	}

	return id, nil
}

func (cs *CategoryService) Update(id uint, payload *request.SaveCategoryRequest) (uint, error) {
	category, err := cs.repo.GetByID(id)
	if err != nil {
		return 0, err
	}

	category.Name = payload.Name
	category.Description = payload.Description
	category.Color = payload.Color
	category.Icon = payload.Icon
	category.UserID = payload.UserId

	err = cs.repo.Update(category)
	if err != nil {
		return 0, err
	}

	return id, nil
}

func (cs *CategoryService) Delete(id uint) error {
	err := cs.repo.Delete(id)
	return err
}
