package transactions

import (
	"errors"
	"net/http"
	"os"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/tools"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/dimasyanu/family-finance-go/internal/transactions/models"
	"github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	abs "github.com/dimasyanu/family-finance-go/pkg/abstractions"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
)

type TransactionController struct {
	mediator *tools.Mediator

	abs.BaseController
}

func NewTransactionController(services *map[constants.ServiceKeys]any) *TransactionController {
	mediator := (*services)[constants.MediatorServiceKey].(*tools.Mediator)
	return &TransactionController{
		mediator: mediator,
	}
}

func (c TransactionController) getService(ctx *gin.Context) *services.TransactionService {
	return ctx.Request.Context().Value(services.TransactionServiceKey).(*services.TransactionService)
}

func (c TransactionController) GetTransactions(ctx *gin.Context) {
	queries := &models.TransactionListFilter{}
	ctx.BindQuery(queries)

	service := c.getService(ctx)
	result, err := service.List(queries)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Retrieved successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(result, &msg))
}

func (c TransactionController) GetTransaction(ctx *gin.Context) {
	id, err := uuid.Parse(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid transaction ID"))
		return
	}

	service := c.getService(ctx)
	result, err := service.GetByID(id)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusOK, r.OkWithData(result, nil))
}

func (c TransactionController) CreateTransaction(ctx *gin.Context) {
	payload := &request.SaveTransactionRequest{}
	err := ctx.ShouldBindJSON(payload)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	userId := ctx.GetUint("user_id")
	service := c.getService(ctx)
	uuid, err := service.Create(payload, userId)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusCreated, r.Created(uuid))
}

func (c TransactionController) UpdateTransaction(ctx *gin.Context) {
	id, err := uuid.Parse(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid transaction ID"))
		return
	}

	payload := &request.SaveTransactionRequest{}
	err = ctx.ShouldBindJSON(payload)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	userId, err := c.GetUser(ctx)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, r.Unauthorized())
		return
	}

	service := c.getService(ctx)
	if err = service.Update(id, payload, userId); err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
	}

	msg := "Updated successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(userId, &msg))
}

func (c TransactionController) TrashTransaction(ctx *gin.Context) {
	id, err := uuid.Parse(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid transaction ID"))
		return
	}

	userId, err := c.GetUser(ctx)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, r.Unauthorized())
		return
	}

	service := c.getService(ctx)
	err = service.Trash(id, userId)
	if err != nil && errors.Is(err, os.ErrExist) {
		ctx.JSON(http.StatusNotFound, r.NotFound())
		return
	} else if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusOK, r.OkWithData(response.Creation[uuid.UUID]{Id: id}, nil))
}

func (c TransactionController) RestoreTransaction(ctx *gin.Context) {
	id, err := uuid.Parse(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid transaction ID"))
		return
	}

	service := c.getService(ctx)
	err = service.Restore(id)
	if err != nil && errors.Is(err, os.ErrExist) {
		ctx.JSON(http.StatusNotFound, r.NotFound())
		return
	} else if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusOK, r.OkWithData(response.Creation[uuid.UUID]{Id: id}, nil))
}

func (c TransactionController) DeleteTransaction(ctx *gin.Context) {
	id, err := uuid.Parse(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid transaction ID"))
		return
	}

	service := c.getService(ctx)
	err = service.Delete(id)
	if err != nil && errors.Is(err, os.ErrExist) {
		ctx.JSON(http.StatusNotFound, r.NotFound())
		return
	} else if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusOK, r.OkWithData(response.Creation[uuid.UUID]{Id: id}, nil))
}
