package abstractions

import (
	"os"

	"github.com/gin-gonic/gin"
)

type BaseController struct {
}

func (c *BaseController) GetUser(ctx *gin.Context) (uint, error) {
	userId := ctx.GetUint("user_id")
	if userId <= 0 {
		return 0, os.ErrExist
	}
	return userId, nil
}
