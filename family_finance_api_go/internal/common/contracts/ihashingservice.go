package contracts

type IHashingService interface {
	Hash(password string) string
	Validate(password string, hashed string) bool
}
