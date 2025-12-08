package controllers

import (
	"net/http"
	"strconv"

	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
)

type AccountController struct {
}

func NewAccountController() *AccountController {
	return &AccountController{}
}

func (ac *AccountController) getService(ctx *gin.Context) *services.AccountService {
	return ctx.Request.Context().Value(services.AccountServiceKey).(*services.AccountService)
}

func (ac *AccountController) GetAccounts(ctx *gin.Context) {
	payload := &filter.AccountListFilter{}
	_ = ctx.BindQuery(payload)

	service := ac.getService(ctx)

	result, err := service.List(payload)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Retrieved successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(result, &msg))
}

func (ac *AccountController) GetAccountByID(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid category ID"))
		return
	}
	service := ac.getService(ctx)

	account, err := service.GetByID(uint(id))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Retrieved successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(account, &msg))
}

func (ac *AccountController) CreateAccount(ctx *gin.Context) {
	payload := &models.Account{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	service := ac.getService(ctx)

	id, err := service.Create(payload)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusCreated, r.Created(id))
}

func (ac *AccountController) UpdateAccount(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid account ID"))
		return
	}

	payload := &request.SaveAccountRequest{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	service := ac.getService(ctx)

	updateId, err := service.Update(uint(id), payload)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Updated successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(response.Creation[uint]{ID: updateId}, &msg))
}

func (ac *AccountController) DeleteAccount(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid account ID"))
		return
	}
	service := ac.getService(ctx)

	err = service.Delete(uint(id))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Deleted successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(nil, &msg))
}
