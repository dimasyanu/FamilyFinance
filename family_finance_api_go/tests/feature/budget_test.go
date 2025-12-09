package feature

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type BudgetTestSuite struct {
	BaseFeatureTestSuite
}

func (s *BudgetTestSuite) TestBudgetListing() {
	db := (*s.services)[services.DbKey].(*gorm.DB)

	// Create sample category
	cat := models.Category{Name: "Sample Category", Description: "A sample category", Icon: 1, Color: "#FFFFFF", UserID: 1}
	err := db.Create(&cat).Error
	assert.NoError(s.t, err)

	// Create sample budgets
	bud1Start, _ := time.Parse("2006-01-02", "2024-01-01")
	bud1End, _ := time.Parse("2006-01-02", "2024-01-31")
	bud2Start, _ := time.Parse("2006-01-02", "2024-02-01")
	bud2End, _ := time.Parse("2006-01-02", "2024-02-28")
	bud1 := models.Budget{Amount: 1000, StartDate: bud1Start, EndDate: bud1End, CategoryID: cat.ID}
	bud2 := models.Budget{Amount: 2000, StartDate: bud2Start, EndDate: bud2End, CategoryID: cat.ID}
	assert.NoError(s.t, db.Create(&bud1).Error)
	assert.NoError(s.t, db.Create(&bud2).Error)

	req, err := http.NewRequest(http.MethodGet, "/api/budgets", nil)
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var budgets r.Res[response.Paginated[models.Budget]]
	err = json.Unmarshal(rec.Body.Bytes(), &budgets)
	assert.NoError(s.t, err)
	assert.Equal(s.t, 2, len(*budgets.Data.Items))
}

func (s *BudgetTestSuite) TestBudgetCreation() {
	payload := &request.SaveBudgetRequest{
		Amount:     1500,
		StartDate:  "2024-03-01",
		EndDate:    "2024-03-31",
		CategoryID: 1,
	}
	payloadBytes, err := json.Marshal(payload)
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodPost, "/api/budgets", bytes.NewBuffer(payloadBytes))
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)
	req.Header.Set("Content-Type", "application/json")

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var resp r.Res[response.Creation[uint]]
	err = json.Unmarshal(rec.Body.Bytes(), &resp)
	assert.NoError(s.t, err)
	assert.Greater(s.t, resp.Data.Id, uint(0))
}

func (s *BudgetTestSuite) TestBudgetRetrieval() {
	db := (*s.services)[services.DbKey].(*gorm.DB)

	// Create sample category
	cat := models.Category{Name: "Sample Category 2", Description: "Another sample category", Icon: 2, Color: "#000000", UserID: 1}
	err := db.Create(&cat).Error
	assert.NoError(s.t, err)

	// Create sample budget
	budStart, _ := time.Parse("2006-01-02", "2024-04-01")
	budEnd, _ := time.Parse("2006-01-02", "2024-04-30")
	budget := models.Budget{Amount: 2500, StartDate: budStart, EndDate: budEnd, CategoryID: cat.ID}
	assert.NoError(s.t, db.Create(&budget).Error)

	req, err := http.NewRequest(http.MethodGet, "/api/budgets/"+fmt.Sprintf("%d", budget.ID), nil)
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var resp r.Res[models.Budget]
	err = json.Unmarshal(rec.Body.Bytes(), &resp)
	assert.NoError(s.t, err)
	assert.Equal(s.t, budget.ID, resp.Data.ID)
	assert.Equal(s.t, budget.Amount, resp.Data.Amount)
	assert.Equal(s.t, budget.CategoryID, resp.Data.CategoryID)
	assert.Equal(s.t, budget.StartDate.Format("2006-01-02"), resp.Data.StartDate.Format("2006-01-02"))
	assert.Equal(s.t, budget.EndDate.Format("2006-01-02"), resp.Data.EndDate.Format("2006-01-02"))
}

func (s *BudgetTestSuite) TestBudgetUpdate() {
	db := (*s.services)[services.DbKey].(*gorm.DB)

	// Create sample category
	cat := models.Category{Name: "Sample Category 3", Description: "Yet another sample category", Icon: 3, Color: "#FF0000", UserID: 1}
	err := db.Create(&cat).Error
	assert.NoError(s.t, err)

	// Create sample budget
	budStart, _ := time.Parse("2006-01-02", "2024-05-01")
	budEnd, _ := time.Parse("2006-01-02", "2024-05-31")
	budget := models.Budget{Amount: 3000, StartDate: budStart, EndDate: budEnd, CategoryID: cat.ID}
	assert.NoError(s.t, db.Create(&budget).Error)

	// Prepare update payload
	updatePayload := &request.SaveBudgetRequest{
		Amount:     3500,
		StartDate:  "2024-05-01",
		EndDate:    "2024-05-31",
		CategoryID: cat.ID,
	}
	payloadBytes, err := json.Marshal(updatePayload)
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodPatch, "/api/budgets/"+fmt.Sprintf("%d", budget.ID), bytes.NewBuffer(payloadBytes))
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)
	req.Header.Set("Content-Type", "application/json")

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var resp r.Res[response.Creation[uint]]
	err = json.Unmarshal(rec.Body.Bytes(), &resp)
	assert.NoError(s.t, err)
	assert.Equal(s.t, uint(budget.ID), resp.Data.Id)

	// Verify update in database
	var updatedBudget models.Budget
	err = db.First(&updatedBudget, budget.ID).Error
	assert.NoError(s.t, err)
	assert.Equal(s.t, updatePayload.Amount, updatedBudget.Amount)
	assert.Equal(s.t, updatePayload.CategoryID, updatedBudget.CategoryID)
	assert.Equal(s.t, updatePayload.StartDate, updatedBudget.StartDate.Format("2006-01-02"))
	assert.Equal(s.t, updatePayload.EndDate, updatedBudget.EndDate.Format("2006-01-02"))
}

func (s *BudgetTestSuite) TestBudgetDeletion() {
	db := (*s.services)[services.DbKey].(*gorm.DB)

	// Create sample category
	cat := models.Category{Name: "Sample Category 4", Description: "Sample category for deletion", Icon: 4, Color: "#00FF00", UserID: 1}
	err := db.Create(&cat).Error
	assert.NoError(s.t, err)

	// Create sample budget
	budStart, _ := time.Parse("2006-01-02", "2024-06-01")
	budEnd, _ := time.Parse("2006-01-02", "2024-06-30")
	budget := models.Budget{Amount: 4000, StartDate: budStart, EndDate: budEnd, CategoryID: cat.ID}
	assert.NoError(s.t, db.Create(&budget).Error)

	req, err := http.NewRequest(http.MethodDelete, "/api/budgets/"+fmt.Sprintf("%d", budget.ID), nil)
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	// Verify deletion in database
	var deletedBudget models.Budget
	err = db.First(&deletedBudget, budget.ID).Error
	assert.Error(s.t, err)
	assert.Equal(s.t, gorm.ErrRecordNotFound, err)
}

func TestBudget(t *testing.T) {
	suite.Run(t, new(BudgetTestSuite))
}
