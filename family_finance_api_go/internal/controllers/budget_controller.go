package controllers

import (
	"net/http"
	"strconv"

	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/gin-gonic/gin"

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
)

type BudgetController struct {
}

func NewBudgetController() *BudgetController {
	return &BudgetController{}
}

func (bc *BudgetController) GetBudgets(ctx *gin.Context) {
	f := &filter.BudgetListFilter{}
	ctx.BindQuery(f)

	service := ctx.Request.Context().Value(services.BudgetServiceKey).(*services.BudgetService)
	budgets, err := service.List(f)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Retrieved successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(budgets, &msg))
}

func (bc *BudgetController) GetBudgetByID(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid budget ID"))
		return
	}
	service := ctx.Request.Context().Value(services.BudgetServiceKey).(*services.BudgetService)
	budget, err := service.GetByID(uint(id))
	if err != nil {
		ctx.JSON(http.StatusNotFound, r.NotFound())
		return
	}

	msg := "Successfully retrieved"
	ctx.JSON(http.StatusOK, r.OkWithData(budget, &msg))
}

func (bc *BudgetController) CreateBudget(ctx *gin.Context) {
	payload := &request.SaveBudgetRequest{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid request payload"))
		return
	}

	service := ctx.Request.Context().Value(services.BudgetServiceKey).(*services.BudgetService)
	id, err := service.Create(payload)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusOK, r.Created(id))
}

func (bc *BudgetController) UpdateBudget(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid budget ID"))
		return
	}

	payload := &request.SaveBudgetRequest{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid request payload"))
		return
	}

	service := ctx.Request.Context().Value(services.BudgetServiceKey).(*services.BudgetService)
	updatedID, err := service.Update(uint(id), payload)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Budget updated successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(response.Creation[uint]{ID: updatedID}, &msg))
}

func (bc *BudgetController) DeleteBudget(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid budget ID"))
		return
	}

	service := ctx.Request.Context().Value(services.BudgetServiceKey).(*services.BudgetService)
	err = service.Delete(uint(id))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Budget deleted successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(nil, &msg))
}
