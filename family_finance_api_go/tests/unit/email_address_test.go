package unit

import (
	"testing"

	"github.com/dimasyanu/family-finance-go/internal/users/valueobjects"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
)

type EmailAddressUnitTestSuite struct {
	suite.Suite
	t *testing.T
}

func (s *EmailAddressUnitTestSuite) TestValidEmailAddress() {
	emailAddressStr := "dimasyanu15@gmail.com"
	emailAddress := valueobjects.NewEmailAddress(emailAddressStr)
	valid := emailAddress.Validate()
	assert.True(s.t, valid)
}
