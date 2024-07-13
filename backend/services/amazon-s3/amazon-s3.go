package amazonS3

import (
	"context"
	"fmt"
	"mime/multipart"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
)

type AWSCredentials struct {
	AccessKeyID     string
	SecretAccessKey string
	SessionToken    string
	Region          string
}

func loadAWSConfigFromToken(creds AWSCredentials) (aws.Config, error) {
	staticProvider := aws.CredentialsProviderFunc(func(context.Context) (aws.Credentials, error) {
		return aws.Credentials{
			AccessKeyID:     creds.AccessKeyID,
			SecretAccessKey: creds.SecretAccessKey,
			SessionToken:    creds.SessionToken,
			Source:          "TemporaryCredentials",
		}, nil
	})

	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		config.WithRegion(creds.Region),
		config.WithCredentialsProvider(staticProvider),
	)
	if err != nil {
		return aws.Config{}, fmt.Errorf("unable to load SDK config, %v", err)
	}

	return cfg, nil
}

func UploadToBucketS3(file *multipart.FileHeader, key string) error {
	bucketName := "bucket-name"
	cfg, err := loadAWSConfigFromToken(AWSCredentials{
		AccessKeyID: "",
		SecretAccessKey: "",
		SessionToken: "",
		Region: "",
	})
	if err != nil {
		return fmt.Errorf("unable to load SDK config, %v", err)
	}

	srcFile, err := file.Open()
	if err != nil {
		return fmt.Errorf("unable to open file %v, %v", file.Filename, err)
	}
	defer srcFile.Close()

	svc := s3.NewFromConfig(cfg)

	_, err = svc.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket:      aws.String(bucketName),
		Key:         aws.String(key),
		Body:        srcFile,
		ContentType: aws.String(file.Header.Get("Content-Type")),
		ACL:         types.ObjectCannedACLPublicRead, // default autorisation, here the file will be public
	})
	if err != nil {
		return fmt.Errorf("unable to upload %q to %q, %v", file.Filename, bucketName, err)
	}

	fmt.Printf("Successfully uploaded %q to %q\n", file.Filename, bucketName)
	return nil
}
