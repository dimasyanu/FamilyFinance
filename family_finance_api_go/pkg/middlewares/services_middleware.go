package middlewares

import (
	"context"

	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/gin-gonic/gin"
)

func ServicesMiddleware(getServices func() map[services.ServiceKey]any) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Initialize and attach s to the context here if needed
		s := getServices()
		ctx := c.Request.Context()
		for key, service := range s {
			ctx = context.WithValue(ctx, services.ServiceKey(key), service)
		}
		c.Request = c.Request.WithContext(ctx)

		// Proceed to the next handler
		c.Next()
	}
}
