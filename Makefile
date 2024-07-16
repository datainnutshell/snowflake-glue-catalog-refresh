# Define the Docker image name
IMAGE_NAME = glue_catalog_sync

# Define the Docker container name
CONTAINER_NAME = $(IMAGE_NAME)_container

# Define the Dockerfile directory
DOCKERFILE_DIR = lambda

# Define the Terraform plan file name
TF_PLAN_FILE = tfplan.out

# Default target
all: build copy init plan deploy

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) $(DOCKERFILE_DIR)

# Copy the lambda_function.zip from the container
copy: build
# Create a container from the image
	docker create --name $(CONTAINER_NAME) $(IMAGE_NAME)
# Copy the file from the container to the host
	docker cp $(CONTAINER_NAME):/app/lambda_function.zip $(DOCKERFILE_DIR)
# Remove the container
	docker rm $(CONTAINER_NAME)

# Initialize Tofu
init:
	tofu init

# Create a Tofu plan
plan: init
	tofu plan -out=$(TF_PLAN_FILE) -var-file settings.tfvars

# Apply the Tofu plan
deploy: plan
	tofu apply $(TF_PLAN_FILE) 

# Apply the Tofu plan
destroy:
	tofu destroy -auto-approve -var-file settings.tfvars

# Clean up any generated files
clean:
	tofu destroy -auto-approve -var-file settings.tfvars
	rm -f $(DOCKERFILE_DIR)/lambda_function.zip $(TF_PLAN_FILE)

.PHONY: all build copy init plan deploy destroy clean