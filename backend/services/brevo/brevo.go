package brevo

import (
	"context"
	"fmt"
	"os"

	brevo "github.com/getbrevo/brevo-go/lib"
)

var brevoClient *brevo.APIClient

type EmailService interface {
    SendEmailToVerify(email string, name string, token string)
	SendEmailPilotAccountValidate(email string, name string)
}

type BrevoEmailService struct{}


func InitBrevoClient() {
	var ctx context.Context
	conf := brevo.NewConfiguration()
	conf.AddDefaultHeader("api-key", os.Getenv("BREVO_API_KEY"))

	brevoClient = brevo.NewAPIClient(conf)
	_, _, err := brevoClient.AccountApi.GetAccount(ctx)
	if err != nil {
		fmt.Println("Error when calling AccountApi->get_account: ", err.Error())
		return
	}
}

func (s *BrevoEmailService) SendEmailToVerify(email string, name string, token string) {
	var ctx context.Context

	brevoClient.TransactionalEmailsApi.SendTransacEmail(ctx, brevo.SendSmtpEmail{
		Sender: &brevo.SendSmtpEmailSender{
			Name:  "AirFleet",
			Email: "mail@airfleet.com",
		},
		To: []brevo.SendSmtpEmailTo{
			{
				Email: email,
				Name:  name,
			},
		},
		TemplateId: 4,
		Params: map[string]interface{}{
			"NAME": name,
			"LINK": os.Getenv("API_URL") + "/api/users/validate/" + token,
		},
	})
}

func (s *BrevoEmailService) SendEmailPilotAccountValidate(email string, name string) {
	var ctx context.Context

	brevoClient.TransactionalEmailsApi.SendTransacEmail(ctx, brevo.SendSmtpEmail{
		Sender: &brevo.SendSmtpEmailSender{
			Name:  "AirFleet",
			Email: "mail@airfleet.com",
		},
		To: []brevo.SendSmtpEmailTo{
			{
				Email: email,
				Name:  name,
			},
		},
		TemplateId: 5,
		Params: map[string]interface{}{
			"NAME": name,
		},
	})
}
