package handler

import (
	"log"

	"github.com/dimasyanu/family-finance-go/config"
	"github.com/dimasyanu/family-finance-go/internal/models"
	"github.com/dimasyanu/family-finance-go/internal/models/request"
	"github.com/dimasyanu/family-finance-go/internal/repositories"
	"github.com/dimasyanu/family-finance-go/internal/routers"
	"github.com/dimasyanu/family-finance-go/internal/services"
	userEntities "github.com/dimasyanu/family-finance-go/internal/users/entities"
	"github.com/dimasyanu/family-finance-go/pkg/dbengines"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SeedDatabase(svc *map[services.ServiceKey]any) {
	// Create default roles
	roleService := (*svc)[services.RoleServiceKey].(*services.RoleService)
	roleService.CreateDefaultRoles()
	superAdminRole, err := roleService.GetRoleByName(models.RoleSuperAdmin)
	if err != nil {
		panic(err.Error())
	}

	// Ensure super admin exists
	userService := (*svc)[services.UserServiceKey].(*services.UserService)
	admin := userService.GetByUsername("superadmin")
	if admin == nil {
		userService.CreateUser(&request.CreateUserRequest{
			Name:     "Super Admin",
			Username: "superadmin",
			Email:    "admin@mail.com",
			Roles:    []int{int(superAdminRole.ID)},
			Password: "supersecretpassword",
		})
	}
}

func GetServices(db *gorm.DB) map[services.ServiceKey]any {
	accountRepo := repositories.NewAccountRepository(db)
	budgetRepo := repositories.NewBudgetRepository(db)
	categoryRepo := repositories.NewCategoryRepository(db)
	roleRepo := repositories.NewRoleRepository(db)
	transactionRepo := repositories.NewTransactionRepository(db)
	userRepo := repositories.NewUserRepository(db)

	return map[services.ServiceKey]any{
		services.DbKey:                 db,
		services.AccountServiceKey:     services.NewAccountService(accountRepo),
		services.BudgetServiceKey:      services.NewBudgetService(budgetRepo),
		services.AuthServiceKey:        services.NewAuthService(userRepo),
		services.CategoryServiceKey:    services.NewCategoryService(categoryRepo),
		services.RoleServiceKey:        services.NewRoleService(roleRepo),
		services.TransactionServiceKey: services.NewTransactionService(transactionRepo),
		services.UserServiceKey:        services.NewUserService(userRepo),
	}
}

func NewHandler(envFile ...string) (*gin.Engine, *map[services.ServiceKey]any) {
	// Load configuration
	config := config.LoadConfig(envFile...)

	// Initialize database
	db, err := dbengines.NewSQLiteEngine(config.DBName)
	if err != nil {
		return nil, nil
	}

	// Migrate the schema
	err = db.AutoMigrate(
		&models.Account{},
		&models.Budget{},
		&models.Category{},
		&models.Role{},
		&models.Transaction{},
		&userEntities.UserEntity{},
	)
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// Initialize routes
	routes := routers.SetupAPIRoutes(func() map[services.ServiceKey]any {
		return GetServices(db)
	})

	svc := GetServices(db)
	SeedDatabase(&svc)
	return routes, &svc
}
