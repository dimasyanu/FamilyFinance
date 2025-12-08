package services

type ServiceKey string

const (
	AccountServiceKey     ServiceKey = "accountService"
	BudgetServiceKey      ServiceKey = "budgetService"
	AuthServiceKey        ServiceKey = "authService"
	CategoryServiceKey    ServiceKey = "categoryService"
	RoleServiceKey        ServiceKey = "roleService"
	TransactionServiceKey ServiceKey = "transactionService"
	UserServiceKey        ServiceKey = "userService"
	DbKey                 ServiceKey = "db"
)
