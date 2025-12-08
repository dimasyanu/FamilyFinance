package request

type CreateUserRequest struct {
	Name           string `json:"name" binding:"required"`
	Username       string `json:"username" binding:"required"`
	Email          string `json:"email" binding:"required,email"`
	Roles          []int  `json:"roles" binding:"required,min=1,dive,gt=0"`
	Password       string `json:"password" binding:"required,min=8"`
	PasswordRepeat string `json:"password_repeat" binding:"required,eqfield=Password"`
}
