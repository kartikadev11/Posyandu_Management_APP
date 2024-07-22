// main.go

package main

import (
	"net/http"
	"tusk/config"
	"tusk/controllers"
	"tusk/models"

	"github.com/gin-gonic/gin"
)

func main() {
	// Database
	db := config.DatabaseConnection()
	db.AutoMigrate(&models.User{}, &models.Schedule{})
	config.CreateOwnerAccount(db)

	// Controller
	userController := controllers.UserController{DB: db}
	ScheduleController := controllers.ScheduleController{DB: db}

	// Router
	router := gin.Default()

	// Middleware CORS
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*") // Atur origin sesuai dengan aplikasi Flutter Anda
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, DELETE, PATCH, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusOK)
			return
		}
		c.Next()
	})

	// Endpoint
	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, "Welcome to Tusk API")
	})

	router.POST("/users/login", userController.Login)
	router.POST("/users", userController.CreateAccount)
	router.DELETE("/users/:id", userController.Delete)
	router.GET("/users/Member", userController.GetMembers)

	router.POST("/tasks", ScheduleController.Create)
	router.DELETE("/tasks/:id", ScheduleController.Delete)
	router.PATCH("/tasks/:id/submit", ScheduleController.Submit)
	router.PATCH("/tasks/:id/reject", ScheduleController.Reject)
	router.PATCH("/tasks/:id/fix", ScheduleController.Fix)
	router.PATCH("/tasks/:id/approve", ScheduleController.Approve)
	router.GET("/tasks/:id", ScheduleController.FindById)
	router.GET("/tasks/review/asc", ScheduleController.NeedToBeReview)
	router.GET("/tasks/progress/:userId", ScheduleController.ProgressTasks)
	router.GET("/tasks/stat/:userId", ScheduleController.Statistic)
	router.GET("/tasks/user/:userId/:status", ScheduleController.FindByUserAndStatus)

	router.Static("/attachments", "./attachments")
	router.Run("192.168.43.49:8080")
}
