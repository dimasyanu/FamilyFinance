package accounts

import (
	"net/http"
	"strconv"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/tools"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/dimasyanu/family-finance-go/pkg/models/response"

	"github.com/dimasyanu/family-finance-go/internal/accounts/models"

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
)

type AccountController struct {
	mediator *tools.Mediator
}

func NewAccountController(services *map[constants.ServiceKey]any) *AccountController {
	mediator := (*services)[constants.MediatorServiceKey].(*tools.Mediator)
	return &AccountController{
		mediator: mediator,
	}
}

func (ac *AccountController) getService(ctx *gin.Context) *services.AccountService {
	return ctx.Request.Context().Value(services.AccountServiceKey).(*services.AccountService)
}

func (ac *AccountController) GetAccounts(ctx *gin.Context) {
	payload := &models.AccountListFilter{}
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
	ctx.JSON(http.StatusOK, r.OkWithData(response.Creation[uint]{Id: updateId}, &msg))
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
