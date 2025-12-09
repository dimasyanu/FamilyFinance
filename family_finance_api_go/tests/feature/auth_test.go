package feature

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/dimasyanu/family-finance-go/internal/handler"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
)

type AuthTestSuite struct {
	suite.Suite
	handler  *gin.Engine
	t        *testing.T
	services *map[services.ServiceKey]any
}

func (suite *AuthTestSuite) SetupTest() {
	// Manually set environment variables for testing
	os.Setenv("DB_ENGINE", "inmemory")
	os.Setenv("JWT_SECRET", "super_secret_jwt_key_for_testing_purposes_only")

	suite.handler, suite.services = handler.InitializeServices()
	suite.t = suite.T()
}

func (suite *AuthTestSuite) TestWithoutAuthorizationHeader() {
	req, err := http.NewRequest(http.MethodGet, "/api/users", nil)
	if err != nil {
		suite.t.Fatal(err)
	}
	rec := httptest.NewRecorder()
	suite.handler.ServeHTTP(rec, req)

	assert.Equal(suite.t, http.StatusUnauthorized, rec.Code)
	assert.Equal(suite.t, `{"success":false,"message":"Unauthorized"}`, rec.Body.String())
}

func (suite *AuthTestSuite) TestWithInvalidAuthorizationHeader() {
	req, err := http.NewRequest(http.MethodGet, "/api/users", nil)
	if err != nil {
		suite.t.Fatal(err)
	}
	req.Header.Set("Authorization", "Bearer valid_token")
	rec := httptest.NewRecorder()
	suite.handler.ServeHTTP(rec, req)

	assert.Equal(suite.t, http.StatusUnauthorized, rec.Code)
	assert.Contains(suite.t, rec.Body.String(), `"success":false`)
}

func (suite *AuthTestSuite) TestWithValidAuthorizationHeader() {

	// Login as super admin
	loginPayload := map[string]string{
		"username": "superadmin",
		"password": "supersecretpassword",
	}
	payloadBytes, err := json.Marshal(loginPayload)
	if err != nil {
		suite.t.Fatalf("failed to marshal login payload: %v", err)
	}
	loginReq, err := http.NewRequest(http.MethodPost, "/api/auth/login", bytes.NewBuffer(payloadBytes))
	if err != nil {
		suite.t.Fatal(err)
	}
	loginReq.Header.Set("Content-Type", "application/json")
	if err != nil {
		suite.t.Fatal(err)
	}
	loginRec := httptest.NewRecorder()
	suite.handler.ServeHTTP(loginRec, loginReq)

	assert.Equal(suite.t, http.StatusOK, loginRec.Code)

	// Extract token from loginRec.Body (omitted for brevity)
	var loginResp r.Res[response.LoginResponse]
	body := loginRec.Body.String()
	if err := json.Unmarshal(loginRec.Body.Bytes(), &loginResp); err != nil {
		suite.t.Fatalf("failed to unmarshal login response: %v", err)
	}
	assert.NotEmpty(suite.t, loginResp.Data.Token)
	assert.NotContains(suite.t, body, `"success":false`)

	req, err := http.NewRequest(http.MethodGet, "/api/users", nil)
	if err != nil {
		suite.t.Fatal(err)
	}
	req.Header.Set("Authorization", "Bearer "+loginResp.Data.Token)
	rec := httptest.NewRecorder()
	suite.handler.ServeHTTP(rec, req)

	assert.Equal(suite.t, http.StatusOK, rec.Code)
	assert.Contains(suite.t, rec.Body.String(), `"success":true`)
}

func (suite *AuthTestSuite) TearDownTest() {
	suite.handler = nil
	suite.t = nil
}

func TestAuth(t *testing.T) {
	suite.Run(t, new(AuthTestSuite))
}
