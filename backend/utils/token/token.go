package token

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

type Token struct {
	Token string `json:"token" binding:"required"`
}

type Claims struct {
	ID int `json:"id"`
	jwt.RegisteredClaims
}

func GenerateToken(userId int) (string, error) {
	expirationTime := time.Now().Add(time.Hour * 24 * 30 * 12)

	claims := &Claims{
		ID: userId,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	if os.Getenv("TOKEN_SECRET") == "" {
		panic("env: TOKEN_SECRET not found")
	}
	jwtKey := []byte(os.Getenv("TOKEN_SECRET"))

	tokenString, err := token.SignedString(jwtKey)

	return tokenString, err
}

func TokenValid(c *gin.Context) error {
	tokenString := extractToken(c)
	_, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(os.Getenv("TOKEN_SECRET")), nil
	})
	if err != nil {
		return err
	}
	return nil
}

func extractToken(c *gin.Context) string {
	token := c.Query("token")
	if token != "" {
		return token
	}
	bearerToken := c.Request.Header.Get("Authorization")
	if len(strings.Split(bearerToken, " ")) == 2 {
		return strings.Split(bearerToken, " ")[1]
	}
	return ""
}

func ExtractTokenID(c *gin.Context) (int, error) {

	tokenString := extractToken(c)

	claims := &Claims{}

	tkn, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (any, error) {
		return []byte(os.Getenv("TOKEN_SECRET")), nil
	})

	if !tkn.Valid {
		return 0, err
	}

	return claims.ID, err
}
