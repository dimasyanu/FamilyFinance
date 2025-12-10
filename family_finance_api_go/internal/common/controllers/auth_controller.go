package controllers

import (
	"net/http"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/dimasyanu/family-finance-go/internal/users/repositories"
	"github.com/dimasyanu/family-finance-go/pkg/models/response"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
)

type AuthController struct {
}

func NewAuthController(services *map[constants.ServiceKey]any) *AuthController {
	return &AuthController{}
}

func (c *AuthController) Login(ctx *gin.Context) {
	service := ctx.Request.Context().Value(constants.UserRepositoryKey).(*repositories.UserRepository)

	payload := &struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid username or password"))
		return
	}

	token, err := service.Login(payload.Username, payload.Password)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, r.BadRequest(err.Error()))
		return
	}

	msg := "Login successful"
	ctx.JSON(http.StatusOK, r.OkWithData(response.LoginResponse{Token: token}, &msg))
}

func (c *AuthController) Register(ctx *gin.Context) {
	msg := "Registration successful"
	ctx.JSON(http.StatusOK, r.OkWithData(nil, &msg))
}

func (c *AuthController) Status(ctx *gin.Context) {
	service := ctx.Request.Context().Value(services.AuthServiceKey).(*services.AuthService)
	ctx.JSON(http.StatusOK, r.OkWithData(service.Status(), nil))
}
