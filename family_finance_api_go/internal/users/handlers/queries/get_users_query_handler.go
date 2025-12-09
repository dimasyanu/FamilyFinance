package queries

import (
	commonModels "github.com/dimasyanu/family-finance-go/internal/common/models"
	"github.com/dimasyanu/family-finance-go/internal/users/models"
	"github.com/dimasyanu/family-finance-go/internal/users/repositories"
)

type GetUsersHandler struct {
	repo *repositories.UserRepository
}

func NewGetUsersHandler(repo *repositories.UserRepository) *GetUsersHandler {
	return &GetUsersHandler{repo: repo}
}

func (h *GetUsersHandler) Handle(filter *models.UserFilter) commonModels.Paginated[models.User] {
	userEntities, total := h.repo.List(filter)
	users, err := models.FromEntities(userEntities)
	if err != nil {
		return commonModels.Paginated[models.User]{}
	}

	return commonModels.Paginated[models.User]{
		Items: users,
		Total: total,
	}
}
