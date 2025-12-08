package controllers

import (
	"net/http"
	"os"

	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	abs "github.com/dimasyanu/family-finance-go/pkg/abstractions"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
)

type AuthController struct {
	abs.BaseController
}

func NewAuthController() *AuthController {
	return &AuthController{}
}

func GetUser(ctx *gin.Context) (uint, error) {
	userId := ctx.GetUint("user_id")
	if userId <= 0 {
		return 0, os.ErrExist
	}
	return userId, nil
}

func (c *AuthController) Login(ctx *gin.Context) {
	service := ctx.Request.Context().Value(services.AuthServiceKey).(*services.AuthService)

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
