package middlewares

import (
	"net/http"
	"os"

	"github.com/dgrijalva/jwt-go"
	"github.com/dimasyanu/family-finance-go/internal/services"
	r "github.com/dimasyanu/family-finance-go/pkg/models/response"
	"github.com/gin-gonic/gin"
)

// JWT authentication middleware
func JwtAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		bearer := c.GetHeader("Authorization")
		if bearer == "" {
			c.JSON(http.StatusUnauthorized, r.Unauthorized())
			c.Abort()
			return
		}

		// Validate the token (omitted for brevity)
		err := validateToken(c, bearer[len("Bearer "):])
		if err != nil {
			c.JSON(http.StatusUnauthorized, r.Unauthorized())
			c.Abort()
			return
		}

		// If token is valid, proceed to the next handler
		c.Next()
	}
}

func validateToken(c *gin.Context, token string) error {
	secret := os.Getenv("JWT_SECRET")
	t, err := jwt.Parse(token, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(secret), nil
	})
	if err != nil {
		return err
	}

	userService := c.Request.Context().Value(services.UserServiceKey).(*services.UserService)
	raw := t.Claims.(jwt.MapClaims)

	// Verify user exists
	user := userService.GetByUsername(raw["username"].(string))
	if user == nil {
		return jwt.ErrInvalidKey
	}

	// Check token expiration
	eol := int64(raw["eol"].(float64))
	if eol < (jwt.TimeFunc().Unix()) {
		return jwt.ErrSignatureInvalid
	}

	// Set user info in context
	c.Set("user_id", uint(user.ID))

	return nil
}
