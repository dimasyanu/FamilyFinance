package common

import (
	"fmt"
	"log"

	"github.com/dimasyanu/family-finance-go/config"
	accountEntities "github.com/dimasyanu/family-finance-go/internal/accounts/entities"
	accountRepos "github.com/dimasyanu/family-finance-go/internal/accounts/repositories"
	budgetEntities "github.com/dimasyanu/family-finance-go/internal/budgets/entities"
	budgetRepos "github.com/dimasyanu/family-finance-go/internal/budgets/repositories"
	categoryEntities "github.com/dimasyanu/family-finance-go/internal/categories/entities"
	categoryRepos "github.com/dimasyanu/family-finance-go/internal/categories/repositories"
	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	contracts "github.com/dimasyanu/family-finance-go/internal/common/contracts"
	"github.com/dimasyanu/family-finance-go/internal/common/routes"
	"github.com/dimasyanu/family-finance-go/internal/common/tools"
	roleEntities "github.com/dimasyanu/family-finance-go/internal/roles/entities"
	roleModels "github.com/dimasyanu/family-finance-go/internal/roles/models"
	roleRepos "github.com/dimasyanu/family-finance-go/internal/roles/repositories"
	transactionEntities "github.com/dimasyanu/family-finance-go/internal/transactions/entities"
	transactionRepos "github.com/dimasyanu/family-finance-go/internal/transactions/repositories"
	userEntities "github.com/dimasyanu/family-finance-go/internal/users/entities"
	userRepos "github.com/dimasyanu/family-finance-go/internal/users/repositories"
	userVobj "github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
	"github.com/dimasyanu/family-finance-go/pkg/dbengines"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SeedDatabase(svc *map[constants.ServiceKeys]any) {
	// Create default roles
	roleRepo := (*svc)[constants.RoleRepositoryKey].(*roleRepos.RoleRepository)
	for _, roleName := range roleModels.DefaultRoles {
		roleRepo.CreateIfNotExists(roleName)
		fmt.Printf("Creating role: %s\n", roleName)
	}
	superAdminRole, err := roleRepo.GetByName(roleModels.RoleSuperAdmin)
	if err != nil {
		panic(err.Error())
	}

	// Ensure super admin exists
	userRepo := (*svc)[constants.UserRepositoryKey].(*userRepos.UserRepository)
	hashingSvc := (*svc)[constants.HashingServiceKey].(contracts.IHashingService)
	admin := userRepo.GetByUsername("superadmin")
	passordHash, err := hashingSvc.Hash("supersecretpassword")
	if err != nil {
		panic(err)
	}

	if admin == nil {
		userRepo.Create(&userEntities.UserEntity{
			Name:         "Super Admin",
			Username:     "superadmin",
			EmailAddress: userVobj.NewEmailAddress("admin@mail.com"),
			Roles:        []*roleEntities.RoleEntity{superAdminRole},
			PasswordHash: passordHash,
		})
	}
}

func GetServices(db *gorm.DB) *map[constants.ServiceKeys]any {
	services := &map[constants.ServiceKeys]any{
		constants.DbKey: db,

		constants.AccountRepositoryKey:     accountRepos.NewAccountRepository(db),
		constants.BudgetRepositoryKey:      budgetRepos.NewBudgetRepository(db),
		constants.CategoryRepositoryKey:    categoryRepos.NewCategoryRepository(db),
		constants.RoleRepositoryKey:        roleRepos.NewRoleRepository(db),
		constants.TransactionRepositoryKey: transactionRepos.NewTransactionRepository(db),
		constants.UserRepositoryKey:        userRepos.NewUserRepository(db),
	}
	(*services)[constants.MediatorServiceKey] = tools.NewMediator(func(b *tools.MediatorBuilder) {
		b.UseServiceProviders(services)
		b.Register()
	})
	return services
}

func InitializeServices(envFile ...string) (*gin.Engine, *map[constants.ServiceKeys]any) {
	// Load configuration
	config := config.LoadConfig(envFile...)

	// Initialize database
	db, err := dbengines.NewSQLiteEngine(config.DBName)
	if err != nil {
		return nil, nil
	}

	// Migrate the schema
	err = db.AutoMigrate(
		&accountEntities.AccountEntity{},
		&budgetEntities.BudgetEntity{},
		&categoryEntities.CategoryEntity{},
		&roleEntities.RoleEntity{},
		&transactionEntities.TransactionEntity{},
		&userEntities.UserEntity{},
	)
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// Initialize routes
	routes := routes.SetupAPIRoutes(func() map[constants.ServiceKeys]any {
		return *GetServices(db)
	})

	svc := GetServices(db)
	SeedDatabase(svc)
	return routes, svc
}
