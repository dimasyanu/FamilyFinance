package feature

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type AccountTestSuite struct {
	BaseFeatureTestSuite
}

func (s *AccountTestSuite) TestAccountListing() {
	db := (*s.services)[services.DbKey].(*gorm.DB)
	account1 := models.Account{Name: "Account 1", Description: "First account", Color: "#123456", Balance: 100.0, UserID: 1}
	account2 := models.Account{Name: "Account 2", Description: "Second account", Color: "#654321", Balance: 200.0, UserID: 1}
	err := db.Create(&account1).Error
	assert.NoError(s.t, err)
	err = db.Create(&account2).Error
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodGet, "/api/accounts", nil)
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var accounts r.Res[response.Paginated[models.Account]]
	err = json.Unmarshal(rec.Body.Bytes(), &accounts)
	assert.NoError(s.t, err)
	assert.Equal(s.t, 2, len(*accounts.Data.Items))
}

func (s *AccountTestSuite) TestAccountCreation() {
	newAccount := map[string]interface{}{
		"name":        "New Account",
		"description": "A newly created account",
		"color":       "#abcdef",
		"balance":     500.0,
		"user_id":     1,
	}
	payload, err := json.Marshal(newAccount)
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodPost, "/api/accounts", bytes.NewBuffer(payload))
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)
	req.Header.Set("Content-Type", "application/json")

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusCreated, rec.Code)

	var creationResp r.Res[response.Creation[uint]]
	err = json.Unmarshal(rec.Body.Bytes(), &creationResp)
	assert.NoError(s.t, err)
	assert.Greater(s.t, creationResp.Data.ID, uint(0))
}

func (s *AccountTestSuite) TestAccountRetrieval() {
	db := (*s.services)[services.DbKey].(*gorm.DB)
	account := models.Account{Name: "Retrieve Account", Description: "Account to retrieve", Color: "#112233", Balance: 300.0, UserID: 1}
	err := db.Create(&account).Error
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodGet, "/api/accounts/"+fmt.Sprintf("%d", account.ID), nil)
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var accountResp r.Res[models.Account]
	err = json.Unmarshal(rec.Body.Bytes(), &accountResp)
	assert.NoError(s.t, err)
	assert.Equal(s.t, account.Name, accountResp.Data.Name)
	assert.Equal(s.t, account.Description, accountResp.Data.Description)
}

func (s *AccountTestSuite) TestAccountUpdate() {
	db := (*s.services)[services.DbKey].(*gorm.DB)
	account := models.Account{Name: "Update Account", Description: "Account to update", Color: "#445566", Balance: 400.0, UserID: 1}
	err := db.Create(&account).Error
	assert.NoError(s.t, err)

	updatedData := map[string]any{
		"name":        "Updated Account",
		"description": "This account has been updated",
		"color":       "#667788",
		"balance":     450.0,
		"user_id":     1,
	}
	payload, err := json.Marshal(updatedData)
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodPatch, "/api/accounts/"+fmt.Sprintf("%d", account.ID), bytes.NewBuffer(payload))
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)
	req.Header.Set("Content-Type", "application/json")

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var updateResp r.Res[response.Creation[uint]]
	err = json.Unmarshal(rec.Body.Bytes(), &updateResp)
	assert.NoError(s.t, err)
	assert.Equal(s.t, uint(account.ID), updateResp.Data.ID)
}

func (s *AccountTestSuite) TestAccountDeletion() {
	db := (*s.services)[services.DbKey].(*gorm.DB)
	account := models.Account{Name: "Delete Account", Description: "Account to delete", Color: "#998877", Balance: 600.0, UserID: 1}
	err := db.Create(&account).Error
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodDelete, "/api/accounts/"+fmt.Sprintf("%d", account.ID), nil)
	assert.NoError(s.t, err)
	req.Header.Set("Authorization", "Bearer "+s.accessToken)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var deleteResp r.Res[any]
	err = json.Unmarshal(rec.Body.Bytes(), &deleteResp)
	assert.NoError(s.t, err)

	var deletedAccount models.Account
	err = db.First(&deletedAccount, account.ID).Error
	assert.Error(s.t, err)
	assert.Equal(s.t, gorm.ErrRecordNotFound, err)
}

func TestAccount(t *testing.T) {
	suite.Run(t, new(AccountTestSuite))
}
