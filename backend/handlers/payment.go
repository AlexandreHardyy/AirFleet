package handlers

import (
	"backend/database"
	"backend/models"
	"backend/repositories"
	"backend/utils/token"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"github.com/stripe/stripe-go/v79/paymentintent"
)

func CreatePaymentIntent(c *gin.Context) {
	var params struct {
		Amount   int64  `json:"amount"`
		FlightId string `json:"currency"`
	}

	if err := c.ShouldBindJSON(&params); err != nil {
		c.JSON(http.StatusBadRequest, Response{Message: err.Error()})
		return
	}

	paymentIntentParams := &stripe.PaymentIntentParams{
		Amount:   stripe.Int64(params.Amount),
		Currency: stripe.String("eur"),
	}

	paymentIntent, err := paymentintent.New(paymentIntentParams)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"client_secret": paymentIntent.ClientSecret, "id": paymentIntent.ID})
}

func VerifyPayment(c *gin.Context) {
	userID, err := token.ExtractTokenID(c)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract user ID from token",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}
	var params struct {
		PaymentId string `json:"payment_id"`
		FlightId  int    `json:"flight_id"`
	}

	if err := c.ShouldBindJSON(&params); err != nil {
		c.JSON(http.StatusBadRequest, Response{Message: err.Error()})
		return
	}

	paymentIntent, err := paymentintent.Get(params.PaymentId, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, Response{Message: err.Error()})
		return
	}
	if paymentIntent.Status != "succeeded" {
		c.JSON(http.StatusInternalServerError, Response{Message: "something go wrong with the payment"})
		return
	}

	flight, err := repositories.NewFlightRepository(database.DB).GetFlightByID(params.FlightId)
	if err != nil {
		c.JSON(http.StatusNotFound, Response{Message: err.Error()})
		return
	}

	repositories.CreatePayment(models.Payment{
		PaymentId: paymentIntent.ID,
		Amount:    *flight.Price,
		UserID:    userID,
		FlightID:  flight.ID,
	})

	c.Status(200)
}
