// Package docs GENERATED BY SWAG; DO NOT EDIT
// This file was generated by swaggo/swag
package docs

import "github.com/swaggo/swag"

const docTemplate = `{
    "schemes": {{ marshal .Schemes }},
    "swagger": "2.0",
    "info": {
        "description": "{{escape .Description}}",
        "title": "{{.Title}}",
        "contact": {},
        "version": "{{.Version}}"
    },
    "host": "{{.Host}}",
    "basePath": "{{.BasePath}}",
    "paths": {
        "/users": {
            "get": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "get all user for admins",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "Get all users",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/responses.ListUser"
                            }
                        }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            },
            "post": {
                "description": "register for a normal client",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "Register user",
                "parameters": [
                    {
                        "description": "Message body",
                        "name": "userInput",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/inputs.CreateUser"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": {
                            "$ref": "#/definitions/responses.User"
                        }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/users/login": {
            "post": {
                "description": "login a client",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "Login",
                "parameters": [
                    {
                        "description": "Message body",
                        "name": "userInput",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/inputs.LoginUser"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/responses.Login"
                        }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/users/me": {
            "get": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "get current user",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "Current user",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/responses.User"
                        }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/users/pilot": {
            "post": {
                "description": "register for a pilot",
                "consumes": [
                    "multipart/form-data"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "Register pilot",
                "parameters": [
                    {
                        "description": "Message body",
                        "name": "userInput",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/inputs.CreatePilot"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": {
                            "$ref": "#/definitions/responses.User"
                        }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/users/pilot-validate/{id}": {
            "patch": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "Update user",
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "Validate Pilot Account",
                "parameters": [
                    {
                        "type": "string",
                        "description": "ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/responses.User"
                        }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    },
                    "404": {
                        "description": "Not Found",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/users/validate/{token}": {
            "get": {
                "description": "validate account with token",
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "Validate Account",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Token",
                        "name": "token",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/users/{id}": {
            "delete": {
                "description": "delete a user",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "Delete user",
                "parameters": [
                    {
                        "type": "integer",
                        "description": "User ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "204": {
                        "description": "No Content"
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            },
            "patch": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "Update user",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "user"
                ],
                "summary": "User",
                "parameters": [
                    {
                        "type": "string",
                        "description": "ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    },
                    {
                        "description": "Body...",
                        "name": "userInput",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/inputs.UpdateUser"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/responses.User"
                        }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/vehicles": {
            "get": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "get all vehicles",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "vehicle"
                ],
                "summary": "Get all vehicles",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/responses.Vehicle"
                            }
                        }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            },
            "post": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "create a new vehicle for a pilot",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "vehicle"
                ],
                "summary": "Create vehicle",
                "parameters": [
                    {
                        "description": "Message body",
                        "name": "vehicleInput",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/inputs.CreateVehicle"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": {
                            "$ref": "#/definitions/responses.Vehicle"
                        }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/vehicles/me": {
            "get": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "get all vehicles for current user",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "vehicle"
                ],
                "summary": "Get all vehicles for current user",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/responses.Vehicle"
                            }
                        }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        },
        "/vehicles/{id}": {
            "get": {
                "description": "get vehicle by id",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "vehicle"
                ],
                "summary": "get vehicle by id",
                "parameters": [
                    {
                        "type": "integer",
                        "description": "Vehicle ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/responses.Vehicle"
                        }
                    },
                    "404": {
                        "description": "Not Found",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            },
            "delete": {
                "description": "delete vehicle by id",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "vehicle"
                ],
                "summary": "delete vehicle by id",
                "parameters": [
                    {
                        "type": "integer",
                        "description": "Vehicle ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    },
                    "404": {
                        "description": "Not Found",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            },
            "patch": {
                "description": "update vehicle by id",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "vehicle"
                ],
                "summary": "update vehicle by id",
                "parameters": [
                    {
                        "type": "integer",
                        "description": "Vehicle ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    },
                    {
                        "description": "Message body",
                        "name": "vehicleInput",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/inputs.UpdateVehicle"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/responses.Vehicle"
                        }
                    },
                    "404": {
                        "description": "Not Found",
                        "schema": {
                            "$ref": "#/definitions/handlers.Response"
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "handlers.Response": {
            "type": "object",
            "properties": {
                "message": {
                    "type": "string"
                }
            }
        },
        "inputs.CreatePilot": {
            "type": "object"
        },
        "inputs.CreateUser": {
            "type": "object",
            "required": [
                "email",
                "first_name",
                "last_name",
                "password"
            ],
            "properties": {
                "email": {
                    "type": "string"
                },
                "first_name": {
                    "type": "string"
                },
                "last_name": {
                    "type": "string"
                },
                "password": {
                    "type": "string"
                }
            }
        },
        "inputs.CreateVehicle": {
            "type": "object",
            "required": [
                "matriculation",
                "model_name",
                "seat",
                "type"
            ],
            "properties": {
                "matriculation": {
                    "type": "string"
                },
                "model_name": {
                    "type": "string"
                },
                "seat": {
                    "type": "integer"
                },
                "type": {
                    "type": "string"
                }
            }
        },
        "inputs.LoginUser": {
            "type": "object",
            "required": [
                "email",
                "password"
            ],
            "properties": {
                "email": {
                    "type": "string"
                },
                "password": {
                    "type": "string"
                }
            }
        },
        "inputs.UpdateUser": {
            "type": "object",
            "properties": {
                "email": {
                    "type": "string"
                },
                "first_name": {
                    "type": "string"
                },
                "is_pilot_verified": {
                    "type": "boolean"
                },
                "is_verified": {
                    "type": "boolean"
                },
                "last_name": {
                    "type": "string"
                },
                "role": {
                    "type": "string"
                },
                "token_verify": {
                    "type": "string"
                }
            }
        },
        "inputs.UpdateVehicle": {
            "type": "object",
            "properties": {
                "matriculation": {
                    "type": "string"
                },
                "model_name": {
                    "type": "string"
                },
                "seat": {
                    "type": "integer"
                },
                "type": {
                    "type": "string"
                },
                "user_id": {
                    "type": "integer"
                }
            }
        },
        "responses.ListUser": {
            "type": "object",
            "properties": {
                "created_at": {
                    "type": "string"
                },
                "email": {
                    "type": "string"
                },
                "first_name": {
                    "type": "string"
                },
                "id": {
                    "type": "integer"
                },
                "is_verified": {
                    "type": "boolean"
                },
                "last_name": {
                    "type": "string"
                },
                "role": {
                    "type": "string"
                },
                "updated_at": {
                    "type": "string"
                }
            }
        },
        "responses.Login": {
            "type": "object",
            "properties": {
                "token": {
                    "type": "string"
                }
            }
        },
        "responses.User": {
            "type": "object",
            "properties": {
                "created_at": {
                    "type": "string"
                },
                "email": {
                    "type": "string"
                },
                "first_name": {
                    "type": "string"
                },
                "id": {
                    "type": "integer"
                },
                "last_name": {
                    "type": "string"
                },
                "role": {
                    "type": "string"
                },
                "updated_at": {
                    "type": "string"
                },
                "vehicles": {
                    "type": "array",
                    "items": {
                        "$ref": "#/definitions/responses.Vehicle"
                    }
                }
            }
        },
        "responses.Vehicle": {
            "type": "object",
            "properties": {
                "created_at": {
                    "type": "string"
                },
                "id": {
                    "type": "integer"
                },
                "is_verified": {
                    "type": "boolean"
                },
                "matriculation": {
                    "type": "string"
                },
                "model_name": {
                    "type": "string"
                },
                "seat": {
                    "type": "integer"
                },
                "type": {
                    "type": "string"
                },
                "updated_at": {
                    "type": "string"
                }
            }
        }
    },
    "securityDefinitions": {
        "BearerAuth": {
            "type": "apiKey",
            "name": "Authorization",
            "in": "header"
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
	Version:          "1.0",
	Host:             "",
	BasePath:         "/api",
	Schemes:          []string{},
	Title:            "Backend AirFleet",
	Description:      "this is the go project.",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
