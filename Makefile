#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = fannie-mae-ci-cd-jenkins
PYTHON_VERSION = 3.12
PYTHON_INTERPRETER = python

# Docker image name
DOCKER_IMAGE_NAME = $(PROJECT_NAME)-env
# Docker container name (optional, useful for debugging)
DOCKER_CONTAINER_NAME = $(PROJECT_NAME)-container

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Build the Docker image
.PHONY: build
build:
	docker build -t $(DOCKER_IMAGE_NAME) .

## Install Python dependencies (rebuilds the image to update environment)
.PHONY: requirements
requirements: build # 'requirements' now triggers a rebuild to update the env
	@echo "Dependencies are installed during the Docker image build process."
	@echo "To update them, run 'make build' again after modifying environment.yml."

## Delete all compiled Python files
.PHONY: clean
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using ruff (use `make format` to do formatting)
.PHONY: lint
lint: build
	docker run --rm \
		-v $(PWD):/app \
		$(DOCKER_IMAGE_NAME) \
		conda run --name $(PROJECT_NAME) ruff format --check
	docker run --rm \
		-v $(PWD):/app \
		$(DOCKER_IMAGE_NAME) \
		conda run --name $(PROJECT_NAME) ruff check

## Format source code with ruff
.PHONY: format
format: build
	docker run --rm \
		-v $(PWD):/app \
		$(DOCKER_IMAGE_NAME) \
		conda run --name $(PROJECT_NAME) ruff check --fix
	docker run --rm \
		-v $(PWD):/app \
		$(DOCKER_IMAGE_NAME) \
		conda run --name $(PROJECT_NAME) ruff format

## Run tests
.PHONY: test
test: build
	docker run --rm \
		-v $(PWD):/app \
		$(DOCKER_IMAGE_NAME) \
		conda run --name $(PROJECT_NAME) pytest tests

## Download Data from storage system
.PHONY: sync_data_down
sync_data_down: build
	docker run --rm \
		-v $(PWD)/data:/app/data \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
		$(DOCKER_IMAGE_NAME) \
		conda run --name $(PROJECT_NAME) aws s3 sync s3://fannie-mae-ci-cd-jenkins/data/ data/

## Upload Data to storage system
.PHONY: sync_data_up
sync_data_up: build
	docker run --rm \
		-v $(PWD)/data:/app/data \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
		$(DOCKER_IMAGE_NAME) \
		conda run --name $(PROJECT_NAME) aws s3 sync data/ s3://fannie-mae-ci-cd-jenkins/data

## Set up Python interpreter environment (now handled by 'build')
.PHONY: create_environment
create_environment: build
	@echo "The Conda environment is created within the Docker image during 'make build'."
	@echo "You can activate it within a running container, e.g., 'docker run -it $(DOCKER_IMAGE_NAME) /bin/bash'."

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################

## Make dataset
.PHONY: data
data: build
	docker run --rm \
		-v $(PWD):/app \
		$(DOCKER_IMAGE_NAME) \
		conda run --name $(PROJECT_NAME) $(PYTHON_INTERPRETER) fannie_mae_ci_cd_jenkins/dataset.py

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n[\s\S]+?\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

help:
	@$(PYTHON_INTERPRETER) -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)
