package valueobjects

import "regexp"

type EmailAddress string

func (emailAddress *EmailAddress) ToString() string {
	return string(*emailAddress)
}

func (emailAddress *EmailAddress) Validate() bool {
	regex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return regex.MatchString(emailAddress.ToString())
}

func NewEmailAddress(str string) EmailAddress {
	email := EmailAddress(str)
	return email
}
