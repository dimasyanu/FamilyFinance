package users

import (
	"net/http"
	"strconv"

	"github.com/dimasyanu/family-finance-go/internal/common/abstractions"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
	"github.com/dimasyanu/family-finance-go/internal/common/utils/mediator"
	"github.com/dimasyanu/family-finance-go/internal/users/handlers"
	queries "github.com/dimasyanu/family-finance-go/internal/users/handlers"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
	"github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
)

type UserController struct {
	abstractions.BaseController
}

func NewUserController(services *map[constants.ServiceKey]any) *UserController {
	return &UserController{
		BaseController: abstractions.BaseController{},
	}
}

func (uc *UserController) GetUsers(c *gin.Context) {
	// Parse query parameters into filter
	f := models.NewUserFilter()
	so := commonModels.NewSortingOption()
	_ = c.BindQuery(f)
	_ = c.BindQuery(so)

	// Create and send the query via Mediator
	query := queries.NewGetUsersHandler(f, so)
	users, err := mediator.Send(c, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Users retrieved successfully"
	c.JSON(http.StatusOK, r.OkWithData(users, &msg))
}

func (uc *UserController) GetUserByID(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid user ID"))
		return
	}

	query := queries.NewGetUserByIdHandler(valueobjects.UserId(id))
	user, err := mediator.Send(ctx, query)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}
	if user == nil {
		ctx.JSON(http.StatusNotFound, r.NotFound())
		return
	}

	msg := "Successfully retrieved"
	ctx.JSON(http.StatusOK, r.OkWithData(user, &msg))
}

func (uc *UserController) GetUserByUsername(ctx *gin.Context) {
	username := ctx.Param("username")

	query := queries.NewGetUserByUsernameHandler(username)
	user, err := mediator.Send(ctx, query)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}
	if user == nil {
		ctx.JSON(http.StatusNotFound, r.NotFound())
		return
	}

	msg := "Successfully retrieved"
	ctx.JSON(http.StatusOK, r.OkWithData(user, &msg))
}

func (uc *UserController) CreateUser(ctx *gin.Context) {
	payload := &handlers.CreateUserHandler[valueobjects.UserId]{}
	if err := ctx.ShouldBindJSON(payload); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}
	if payload.Password != payload.PasswordRepeat {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Passwords do not match"))
		return
	}

	var command contracts.IRequestHandler[valueobjects.UserId] = payload
	result, err := mediator.Send(ctx, command)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	ctx.JSON(http.StatusCreated, r.Created(result))
}

func (uc *UserController) UpdateUser(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid user ID"))
		return
	}

	handler := handlers.NewUpdateUserHandler(valueobjects.UserId(id))
	if err := ctx.ShouldBindJSON(handler); err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest(err.Error()))
		return
	}

	user, err := mediator.Send(ctx, handler)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.InternalServerError())
		return
	}

	msg := "Updated successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(user, &msg))
}

func (uc *UserController) TrashUser(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid user ID"))
		return
	}

	cmd := handlers.NewTrashUserHandler(valueobjects.UserId(id))
	_, err = mediator.Send(ctx, cmd)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Trashed successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(nil, &msg))
}

func (uc *UserController) RestoreUser(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, r.BadRequest("Invalid user ID"))
		return
	}

	cmd := handlers.NewRestoreUserHandler(valueobjects.UserId(id))
	_, err = mediator.Send(ctx, cmd)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, r.InternalServerError())
		return
	}

	msg := "Restored successfully"
	ctx.JSON(http.StatusOK, r.OkWithData(nil, &msg))
}
