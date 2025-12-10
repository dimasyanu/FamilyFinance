package constants

type ServiceKey string

const (
	DbKey             ServiceKey = "db"
	AuthorizedUserKey ServiceKey = "authorizedUser"

	HashingServiceKey  ServiceKey = "hashingService"
	MediatorServiceKey ServiceKey = "mediatorService"

	UserRepositoryKey        ServiceKey = "userRepository"
	AccountRepositoryKey     ServiceKey = "accountRepository"
	BudgetRepositoryKey      ServiceKey = "budgetRepository"
	AuthRepositoryKey        ServiceKey = "authRepository"
	CategoryRepositoryKey    ServiceKey = "categoryRepository"
	RoleRepositoryKey        ServiceKey = "roleRepository"
	TransactionRepositoryKey ServiceKey = "transactionRepository"
)
