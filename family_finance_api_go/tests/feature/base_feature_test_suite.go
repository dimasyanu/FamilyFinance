package feature

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/dimasyanu/family-finance-go/internal/handler"
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
)

type BaseFeatureTestSuite struct {
	suite.Suite
	handler     *gin.Engine
	t           *testing.T
	services    *map[services.ServiceKey]any
	roles       *[]models.Role
	accessToken string
}

func (s *BaseFeatureTestSuite) SetupTest() {
	// Manually set environment variables for testing
	os.Setenv("DB_ENGINE", "inmemory")
	os.Setenv("JWT_SECRET", "super_secret_jwt_key_for_testing_purposes_only")

	s.handler, s.services = handler.InitializeServices()
	s.t = s.T()

	roleService := (*s.services)[services.RoleServiceKey].(*services.RoleService)
	roles, err := roleService.ListAllRoles()
	assert.NoError(s.t, err)
	s.roles = roles

	// Login as super admin
	payloadBytes, err := json.Marshal(map[string]string{
		"username": "superadmin",
		"password": "supersecretpassword",
	})
	assert.NoError(s.t, err)
	loginReq, err := http.NewRequest(http.MethodPost, "/api/auth/login", bytes.NewBuffer(payloadBytes))
	assert.NoError(s.t, err)
	loginRec := httptest.NewRecorder()
	s.handler.ServeHTTP(loginRec, loginReq)
	loginRes := r.Res[response.LoginResponse]{}
	err = json.Unmarshal(loginRec.Body.Bytes(), &loginRes)
	assert.NoError(s.t, err)
	s.accessToken = loginRes.Data.Token
}

func (s *BaseFeatureTestSuite) TearDownTest() {
	// Clean up environment variables
	os.Unsetenv("DB_ENGINE")
	os.Unsetenv("JWT_SECRET")

	// Clean up database
	db := (*s.services)[services.DbKey].(*gorm.DB)

	db.Exec("DROP TABLE accounts;")
	db.Exec("DROP TABLE budgets;")
	db.Exec("DROP TABLE categories;")
	db.Exec("DROP TABLE roles;")
	db.Exec("DROP TABLE transactions;")
	db.Exec("DROP TABLE users;")
	db.Exec("DROP TABLE user_roles;")

	// Reset services and handler
	s.handler = nil
	s.services = nil
	s.t = nil
}
