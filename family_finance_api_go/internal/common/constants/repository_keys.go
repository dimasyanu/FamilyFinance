package constants

type ServiceKeys string

const (
	DbKey ServiceKeys = "db"

	HashingServiceKey  ServiceKeys = "hashingService"
	MediatorServiceKey ServiceKeys = "mediatorService"

	UserRepositoryKey        ServiceKeys = "userRepository"
	AccountRepositoryKey     ServiceKeys = "accountRepository"
	BudgetRepositoryKey      ServiceKeys = "budgetRepository"
	AuthRepositoryKey        ServiceKeys = "authRepository"
	CategoryRepositoryKey    ServiceKeys = "categoryRepository"
	RoleRepositoryKey        ServiceKeys = "roleRepository"
	TransactionRepositoryKey ServiceKeys = "transactionRepository"
)
