package unit

import (
	"os"
	"testing"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/handler"
	"github.com/dimasyanu/family-finance-go/internal/models/request/filter"
	"github.com/dimasyanu/family-finance-go/internal/roles/models"
	"github.com/dimasyanu/family-finance-go/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type RoleUnitTestSuite struct {
	suite.Suite
	handler  *gin.Engine
	t        *testing.T
	services *map[constants.ServiceKey]any
}

func (s *RoleUnitTestSuite) SetupTest() {
	// Manually set environment variables for testing
	os.Setenv("DB_ENGINE", "inmemory")
	os.Setenv("JWT_SECRET", "super_secret_jwt_key_for_testing_purposes_only")

	s.handler, s.services = handler.InitializeServices()
	s.t = s.T()
}

func (s *RoleUnitTestSuite) TearDownTest() {
	// Clean up environment variables
	os.Unsetenv("DB_ENGINE")
	os.Unsetenv("JWT_SECRET")

	// Clean up database
	db := (*s.services)[constants.DbKey].(*gorm.DB)

	db.Exec("DELETE FROM users;")
	db.Exec("DELETE FROM roles;")
	db.Exec("DELETE FROM user_roles;")

	// Reset services and handler
	s.handler = nil
	s.services = nil
	s.t = nil
}

func (s *RoleUnitTestSuite) TestListRoles() {
	roleService := (*s.services)[constants.RoleRepositoryKey].(*services.RoleService)

	roles, err := roleService.ListRoles(nil)
	assert.NoError(s.t, err)
	assert.Equal(s.t, int64(3), roles.Total, "Total roles count should be 3")
	assert.GreaterOrEqual(s.t, 3, len(*roles.Items), "There should be at least 3 default roles")

	roles, err = roleService.ListRoles(&filter.RoleListFilter{
		ListFilter: filter.ListFilter{
			Limit:  2,
			Offset: 0,
		},
	})
	assert.NoError(s.t, err)
	assert.Equal(s.t, int64(3), roles.Total, "Total roles count with pagination should be 2")
	assert.GreaterOrEqual(s.t, 2, len(*roles.Items), "There should be at least 2 roles matching the filter")

	roles, err = roleService.ListRoles(&filter.RoleListFilter{
		ListFilter: filter.ListFilter{
			Limit:  5,
			Offset: 0,
		},
		Name: "admin",
	})
	assert.NoError(s.t, err)
	assert.Equal(s.t, int64(2), roles.Total, "Total roles count with name filter 'admin' should be 2: Admin and SuperAdmin")
	assert.GreaterOrEqual(s.t, 2, len(*roles.Items), "There should be at least 2 roles matching the name filter")
}

func (s *RoleUnitTestSuite) TestRoleCreation() {
	roleService := (*s.services)[constants.RoleRepositoryKey].(*services.RoleService)

	roles, err := roleService.ListAllRoles()
	assert.NoError(s.t, err)
	assert.GreaterOrEqual(s.t, len(*roles), 3, "There should be at least 3 default roles")

	newRole := &models.Role{Name: "test-role"}
	err = roleService.CreateRole(newRole)
	assert.NoError(s.t, err, "Creating a new role should not produce an error")

	retrievedRole, err := roleService.GetRoleByName(newRole.Name)
	assert.NoError(s.t, err, "Retrieving the newly created role should not produce an error")
	assert.Equal(s.t, newRole.Name, retrievedRole.Name, "The retrieved role name should match the created role name")

	roles, err = roleService.ListAllRoles()
	assert.NoError(s.t, err)
	assert.GreaterOrEqual(s.t, len(*roles), 4, "There should be at least 4 roles after adding a new one")
}

func (s *RoleUnitTestSuite) TestRoleUpdateAndDelete() {
	roleService := (*s.services)[constants.RoleRepositoryKey].(*services.RoleService)

	newRole := &models.Role{Name: "new-role"}
	err := roleService.CreateRole(newRole)
	assert.NoError(s.t, err, "Creating a new role should not produce an error")

	retrievedRole, err := roleService.GetRoleByName(newRole.Name)
	assert.NoError(s.t, err, "Retrieving the newly created role should not produce an error")
	assert.Equal(s.t, newRole.Name, retrievedRole.Name, "The retrieved role name should match the created role name")

	// Update role name
	retrievedRole.Name = "updated-role"
	err = roleService.UpdateRole(retrievedRole)
	assert.NoError(s.t, err, "Updating the role should not produce an error")

	// Verify update
	updatedRole, err := roleService.GetRoleByID(int64(retrievedRole.ID))
	assert.NoError(s.t, err, "Retrieving the updated role should not produce an error")
	assert.Equal(s.t, "updated-role", updatedRole.Name, "The role name should be updated")

	findOldRole, err := roleService.GetRoleByName("new-role")
	assert.Error(s.t, err, "Retrieving the old role name should produce an error")
	assert.Nil(s.t, findOldRole, "The old role name should not exist")

	// Delete role
	err = roleService.DeleteRole(int64(updatedRole.ID))
	assert.NoError(s.t, err, "Deleting the role should not produce an error")

	// Verify deletion
	deletedRole, err := roleService.GetRoleByID(int64(updatedRole.ID))
	assert.Error(s.t, err, "Retrieving the deleted role should produce an error")
	assert.Nil(s.t, deletedRole, "The deleted role should not exist")
}

func TestRoleUnitFeatures(t *testing.T) {
	suite.Run(t, new(RoleUnitTestSuite))
}
