package controllers

import (
	"net/http"
	"os"
	"strconv"
	"strings"
	"tusk/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type ScheduleController struct {
	DB *gorm.DB
}

func (t *ScheduleController) Create(c *gin.Context) {
	task := models.Schedule{}
	errBindJson := c.ShouldBindJSON(&task)
	if errBindJson != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errBindJson.Error()})
		return
	}

	errDB := t.DB.Create(&task).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusCreated, task)
}

func (t *ScheduleController) Delete(c *gin.Context) {
	id := c.Param("id")
	task := models.Schedule{}

	if err := t.DB.First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tidak Ditemukan"})
		return
	}

	errDB := t.DB.Delete(&models.Schedule{}, id).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errDB.Error()})
		return
	}

	if task.Attachment != "" {
		os.Remove("attachments/" + task.Attachment)
	}

	c.JSON(http.StatusOK, "Deleted")
}

func (t *ScheduleController) Submit(c *gin.Context) {
	task := models.Schedule{}
	id := c.Param("id")
	submitDate := c.PostForm("submitDate")
	file, errFile := c.FormFile("attachment")
	if errFile != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errFile.Error()})
		return
	}

	if err := t.DB.First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}

	// remove old attachment
	attachment := task.Attachment
	fileInfo, _ := os.Stat("attachments/" + attachment)
	if fileInfo != nil {
		// found
		os.Remove("attachments/" + attachment)
	}

	// create new attaachment
	attachment = file.Filename
	errSave := c.SaveUploadedFile(file, "attachments/"+attachment)
	if errSave != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errSave.Error()})
		return
	}

	errDB := t.DB.Where("id=?", id).Updates(models.Schedule{
		Status:     "Review",
		SubmitDate: submitDate,
		Attachment: attachment,
	}).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, "Submit untuk di-Review")
}

func (t *ScheduleController) Reject(c *gin.Context) {
	task := models.Schedule{}
	id := c.Param("id")
	reason := c.PostForm("reason")
	rejectedDate := c.PostForm("rejectedDate")

	if err := t.DB.First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}

	errDB := t.DB.Where("id=?", id).Updates(models.Schedule{
		Status:       "Rejected",
		Reason:       reason,
		RejectedDate: rejectedDate,
	}).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, "Rejected")
}

func (t *ScheduleController) Fix(c *gin.Context) {
	id := c.Param("id")
	revision, errConv := strconv.Atoi(c.PostForm("revision"))
	if errConv != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": errConv.Error()})
		return
	}

	if err := t.DB.First(&models.Schedule{}, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}

	errDB := t.DB.Where("id=?", id).Updates(models.Schedule{
		Status:   "Queue",
		Revision: int8(revision),
	}).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, "Presensi Fix")
}

func (t *ScheduleController) Approve(c *gin.Context) {
	id := c.Param("id")
	approvedDate := c.PostForm("approvedDate")

	if err := t.DB.First(&models.Schedule{}, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tidak Ditemukan"})
		return
	}

	errDB := t.DB.Where("id=?", id).Updates(models.Schedule{
		Status:       "Approved",
		ApprovedDate: approvedDate,
	}).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, "Approved")
}

func (t *ScheduleController) FindById(c *gin.Context) {
	task := models.Schedule{}
	id := c.Param("id")

	if err := t.DB.First(&models.Schedule{}, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}

	errDB := t.DB.Preload("User").Find(&task, id).Error
	if errDB != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, task)
}

func (t *ScheduleController) NeedToBeReview(c *gin.Context) {
	tasks := []models.Schedule{}

	errDB := t.DB.Preload("User").Where("status=?", "Review").Order("submit_date ASC").Limit(2).Find(&tasks).Error
	if errDB != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, tasks)
}

func (t *ScheduleController) ProgressTasks(c *gin.Context) {
	tasks := []models.Schedule{}
	userId := c.Param("userId")

	errDB := t.DB.Where(
		"(status!=? AND user_id=?) OR (revision!=? AND user_id=?)", "Queue", userId, 0, userId,
	).Order("updated_at DESC").Limit(5).Find(&tasks).Error
	if errDB != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, tasks)
}

func (t *ScheduleController) Statistic(c *gin.Context) {
	userId := c.Param("userId")

	stat := []map[string]interface{}{}

	errDB := t.DB.Model(models.Schedule{}).Select("status, count(status) as total").Where("user_id=?", userId).Group("status").Find(&stat).Error
	if errDB != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, stat)
}

func (t *ScheduleController) FindByUserAndStatus(c *gin.Context) {
	tasks := []models.Schedule{}
	userId := c.Param("userId")
	status := c.Param("status")

	errDB := t.DB.Where("user_id=? AND status=?", userId, status).Find(&tasks).Error
	if errDB != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": errDB.Error()})
		return
	}

	c.JSON(http.StatusOK, tasks)
}

// GetSchedulesByStatus mengembalikan jadwal berdasarkan status yang diberikan
func (t *ScheduleController) GetSchedulesByStatus(c *gin.Context) {
    tasks := []models.Schedule{}
    status := c.Param("status")

    if err := t.DB.Where("status IN (?)", strings.Split(status, ",")).Find(&tasks).Error; err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, tasks)
}