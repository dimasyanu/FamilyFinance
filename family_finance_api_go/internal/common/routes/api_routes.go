package routes

import (
	"github.com/dimasyanu/family-finance-go/internal/accounts"
	"github.com/dimasyanu/family-finance-go/internal/budgets"
	"github.com/dimasyanu/family-finance-go/internal/categories"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/controllers"
	"github.com/dimasyanu/family-finance-go/internal/transactions"
	"github.com/dimasyanu/family-finance-go/internal/users"
	"github.com/dimasyanu/family-finance-go/pkg/middlewares"
	"github.com/gin-gonic/gin"
)

func SetupAPIRoutes(servicesFunc func() map[constants.ServiceKeys]any) *gin.Engine {
	services := servicesFunc()
	var (
		authController        *controllers.AuthController         = controllers.NewAuthController(&services)
		accountController     *accounts.AccountController         = accounts.NewAccountController(&services)
		budgetController      *budgets.BudgetController           = budgets.NewBudgetController(&services)
		categoryController    *categories.CategoryController      = categories.NewCategoryController(&services)
		transactionController *transactions.TransactionController = transactions.NewTransactionController(&services)
		profileController     *users.ProfileController            = users.NewProfileController(&services)
		userController        *users.UserController               = users.NewUserController(&services)
	)

	// Initialize Gin router
	routes := gin.Default()
	routes.Use(middlewares.ServicesMiddleware(servicesFunc))
	routes.Use(middlewares.ErrorHandlerMiddleware())

	// Public routes
	api := routes.Group("/api")
	{
		api.GET("/status", authController.Status)

		auth := api.Group("/auth")
		{
			auth.POST("/login", authController.Login)
			auth.POST("/register", authController.Register)
		}

		// Protected routes with auth middleware
		protected := api.Use(middlewares.JwtAuthMiddleware(), middlewares.ErrorHandlerMiddleware())
		{
			protected.GET("/profile", profileController.GetProfile)
			protected.PUT("/profile", profileController.UpdateProfile)

			protected.GET("/users", userController.GetUsers)
			protected.GET("/users/:id", userController.GetUserByID)
			protected.POST("/users", userController.CreateUser)
			protected.PATCH("/users/:id", userController.UpdateUser)
			protected.DELETE("/users/:id", userController.DeleteUser)

			protected.GET("/accounts", accountController.GetAccounts)
			protected.GET("/accounts/:id", accountController.GetAccountByID)
			protected.POST("/accounts", accountController.CreateAccount)
			protected.PATCH("/accounts/:id", accountController.UpdateAccount)
			protected.DELETE("/accounts/:id", accountController.DeleteAccount)

			protected.GET("/budgets", budgetController.GetBudgets)
			protected.GET("/budgets/:id", budgetController.GetBudgetByID)
			protected.POST("/budgets", budgetController.CreateBudget)
			protected.PATCH("/budgets/:id", budgetController.UpdateBudget)
			protected.DELETE("/budgets/:id", budgetController.DeleteBudget)

			protected.GET("/categories", categoryController.GetCategories)
			protected.GET("/categories/:id", categoryController.GetCategory)
			protected.POST("/categories", categoryController.CreateCategory)
			protected.PATCH("/categories/:id", categoryController.UpdateCategory)
			protected.DELETE("/categories/:id", categoryController.DeleteCategory)

			protected.GET("/transactions", transactionController.GetTransactions)
			protected.GET("/transactions/:id", transactionController.GetTransaction)
			protected.POST("/transactions", transactionController.CreateTransaction)
			protected.PATCH("/transactions/:id", transactionController.UpdateTransaction)
			protected.DELETE("/transactions/:id/trash", transactionController.TrashTransaction)
			protected.PATCH("/transactions/:id/restore", transactionController.RestoreTransaction)
			protected.DELETE("/transactions/:id", transactionController.DeleteTransaction)
		}
	}

	return routes
}
