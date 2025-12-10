package categories

import (
	"net/http"
	"strconv"

	"github.com/dimasyanu/family-finance-go/internal/categories/models"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/tools"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
)

type CategoryController struct {
	mediator *tools.Mediator
}

func NewCategoryController(services *map[constants.ServiceKey]any) *CategoryController {
	mediator := (*services)[constants.MediatorServiceKey].(*tools.Mediator)
	return &CategoryController{
		mediator: mediator,
	}
}

func (uc *CategoryController) getService(ctx *gin.Context) *services.CategoryService {
	return ctx.Request.Context().Value(services.CategoryServiceKey).(*services.CategoryService)
}

func (uc *CategoryController) GetCategories(ctx *gin.Context) {
	payload := &models.CategoryListFilter{}
	_ = ctx.BindQuery(payload)

	service := uc.getService(ctx)
	result, err := service.List(payload)
	if err != nil {
		ctx.JSON(500, gin.H{"error": err.Error()})
		return
	}

	msg := "Retrieved successfully"
	ctx.JSON(200, r.OkWithData(result, &msg))
}

func (uc *CategoryController) GetCategory(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid category ID"))
		return
	}

	service := uc.getService(ctx)
	category, err := service.GetByID(uint(id))
	if err != nil {
		ctx.JSON(http.StatusNotFound, r.NotFound())
		return
	}

	msg := "Successfully retrieved"
	ctx.JSON(http.StatusOK, r.OkWithData(category, &msg))
}

func (uc *CategoryController) CreateCategory(ctx *gin.Context) {
	payload := &request.SaveCategoryRequest{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	// If UserId is not provided, get it from the JWT token
	if payload.UserId == 0 {
		userIdInterface, exists := ctx.Get("user_id")
		if !exists {
			ctx.JSON(http.StatusUnauthorized, r.Unauthorized())
			return
		}
		userId, ok := userIdInterface.(uint)
		if !ok {
			ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
			return
		}
		payload.UserId = userId
	}

	service := uc.getService(ctx)
	id, err := service.Create(payload)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusCreated, r.Created(id))
}

func (uc *CategoryController) UpdateCategory(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid category ID"))
		return
	}

	payload := &request.SaveCategoryRequest{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	service := uc.getService(ctx)
	updatedId, err := service.Update(uint(id), payload)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Category updated successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(&response.Creation[uint]{Id: updatedId}, &msg))
}

func (uc *CategoryController) DeleteCategory(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid category ID"))
		return
	}
	service := uc.getService(ctx)
	err = service.Delete(uint(id))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Category deleted successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(nil, &msg))
}
