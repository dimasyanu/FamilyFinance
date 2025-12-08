package feature

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
)

type CategoryTestSuite struct {
	BaseFeatureTestSuite
}

func (s *CategoryTestSuite) TestGetCategories() {
	db := (*s.services)[services.DbKey].(*gorm.DB)
	cat1 := models.Category{Name: "Cat 1", Description: "First category", Icon: 1, Color: "#111111"}
	cat2 := models.Category{Name: "Cat 2", Description: "Second category", Icon: 2, Color: "#222222"}
	err := db.Create(&cat1).Error
	assert.NoError(s.t, err)
	err = db.Create(&cat2).Error
	assert.NoError(s.t, err)

	getReq, err := http.NewRequest(http.MethodGet, "/api/categories", nil)
	assert.NoError(s.t, err)
	getReq.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, getReq)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var categories r.Res[response.Paginated[models.Category]]
	err = json.Unmarshal(rec.Body.Bytes(), &categories)
	assert.NoError(s.t, err)
	assert.Equal(s.t, 2, len(*categories.Data.Items))
}

func (s *CategoryTestSuite) TestCategoryCreation() {
	newCat := &request.SaveCategoryRequest{
		Name:        "Test Category",
		Description: "A category for testing",
		Icon:        2,
		Color:       "#333333",
	}
	payloadBytes, err := json.Marshal(newCat)
	assert.NoError(s.t, err)

	createReq, err := http.NewRequest(http.MethodPost, "/api/categories", bytes.NewBuffer(payloadBytes))
	assert.NoError(s.t, err)
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, createReq)
	assert.Equal(s.t, http.StatusCreated, rec.Code)

	db := (*s.services)[services.DbKey].(*gorm.DB)
	cats := &[]models.Category{}
	err = db.Find(cats).Error
	assert.NoError(s.t, err)
	assert.Equal(s.t, 1, len(*cats))
	assert.Equal(s.t, newCat.Name, (*cats)[0].Name)
	assert.Equal(s.t, newCat.Description, (*cats)[0].Description)
	assert.Equal(s.t, newCat.Icon, (*cats)[0].Icon)
	assert.Equal(s.t, newCat.Color, (*cats)[0].Color)
}

func (s *CategoryTestSuite) TestCategoryCreationInvalidPayload() {
	invalidPayload := []byte(`{"name": "", "description": "A category", "icon": -1, "color": "not-a-color"}`)
	createReq, err := http.NewRequest(http.MethodPost, "/api/categories", bytes.NewBuffer(invalidPayload))
	assert.NoError(s.t, err)
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, createReq)
	assert.Equal(s.t, http.StatusBadRequest, rec.Code)
}

func (s *CategoryTestSuite) TestCategoryGetByID() {
	db := (*s.services)[services.DbKey].(*gorm.DB)
	cat := models.Category{Name: "Cat GetByID", Description: "Category to get by ID", Icon: 3, Color: "#444444"}
	err := db.Create(&cat).Error
	assert.NoError(s.t, err)

	getReq, err := http.NewRequest(http.MethodGet, "/api/categories/"+strconv.FormatUint(uint64(cat.ID), 10), nil)
	assert.NoError(s.t, err)
	getReq.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, getReq)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var category r.Res[models.Category]
	err = json.Unmarshal(rec.Body.Bytes(), &category)
	assert.NoError(s.t, err)
	assert.Equal(s.t, cat.Name, category.Data.Name)
	assert.Equal(s.t, cat.Description, category.Data.Description)
	assert.Equal(s.t, cat.Icon, category.Data.Icon)
	assert.Equal(s.t, cat.Color, category.Data.Color)
}

func (s *CategoryTestSuite) TestCategoryModification() {
	db := (*s.services)[services.DbKey].(*gorm.DB)
	cat := models.Category{Name: "Cat To Modify", Description: "Category before modification", Icon: 4, Color: "#555555"}
	err := db.Create(&cat).Error
	assert.NoError(s.t, err)

	payload := &request.SaveCategoryRequest{
		Name:        "Modified Category",
		Description: "Category after modification",
		Icon:        5,
		Color:       "#666666",
	}
	payloadBytes, err := json.Marshal(payload)
	assert.NoError(s.t, err)

	updateReq, err := http.NewRequest(http.MethodPatch, "/api/categories/"+strconv.FormatUint(uint64(cat.ID), 10), bytes.NewBuffer(payloadBytes))
	assert.NoError(s.t, err)
	updateReq.Header.Set("Content-Type", "application/json")
	updateReq.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, updateReq)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var updateRes r.Res[response.Creation[uint]]
	err = json.Unmarshal(rec.Body.Bytes(), &updateRes)
	assert.NoError(s.t, err)
	assert.Equal(s.t, cat.ID, uint(updateRes.Data.ID))

	getReq, err := http.NewRequest(http.MethodGet, "/api/categories/"+strconv.FormatUint(uint64(cat.ID), 10), nil)
	assert.NoError(s.t, err)
	getReq.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec = httptest.NewRecorder()
	s.handler.ServeHTTP(rec, getReq)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var catDetail r.Res[models.Category]
	err = json.Unmarshal(rec.Body.Bytes(), &catDetail)
	assert.NoError(s.t, err)
	assert.Equal(s.t, payload.Name, catDetail.Data.Name)
	assert.Equal(s.t, payload.Description, catDetail.Data.Description)
	assert.Equal(s.t, payload.Icon, catDetail.Data.Icon)
	assert.Equal(s.t, payload.Color, catDetail.Data.Color)
}

func (s *CategoryTestSuite) TestCategoryDeletion() {
	db := (*s.services)[services.DbKey].(*gorm.DB)
	cat := models.Category{Name: "Cat To Delete", Description: "Category to be deleted", Icon: 6, Color: "#777777"}
	err := db.Create(&cat).Error
	assert.NoError(s.t, err)

	deleteReq, err := http.NewRequest(http.MethodDelete, "/api/categories/"+strconv.FormatUint(uint64(cat.ID), 10), nil)
	assert.NoError(s.t, err)
	deleteReq.Header.Set("Authorization", "Bearer "+s.accessToken)
	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, deleteReq)
	assert.Equal(s.t, http.StatusOK, rec.Code)

	var deletedCat models.Category
	err = db.First(&deletedCat, cat.ID).Error
	assert.Error(s.t, err)
	assert.Equal(s.t, gorm.ErrRecordNotFound, err)
}

func TestCategory(t *testing.T) {
	suite.Run(t, new(CategoryTestSuite))
}
