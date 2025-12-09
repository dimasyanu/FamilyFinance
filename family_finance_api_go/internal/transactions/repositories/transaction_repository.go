package repositories

import (
	"time"

	"github.com/dimasyanu/family-finance-go/internal/transactions/entities"
	"github.com/dimasyanu/family-finance-go/internal/transactions/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type TransactionRepository struct {
	db *gorm.DB
}

func NewTransactionRepository(db *gorm.DB) *TransactionRepository {
	return &TransactionRepository{db: db}
}

func (r *TransactionRepository) List(f *models.TransactionListFilter) (*[]entities.TransactionEntity, int64) {
	transactions := &[]entities.TransactionEntity{}
	var total int64

	query := r.db.Model(&entities.TransactionEntity{})

	if f.UserID > 0 {
		query = query.Where("user_id = ?", f.UserID)
	}
	if f.AccountID > 0 {
		query = query.Where("account_id = ?", f.AccountID)
	}
	if f.CategoryID > 0 {
		query = query.Where("category_id = ?", f.CategoryID)
	}
	if f.MinAmount > 0 {
		query = query.Where("amount >= ?", f.MinAmount)
	}
	if f.MaxAmount > 0 {
		query = query.Where("amount <= ?", f.MaxAmount)
	}

	query.Count(&total)

	if f.Limit > 0 {
		query = query.Limit(f.Limit)
	}
	if f.Offset > 0 {
		query = query.Offset(f.Offset)
	}

	query.Find(transactions)

	return transactions, total
}

func (r *TransactionRepository) GetByID(id uuid.UUID) (*entities.TransactionEntity, error) {
	var transaction entities.TransactionEntity
	if err := r.db.First(&transaction, id).Error; err != nil {
		return nil, err
	}
	return &transaction, nil
}

func (r *TransactionRepository) Create(transaction *entities.TransactionEntity) (uuid.UUID, error) {
	err := r.db.Create(transaction).Error
	return transaction.ID, err
}

func (r *TransactionRepository) Update(transaction *entities.TransactionEntity) error {
	return r.db.Save(transaction).Error
}

func (r *TransactionRepository) Trash(id uuid.UUID, deletedBy uint) error {
	return r.db.Model(&entities.TransactionEntity{}).Where("id = ?", id).Updates(map[string]interface{}{
		"deleted_at": gorm.DeletedAt{Time: time.Now(), Valid: true},
		"deleted_by": deletedBy,
	}).Error
}

func (r *TransactionRepository) Restore(id uuid.UUID) error {
	return r.db.Model(&entities.TransactionEntity{}).Where("id = ?", id).Updates(map[string]interface{}{
		"deleted_at": nil,
		"deleted_by": nil,
	}).Error
}

func (r *TransactionRepository) Delete(id uuid.UUID) error {
	return r.db.Unscoped().Delete(&entities.TransactionEntity{}, id).Error
}
