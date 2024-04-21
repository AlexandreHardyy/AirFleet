package utils

import (
	"mime/multipart"
	"strings"
)

var extensionsAvailable []string = []string{"pdf", "jpg", "jpeg", "png"}

func GetFileExtension(fileName string) string {
	splitedString := strings.Split(fileName, ".")
	return splitedString[len(splitedString)-1]
}

func IsFileValid(file *multipart.FileHeader) bool {
	extension := GetFileExtension(file.Filename)
	if !ArrayContain(extension, extensionsAvailable) {
		return false
	}

	return file.Size < 5*1024*1024
}
