package users

import (
	"net/http"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/tools"
	"github.com/gin-gonic/gin"
)

type ProfileController struct {
	mediator *tools.Mediator
}

func NewProfileController(services *map[constants.ServiceKeys]any) *ProfileController {
	mediator := (*services)[constants.MediatorServiceKey].(*tools.Mediator)
	return &ProfileController{
		mediator: mediator,
	}
}

func (c *ProfileController) GetProfile(ctx *gin.Context) {
	// Placeholder logic for getting user profile
	ctx.JSON(http.StatusOK, gin.H{
		"message": "User profile retrieved successfully",
	})
}

func (c *ProfileController) UpdateProfile(ctx *gin.Context) {
	// Placeholder logic for updating user profile
	ctx.JSON(http.StatusOK, gin.H{
		"message": "User profile updated successfully",
	})
}
