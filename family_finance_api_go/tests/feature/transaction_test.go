package feature

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
)

type TransactionTestSuite struct {
	BaseFeatureTestSuite
}

func (s *TransactionTestSuite) TestTransactionListing() {
	db := (*s.services)[services.DbKey].(*gorm.DB)

	account := &models.Account{Name: "Wallet", Description: "My Wallet", Color: "#333", Balance: 0, UserID: 1}
	err := db.Create(account).Error
	assert.NoError(s.t, err)

	category := &models.Category{Name: "Shopping", Description: "shopping expanse", Icon: 2, Color: "#321321", UserID: 1}
	err = db.Create(category).Error
	assert.NoError(s.t, err)

	ts1 := &models.Transaction{
		ID:              uuid.New(),
		TransactionType: -1,
		AccountID:       account.ID,
		CategoryID:      category.ID,
		Date:            time.Now(),
		Description:     "Buy some vegetables, and some fruits",
		Amount:          100000,
	}
	err = db.Create(ts1).Error
	assert.NoError(s.t, err)

	ts2 := &models.Transaction{
		ID:              uuid.New(),
		TransactionType: -1,
		AccountID:       account.ID,
		CategoryID:      category.ID,
		Date:            time.Now(),
		Description:     "Snacks",
		Amount:          25000,
	}
	err = db.Create(ts2).Error
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodGet, "/api/transactions", nil)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Add("Authorization", "Bearer "+s.accessToken)
	assert.NoError(s.t, err)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)

	var transactions r.Res[response.Paginated[models.Transaction]]
	err = json.Unmarshal(rec.Body.Bytes(), &transactions)
	assert.NoError(s.t, err)
	assert.Equal(s.t, 2, len(*transactions.Data.Items))
	assert.Equal(s.t, int64(2), transactions.Data.Total)
}

func (s *TransactionTestSuite) TestTransactionCreation() {
	db := (*s.services)[services.DbKey].(*gorm.DB)

	account := &models.Account{Name: "Wallet", Description: "My Wallet", Color: "#333", Balance: 0, UserID: 1}
	err := db.Create(account).Error
	assert.NoError(s.t, err)

	category := &models.Category{Name: "Shopping", Description: "shopping expanse", Icon: 2, Color: "#321321", UserID: 1}
	err = db.Create(category).Error
	assert.NoError(s.t, err)

	payload := &request.SaveTransactionRequest{
		TransactionType: -1,
		AccountID:       account.ID,
		CategoryID:      category.ID,
		Date:            time.Now().Format("2006-01-02"),
		Description:     "Buy some vegetables, and some fruits",
		Amount:          100000,
	}
	payloadBytes, err := json.Marshal(payload)
	assert.NoError(s.t, err)
	req, err := http.NewRequest(http.MethodPost, "/api/transactions", bytes.NewBuffer(payloadBytes))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Add("Authorization", "Bearer "+s.accessToken)
	assert.NoError(s.t, err)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Contains(s.t, rec.Body.String(), "successfully")
	assert.Equal(s.t, http.StatusCreated, rec.Result().StatusCode)

	result := &r.Res[response.Creation[uuid.UUID]]{}
	err = json.Unmarshal(rec.Body.Bytes(), result)
	assert.NoError(s.t, err)

	dbItem := &models.Transaction{}
	db.Model(&models.Transaction{}).First(dbItem)
	assert.Equal(s.t, dbItem.ID, result.Data.Id)
}

func TestTransaction(t *testing.T) {
	suite.Run(t, new(TransactionTestSuite))
}
