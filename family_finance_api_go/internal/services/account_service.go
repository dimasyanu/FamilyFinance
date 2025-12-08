package services

import (
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/repositories"
)

type AccountService struct {
	repo *repositories.AccountRepository
}

func NewAccountService(repo *repositories.AccountRepository) *AccountService {
	return &AccountService{repo: repo}
}

func (as *AccountService) List(f *filter.AccountListFilter) (*response.Paginated[models.Account], error) {
	accounts, total := as.repo.List(f)
	return &response.Paginated[models.Account]{Items: accounts, Total: total}, nil
}

func (as *AccountService) GetByID(id uint) (*models.Account, error) {
	account, err := as.repo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return account, nil
}

func (as *AccountService) Create(account *models.Account) (uint, error) {
	id, err := as.repo.Create(account)
	if err != nil {
		return 0, err
	}

	return id, nil
}

func (as *AccountService) Update(id uint, payload *request.SaveAccountRequest) (uint, error) {
	account, err := as.repo.GetByID(id)
	if err != nil {
		return 0, err
	}

	account.Name = payload.Name
	account.Description = payload.Description
	account.Color = payload.Color
	account.Balance = payload.Balance
	account.UserID = payload.UserID

	err = as.repo.Update(account)
	if err != nil {
		return 0, err
	}

	return id, nil
}

func (as *AccountService) Delete(id uint) error {
	account, err := as.repo.GetByID(id)
	if err != nil {
		return err
	}

	err = as.repo.Delete(account)
	if err != nil {
		return err
	}

	return nil
}
