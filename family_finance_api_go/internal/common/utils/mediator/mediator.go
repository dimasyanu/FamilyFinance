package mediator

import (
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
	"github.com/gin-gonic/gin"
)

func Send[TResult any](ctx *gin.Context, request contracts.IRequestHandler[TResult]) (*TResult, error) {
	if err := request.Init(ctx.Request.Context()); err != nil {
		return nil, err
	}
	return request.Handle()
}
