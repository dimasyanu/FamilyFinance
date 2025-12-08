package services

import (
	"fmt"
	"os"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/dimasyanu/family-finance-go/internal/repositories"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	userRepo *repositories.UserRepository
}

func NewAuthService(userRepo *repositories.UserRepository) *AuthService {
	return &AuthService{userRepo: userRepo}
}

// Login user and return JWT token
func (as *AuthService) Login(username, password string) (string, error) {
	// Get the user
	user := as.userRepo.GetByUsername(username)
	if user == nil {
		return "", fmt.Errorf("invalid username or password")
	}

	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
	if err != nil {
		return "", fmt.Errorf("invalid username or password")
	}

	// Create a newToken
	newToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"username": username,
		"eol":      jwt.TimeFunc().Add(time.Hour).Unix(), // Token expiration time, one hour
	})

	// Generate JWT token or session management
	secret := os.Getenv("JWT_SECRET")
	tokenString, err := newToken.SignedString([]byte(secret))
	if err != nil {
		return "", fmt.Errorf("failed to generate token")
	}

	return tokenString, nil
}

func (as *AuthService) Register(username, password string) (string, error) {
	// Placeholder logic for user registration
	return "Registered user " + username, nil
}

func (as *AuthService) Status() string {
	return "Auth service is running"
}
