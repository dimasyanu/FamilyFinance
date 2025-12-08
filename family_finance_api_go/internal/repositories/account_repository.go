package repositories

import (
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"gorm.io/gorm"
)

type AccountRepository struct {
	db *gorm.DB
}

func NewAccountRepository(db *gorm.DB) *AccountRepository {
	return &AccountRepository{db: db}
}

func (ar *AccountRepository) ListAll() (*[]models.Account, error) {
	accounts := &[]models.Account{}
	result := ar.db.Find(accounts)
	if result.Error != nil {
		return nil, result.Error
	}
	return accounts, nil
}

func (ar *AccountRepository) List(filter *filter.AccountListFilter) (*[]models.Account, int64) {
	accounts := &[]models.Account{}
	total := int64(0)

	query := ar.db.Model(&models.Account{})

	if filter.Search != "" {
		query = query.Where("name LIKE ?", "%"+filter.Search+"%")
	}

	query.Count(&total)

	if filter.Limit > 0 {
		query = query.Limit(filter.Limit)
	}
	if filter.Offset > 0 {
		query = query.Offset(filter.Offset)
	}

	query.Find(accounts)

	return accounts, total
}

func (ar *AccountRepository) GetByID(id uint) (*models.Account, error) {
	var account models.Account
	result := ar.db.First(&account, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &account, nil
}

func (ar *AccountRepository) Create(account *models.Account) (uint, error) {
	result := ar.db.Create(account)
	if result.Error != nil {
		return 0, result.Error
	}
	return account.ID, nil
}

func (ar *AccountRepository) Update(account *models.Account) error {
	result := ar.db.Save(account)
	return result.Error
}

func (ar *AccountRepository) Delete(account *models.Account) error {
	result := ar.db.Delete(account)
	return result.Error
}
