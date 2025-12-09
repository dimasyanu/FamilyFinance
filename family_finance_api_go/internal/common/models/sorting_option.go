package models

type SortingOption struct {
	Field     string `json:"sort_field"`
	Direction string `json:"sort_direction"`
}
