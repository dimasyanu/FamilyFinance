package repositories

import (
	"github.com/dimasyanu/family-finance-go/internal/accounts/entities"
	"github.com/dimasyanu/family-finance-go/internal/accounts/models"
	"gorm.io/gorm"
)

type AccountRepository struct {
	db *gorm.DB
}

func NewAccountRepository(db *gorm.DB) *AccountRepository {
	return &AccountRepository{db: db}
}

func (ar *AccountRepository) ListAll() (*[]entities.AccountEntity, error) {
	accounts := &[]entities.AccountEntity{}
	result := ar.db.Find(accounts)
	if result.Error != nil {
		return nil, result.Error
	}
	return accounts, nil
}

func (ar *AccountRepository) List(filter *models.AccountListFilter) (*[]entities.AccountEntity, int64) {
	accounts := &[]entities.AccountEntity{}
	total := int64(0)

	query := ar.db.Model(&entities.AccountEntity{})

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

func (ar *AccountRepository) GetByID(id uint) (*entities.AccountEntity, error) {
	var account entities.AccountEntity
	result := ar.db.First(&account, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &account, nil
}

func (ar *AccountRepository) Create(account *entities.AccountEntity) (uint, error) {
	result := ar.db.Create(account)
	if result.Error != nil {
		return 0, result.Error
	}
	return account.ID, nil
}

func (ar *AccountRepository) Update(account *entities.AccountEntity) error {
	result := ar.db.Save(account)
	return result.Error
}

func (ar *AccountRepository) Delete(account *entities.AccountEntity) error {
	result := ar.db.Delete(account)
	return result.Error
}
