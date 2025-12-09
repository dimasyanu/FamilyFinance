package contracts

type IHashingService interface {
	Hash(password string) (string, error)
	Validate(password string, hashed string) bool
}
