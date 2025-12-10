package abstractions

import (
	"context"
	"errors"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
)

type AuthorizedUser struct {
	User *models.User
}

func (au *AuthorizedUser) Init(ctx context.Context) error {
	user, ok := ctx.Value(constants.AuthorizedUserKey).(*models.User)
	if !ok {
		return errors.New("Unauthorized")
	}
	au.User = user
	return nil
}
