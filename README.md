Docker compose explanation:

version: '3': This line specifies the version of Docker Compose to use. Here it's version 3.

services:: This section is used to define the different services or containers that will be run. Here, we have only one service defined, called "terraform".

terraform:: This is the name of the service, it's arbitrary and you could name it anything.

image: hashicorp/terraform:latest: This line specifies the Docker image to use for this service. In this case, it's using the latest version of the official HashiCorp Terraform image.

volumes:: This section is used to mount paths between the host (the machine where Docker is running) and the container. Here, the local directory ./terraform is being mounted to the /app directory inside the Docker container.

working_dir: /app: This sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile. In this case, it's /app.

command: ["terraform", "apply", "-auto-approve"]: This line specifies the command to be run within the container once it's up. In this case, the terraform apply -auto-approve command is run. This command is a Terraform command used to apply the changes required to reach the desired state of the configuration. The -auto-approve flag is an option that skips interactive approval of plan before applying.