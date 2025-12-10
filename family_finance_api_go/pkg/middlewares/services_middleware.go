package middlewares

import (
	"context"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/gin-gonic/gin"
)

func ServicesMiddleware(getServices func() map[constants.ServiceKey]any) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Initialize and attach s to the context here if needed
		s := getServices()
		ctx := c.Request.Context()
		for key, service := range s {
			ctx = context.WithValue(ctx, constants.ServiceKey(key), service)
		}
		c.Request = c.Request.WithContext(ctx)

		// Proceed to the next handler
		c.Next()
	}
}
