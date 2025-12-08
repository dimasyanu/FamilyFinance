package response

import (
	"github.com/dimasyanu/family-finance-go/internal/models/response"
)

// Standard response structure
type Res[T any] struct {
	Success bool   `json:"success" default:"true"`
	Message string `json:"message,omitempty"`
	Data    *T     `json:"data,omitempty"`
}

// Standard response for successful operations without data
func Ok() *Res[any] {
	return &Res[any]{
		Success: true,
		Message: "Success",
	}
}

// Standard response for successful operations with optional data and message
func OkWithData(data any, message *string) *Res[any] {
	result := Ok()

	if data != nil {
		result.Data = &data
	}

	if message != nil {
		result.Message = *message
	}

	return result
}

// Standard response for resource creation
func Created[T any](id T) *Res[response.Creation[T]] {
	return &Res[response.Creation[T]]{
		Success: true,
		Message: "Resource created successfully",
		Data: &response.Creation[T]{
			ID: id,
		},
	}
}

// Standard response for resource creation with optional data and message
func CreatedWithData(data any, message *string) *Res[any] {
	result := &Res[any]{
		Success: true,
		Message: "Resource created successfully",
	}

	if data != nil {
		result.Data = &data
	}

	if message != nil {
		result.Message = *message
	}

	return result
}

// Standard response for resource not found
func NotFound() *Res[any] {
	return &Res[any]{
		Success: false,
		Message: "Resource not found",
	}
}

// Standard response for bad request with custom message
func BadRequest(message string) *Res[any] {
	return &Res[any]{
		Success: false,
		Message: message,
	}
}

// Standard response for unauthorized access
func Unauthorized() *Res[any] {
	return &Res[any]{
		Success: false,
		Message: "Unauthorized",
	}
}

// Standard response for internal server error
func InternalServerError() *Res[any] {
	return &Res[any]{
		Success: false,
		Message: "Internal server error",
	}
}
