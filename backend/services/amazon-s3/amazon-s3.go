package amazonS3

import (
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"os"
	"path/filepath"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

const bucketName = "airfleet-prod"

func UploadToBucketS3(file *multipart.FileHeader, key string) error {
	accessKeyID := os.Getenv("AWS_ACCESS_KEY_ID")
	secretAccessKey := os.Getenv("AWS_SECRET_ACCESS_KEY")
	region := os.Getenv("AWS_REGION")

	if accessKeyID == "" || secretAccessKey == "" || region == "" || bucketName == "" {
		log.Fatal("Les variables d'environnement AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, S3_BUCKET_NAME et FILE_PATH doivent être définies")
	}

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
		Credentials: credentials.NewStaticCredentials(
			accessKeyID,
			secretAccessKey,
			"",
		),
	})
	if err != nil {
		log.Fatal(err)
	}

	s3Client := s3.New(sess)

	srcFile, err := file.Open()
	if err != nil {
		return fmt.Errorf("unable to open file %v, %v", file.Filename, err)
	}
	defer srcFile.Close()

	uploadInput := &s3.PutObjectInput{
		Bucket:        aws.String(bucketName),
		Key:           aws.String(filepath.Base(key)),
		Body:          srcFile,
		ContentLength: aws.Int64(file.Size),
	}

	_, err = s3Client.PutObject(uploadInput)
	if err != nil {
		log.Fatalf("Erreur d'upload du fichier: %v", err)
	}
	return nil
}

func DownloadFromBucketS3(key string) ([]byte, error) {
	accessKeyID := os.Getenv("AWS_ACCESS_KEY_ID")
	secretAccessKey := os.Getenv("AWS_SECRET_ACCESS_KEY")
	region := os.Getenv("AWS_REGION")

	if accessKeyID == "" || secretAccessKey == "" || region == "" {
		return nil, fmt.Errorf("les variables d'environnement AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION doivent être définies")
	}

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
		Credentials: credentials.NewStaticCredentials(
			accessKeyID,
			secretAccessKey,
			"",
		),
	})
	if err != nil {
		return nil, err
	}

	s3Client := s3.New(sess)

	result, err := s3Client.GetObject(&s3.GetObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(key),
	})
	if err != nil {
		return nil, fmt.Errorf("erreur lors du téléchargement du fichier : %v", err)
	}
	defer result.Body.Close()

	body, err := io.ReadAll(result.Body)
	if err != nil {
		return nil, fmt.Errorf("erreur lors de la lecture du corps du fichier : %v", err)
	}

	return body, nil
}
