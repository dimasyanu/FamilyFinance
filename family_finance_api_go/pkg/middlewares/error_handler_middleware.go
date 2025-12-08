package middlewares

import (
	"net/http"

	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
)

// Error handling middleware
func ErrorHandlerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		if len(c.Errors) > 0 {
			c.JSON(http.StatusInternalServerError, r.InternalServerError())
		}

		if c.Writer.Status() == http.StatusNotFound {
			c.JSON(http.StatusNotFound, r.NotFound())
		}
	}
}
