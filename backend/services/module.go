package services

import (
	"backend/inputs"
	"backend/repositories"
	"backend/responses"
)

type ModuleServiceInterface interface {
	UpdateModule(moduleID int, module inputs.InputUpdateModule) (responses.ResponseModule, error)
	GetAllModules(filters map[string]interface{}) ([]responses.ResponseModule, error)
	GetModule(filters map[string]interface{}) (responses.ResponseModule, error)
}

type ModuleService struct {
	repository repositories.ModuleRepositoryInterface
}

func NewModuleService(repository repositories.ModuleRepositoryInterface) *ModuleService {
	return &ModuleService{repository}
}

func (s *ModuleService) UpdateModule(moduleID int, module inputs.InputUpdateModule) (responses.ResponseModule, error) {
	moduleModel, err := s.repository.GetModuleByID(moduleID)
	if err != nil {
		return responses.ResponseModule{}, err
	}

	if module.IsEnabled != nil {
		moduleModel.IsEnabled = *module.IsEnabled
	}

	updatedModule, err := s.repository.UpdateModule(moduleModel)
	if err != nil {
		return responses.ResponseModule{}, err
	}

	return responses.ResponseModule{
		ID:        updatedModule.ID,
		Name:      updatedModule.Name,
		IsEnabled: updatedModule.IsEnabled,
	}, nil
}

func (s *ModuleService) GetAllModules(filters map[string]interface{}) ([]responses.ResponseModule, error) {
	modules, err := s.repository.GetAllModules(filters)
	if err != nil {
		return nil, err
	}

	var responseModules []responses.ResponseModule
	for _, module := range modules {
		responseModules = append(responseModules, responses.ResponseModule{
			ID:        module.ID,
			Name:      module.Name,
			IsEnabled: module.IsEnabled,
		})
	}

	return responseModules, nil
}

func (s *ModuleService) GetModule(filters map[string]interface{}) (responses.ResponseModule, error) {
	module, err := s.repository.GetModule(filters)
	if err != nil {
		return responses.ResponseModule{}, err
	}

	return responses.ResponseModule{
		ID:        module.ID,
		Name:      module.Name,
		IsEnabled: module.IsEnabled,
	}, nil
}
