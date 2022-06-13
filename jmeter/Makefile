IMAGE=ghcr.io/dfe-digital/apply-jmeter-runner:latest

apply:
	$(eval VAR_FILE=apply)

manage:
	$(eval VAR_FILE=manage)

vendor:
	$(eval VAR_FILE=vendor)

find:
	$(eval VAR_FILE=find)

build:
	docker build -t $(IMAGE) .

push: build
	docker push $(IMAGE)

deploy-init:
	$(if $(PASSCODE), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(eval export TF_VAR_cf_sso_passcode=$(PASSCODE))
	terraform init

deploy-plan: deploy-init
	terraform plan -var-file workspace_variables/$(VAR_FILE).tfvars

deploy: deploy-init
	terraform apply -var-file workspace_variables/$(VAR_FILE).tfvars -auto-approve

destroy: deploy-init
	terraform destroy -var-file workspace_variables/$(VAR_FILE).tfvars -auto-approve
