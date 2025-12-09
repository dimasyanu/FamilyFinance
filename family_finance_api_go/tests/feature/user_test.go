package feature

import (
	"bytes"
	"encoding/json"
	"fmt"
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

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
)

type UserTestSuite struct {
	BaseFeatureTestSuite
}

func (s *UserTestSuite) TestUserListing() {
	req, err := http.NewRequest(http.MethodGet, "/api/users?limit=5&offset=0", nil)
	assert.NoError(s.t, err)

	req.Header.Set("Content-Type", "application/json")
	req.Header.Add("Authorization", "Bearer "+s.accessToken)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)

	assert.Equal(s.t, http.StatusOK, rec.Code, "Expected status code %d, got %d", http.StatusOK, rec.Code)

	var listRes r.Res[response.Paginated[models.User]]
	str := rec.Body.String()
	fmt.Print(str)

	err = json.Unmarshal(rec.Body.Bytes(), &listRes)
	assert.NoError(s.t, err)
	assert.Equal(s.t, 1, len((*listRes.Data.Items)))
	assert.GreaterOrEqual(s.t, listRes.Data.Total, int64(1))
}

// Test user creation functionality
func (s *UserTestSuite) TestUserCreation() {
	var role *models.Role
	for _, r := range *s.roles {
		if r.Name == "user" {
			role = &r
		}
	}

	const pass = "supersecretandstrongpassword"
	userPayload := request.CreateUserRequest{
		Name:           "New User",
		Username:       "newuser",
		Email:          "newuser@mail.com",
		Roles:          []int{int(role.ID)},
		Password:       pass,
		PasswordRepeat: pass,
	}
	payloadBytes, err := json.Marshal(userPayload)
	assert.NoError(s.t, err)

	// Create a new user
	req, err := http.NewRequest(http.MethodPost, "/api/users", bytes.NewBuffer(payloadBytes))
	assert.NoError(s.t, err)

	req.Header.Set("Content-Type", "application/json")
	req.Header.Add("Authorization", "Bearer "+s.accessToken)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)

	assert.Equal(s.t, http.StatusCreated, rec.Code, "Expected status code %d, got %d", http.StatusCreated, rec.Code)

	var createdRes r.Res[response.Creation[uint]]
	err = json.Unmarshal(rec.Body.Bytes(), &createdRes)
	assert.NoError(s.t, err)
	assert.GreaterOrEqual(s.t, createdRes.Data.Id, uint(2))

	// Get the new user
	getUser, err := http.NewRequest(http.MethodGet, "/api/users/"+strconv.Itoa(int(createdRes.Data.Id)), nil)
	assert.NoError(s.t, err)
	getUser.Header.Set("Content-Type", "application/json")
	getUser.Header.Add("Authorization", "Bearer "+s.accessToken)

	getRec := httptest.NewRecorder()
	s.handler.ServeHTTP(getRec, getUser)

	assert.Equal(s.t, http.StatusOK, getRec.Code, "Expected status code %d, got %d", http.StatusOK, getRec.Code)

	var createdUser r.Res[models.User]
	err = json.Unmarshal(getRec.Body.Bytes(), &createdUser)
	assert.NoError(s.t, err)
	strBody := getRec.Body.String()
	fmt.Print(strBody)

	assert.Equal(s.t, userPayload.Name, createdUser.Data.Name)
	assert.Equal(s.t, userPayload.Username, createdUser.Data.Username)
	assert.Equal(s.t, userPayload.Email, createdUser.Data.Email)
}

func (s *UserTestSuite) TestUserModification() {
	var role *models.Role
	for _, r := range *s.roles {
		if r.Name == "user" {
			role = &r
		}
	}

	service := (*s.services)[services.UserServiceKey].(*services.UserService)
	const pass = "supersecretandstrongpassword"
	userPayload := request.CreateUserRequest{
		Name:           "New User",
		Username:       "newuser",
		Email:          "newuser@mail.com",
		Roles:          []int{int(role.ID)},
		Password:       pass,
		PasswordRepeat: pass,
	}

	// Create a new user
	id := service.CreateUser(&userPayload)

	// Modify the new user
	userModifyPayload := &request.UpdateUserRequest{
		Name: userPayload.Name + " Modified",
	}

	payloadBytes, err := json.Marshal(userModifyPayload)
	assert.NoError(s.t, err)

	req, err := http.NewRequest(http.MethodPatch, "/api/users/"+strconv.FormatInt(id, 10), bytes.NewBuffer(payloadBytes))
	assert.NoError(s.t, err)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Add("Authorization", "Bearer "+s.accessToken)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)

	assert.Equal(s.t, http.StatusOK, rec.Code, "Expected status code %d, got %d", http.StatusOK, rec.Code)

	// Get the modified user
	getUser, err := http.NewRequest(http.MethodGet, "/api/users/"+strconv.Itoa(int(id)), nil)
	assert.NoError(s.t, err)
	getUser.Header.Set("Content-Type", "application/json")
	getUser.Header.Add("Authorization", "Bearer "+s.accessToken)

	getRec := httptest.NewRecorder()
	s.handler.ServeHTTP(getRec, getUser)

	assert.Equal(s.t, http.StatusOK, getRec.Code, "Expected status code %d, got %d", http.StatusOK, getRec.Code)

	var updatedUser r.Res[models.User]
	err = json.Unmarshal(getRec.Body.Bytes(), &updatedUser)
	assert.NoError(s.t, err)
	strBody := getRec.Body.String()
	fmt.Print(strBody)

	assert.Equal(s.t, userModifyPayload.Name, updatedUser.Data.Name)
}

func (s *UserTestSuite) TestUserDeletion() {
	var role *models.Role
	for _, r := range *s.roles {
		if r.Name == "user" {
			role = &r
		}
	}

	service := (*s.services)[services.UserServiceKey].(*services.UserService)
	const pass = "supersecretandstrongpassword"
	userPayload := request.CreateUserRequest{
		Name:           "New User",
		Username:       "newuser",
		Email:          "newuser@mail.com",
		Roles:          []int{int(role.ID)},
		Password:       pass,
		PasswordRepeat: pass,
	}

	// Create a new user
	id := service.CreateUser(&userPayload)

	// Delete the user
	req, err := http.NewRequest(http.MethodDelete, "/api/users/"+strconv.FormatInt(id, 10), nil)
	assert.NoError(s.t, err)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Add("Authorization", "Bearer "+s.accessToken)

	rec := httptest.NewRecorder()
	s.handler.ServeHTTP(rec, req)

	assert.Equal(s.t, http.StatusOK, rec.Code, "Expected status code %d, got %d", http.StatusOK, rec.Code)

	// Try to get the deleted user
	getUser, err := http.NewRequest(http.MethodGet, "/api/users/"+strconv.Itoa(int(id)), nil)
	assert.NoError(s.t, err)
	getUser.Header.Set("Content-Type", "application/json")
	getUser.Header.Add("Authorization", "Bearer "+s.accessToken)

	getRec := httptest.NewRecorder()
	s.handler.ServeHTTP(getRec, getUser)

	assert.Equal(s.t, http.StatusNotFound, getRec.Code, "Expected status code %d, got %d", http.StatusNotFound, getRec.Code)
}

func TestUser(t *testing.T) {
	suite.Run(t, new(UserTestSuite))
}
