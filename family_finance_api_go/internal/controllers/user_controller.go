package controllers

import (
	"net/http"
	"strconv"

	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/models/response"
	"github.com/dimasyanu/family-finance-go/internal/services"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
)

type UserController struct {
}

func NewUserController() *UserController {
	return &UserController{}
}

func (c *UserController) getService(ctx *gin.Context) *services.UserService {
	return ctx.Request.Context().Value(services.UserServiceKey).(*services.UserService)
}

func (uc *UserController) GetUsers(c *gin.Context) {
	f := &filter.UserListFilter{
		ListFilter: filter.ListFilter{
			Limit:  10,
			Offset: 0,
		},
	}
	_ = c.BindQuery(f)

	service := uc.getService(c)
	users := service.List(f)

	msg := "Users retrieved successfully"
	c.JSON(http.StatusOK, r.OkWithData(users, &msg))
}

func (uc *UserController) GetUserByID(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid user ID"))
		return
	}

	service := uc.getService(ctx)
	user := service.GetUserByID(int64(id))
	if user == nil {
		ctx.JSON(http.StatusNotFound, r.NotFound())
		return
	}

	msg := "Successfully retrieved"
	ctx.JSON(http.StatusOK, r.OkWithData(user, &msg))
}

func (uc *UserController) CreateUser(ctx *gin.Context) {
	payload := &request.CreateUserRequest{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	service := uc.getService(ctx)
	result := service.CreateUser(payload)

	ctx.JSON(http.StatusCreated, r.Created(result))
}

func (uc *UserController) UpdateUser(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid user ID"))
		return
	}
	service := uc.getService(ctx)

	payload := &request.UpdateUserRequest{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	updateId, err := service.UpdateUser(int64(id), payload)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.InternalServerError())
		return
	}

	msg := "Updated successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(&response.Creation[int64]{
		ID: updateId,
	}, &msg))
}

func (uc *UserController) DeleteUser(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid user ID"))
		return
	}

	service := uc.getService(ctx)
	err = service.DeleteUser(int64(id))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Deleted successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(nil, &msg))
}
