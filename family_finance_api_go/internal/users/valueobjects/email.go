package valueobjects

import (
	"regexp"
)

type EmailAddress string

func (email *EmailAddress) Validate() bool {
	regex := regexp.MustCompile(`(?m)^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return regex.MatchString(email)
}

func NewEmailAddress(val string) EmailAddress {
	return val
}
