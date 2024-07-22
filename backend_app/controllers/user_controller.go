package controllers

import (
	"net/http"
	"tusk/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserController struct {
	DB *gorm.DB
}

func (u *UserController) Login(c *gin.Context) {
	user := models.User{}
	errBindJson := c.ShouldBindJSON(&user)
	if errBindJson != nil {
	  c.JSON(http.StatusInternalServerError, gin.H{"error": errBindJson.Error()})
	  return
	}
  
	password := user.Password
  
	errDB := u.DB.Where("email=?", user.Email).Take(&user).Error
	if errDB != nil {
	  c.JSON(http.StatusInternalServerError, gin.H{"error": "Email atau Password Salah"})
	  return
	}
  
	errHash := bcrypt.CompareHashAndPassword(
	  []byte(user.Password),
	  []byte(password),
	)
	if errHash != nil {
	  c.JSON(http.StatusUnauthorized, gin.H{"error": "Email atau Password Salah"})
	  return
	}
  
	c.JSON(http.StatusOK, user)
  }
  

func (u *UserController) CreateAccount(c *gin.Context) {
	user := models.User{}
	errBindJson := c.ShouldBindJSON(&user)
	if errBindJson != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errBindJson.Error()})
		return
	}

	emailExist := u.DB.Where("email=?", user.Email).First(&user).RowsAffected != 0
	if emailExist {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email Sudah Pernah digunakan"})
		return
	}

	hashedPasswordBytes, _ := bcrypt.GenerateFromPassword([]byte("123456"), bcrypt.DefaultCost)

	user.Password = string(hashedPasswordBytes)
	user.Role = "Member"

	errDB := u.DB.Create(&user).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusCreated, user)
}

func (u *UserController) Delete(c *gin.Context) {
	id := c.Param("id")

	errDB := u.DB.Delete(&models.User{}, id).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, "Deleted")
}

func (u *UserController) GetMembers(c *gin.Context) {
	users := []models.User{}

	errDB := u.DB.Select("id,name").Where("role=?", "Member").Find(&users).Error
	if errDB != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, users)
}
