package models

import "time"

type Schedule struct {
	Id           int       `gorm:"type:int; primaryKey; autoIncrement" json:"id"`
	UserId       int       `gorm:"int" json:"userId"`
	Title        string    `gorm:"type:varchar(255)" json:"title"`
	Address      string    `gorm:"type:text" json:"address"`
	Note         string    `gorm:"type:text" json:"note"`
	Reason       string    `gorm:"type:text; default:" json:"reason`
	Revision     int8      `gorm:"type:int; default:0" json:"revision"`
	Status       string    `gorm:"type:varchar(50)" json:"status"`
	StartDate    string    `gorm:"type:varchar(50)" json:"startDate"`
	EndDate      string    `gorm:"type:varchar(50)" json:"endDate"`
	SubmitDate   string    `gorm:"type:varchar(50)" json:"submitDate"`
	RejectedDate string    `gorm:"type:varchar(50)" json:"rejectedDate"`
	ApprovedDate string    `gorm:"type:varchar(50)" json:"approvedDate"`
	Attachment   string    `gorm:"type:varchar(255)" json:"attachment"`
	CreatedAt    time.Time `json:"createdAt"`
	UpdatedAt    time.Time `json:"updatedAt"`
	User         User      `gorm:"foreignKey:UserId" json:"user,omitempty"` // belongs to
}
