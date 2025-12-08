package request

type UpdateUserRequest struct {
	Name string `json:"name" binding:"required"`
}
