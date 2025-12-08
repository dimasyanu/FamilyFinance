package unit

import (
	"testing"

	"github.com/dimasyanu/faimly-finance-api/internal/users/valueobjects"
	"github.com/stretchr/testify/suite"
)

type EmailAddressUnitTestSuite struct {
	suite.Suite

	t *testing.T
}

func (s *EmailAddressUnitTestSuite) TestEmailValid() {
	// Arrange
	emailAddressString := valueobjects.NewEmailAddress("admin@mail.com")
	emailaddress.Validate()
}
