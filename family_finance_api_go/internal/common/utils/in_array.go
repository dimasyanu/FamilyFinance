package utils

// type InArray[T comparable] func(item T, array []T) bool

func InArray[T comparable](array []T, item T) bool {
	for _, v := range array {
		if v == item {
			return true
		}
	}
	return false
}
