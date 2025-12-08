package services

import (
	"time"

	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/repositories"
	"github.com/google/uuid"
)

type TransactionService struct {
	repo *repositories.TransactionRepository
}

func NewTransactionService(repo *repositories.TransactionRepository) *TransactionService {
	return &TransactionService{repo: repo}
}

func (s *TransactionService) List(filter *filter.TransactionListFilter) (response.Paginated[models.Transaction], error) {
	items, total := s.repo.List(filter)
	return response.Paginated[models.Transaction]{Items: items, Total: total}, nil
}

func (s *TransactionService) GetByID(id uuid.UUID) (*models.Transaction, error) {
	return s.repo.GetByID(id)
}

func (s *TransactionService) Create(payload *request.SaveTransactionRequest, userId uint) (uuid.UUID, error) {
	transaction := models.FromCreateTransactionRequest(payload, userId)
	return s.repo.Create(transaction)
}

func (s *TransactionService) Update(id uuid.UUID, transaction *request.SaveTransactionRequest, userId uint) error {
	item, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}

	item.AccountID = transaction.AccountID
	item.CategoryID = transaction.CategoryID
	item.TargetAccountID = transaction.TargetAccountID
	item.Description = transaction.Description
	item.Date, _ = time.Parse("2006-01-02", transaction.Date)
	item.Amount = transaction.Amount
	item.TransactionType = transaction.TransactionType

	return s.repo.Update(item)
}

func (s *TransactionService) Trash(id uuid.UUID, deletedBy uint) error {
	return s.repo.Trash(id, deletedBy)
}

func (s *TransactionService) Restore(id uuid.UUID) error {
	return s.repo.Restore(id)
}

func (s *TransactionService) Delete(id uuid.UUID) error {
	return s.repo.Delete(id)
}
