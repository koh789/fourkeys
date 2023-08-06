SHELL := /bin/bash -o pipefail
BIN_NAME     ?=

ROOT_DIR          ?= .
BRANCH_NAME       := $(shell git symbolic-ref --short HEAD)
COMMIT_HASH       := $(shell git rev-parse --short HEAD)
CURRENT_TIMESTAMP := $(shell date +%Y-%m-%d-%H%M%S)
VERSION_FILE      ?= Version
VERSION           := $(CURRENT_TIMESTAMP).$(subst /,_,$(BRANCH_NAME)).$(COMMIT_HASH)
PR_NUMBER         ?=


IMAGE_NAME   := gcr.io/$(PROJECT_ID)/$(BIN_NAME)
IMAGE_TAG    ?= $(shell cat $(VERSION_FILE))
IMAGE_PATH   = $(IMAGE_NAME):$(IMAGE_TAG)

branch-name: ## branch-name
	@echo $(BRANCH_NAME)

commit-hash: ## commit-hash
	@echo $(COMMIT_HASH)

current-version: ## current-version
	@echo $(VERSION)

image-tag: ## image-tag
	@echo $(IMAGE_TAG)

image-path: ## image-path
	@echo $(IMAGE_PATH)

refresh-version: ## refresh-version
	@echo $(VERSION) > $(VERSION_FILE)

build-image: .check-project-id .check-env ## build-image
	docker -- build -t $(IMAGE_PATH) -t $(IMAGE_NAME):$(ENV) -t $(IMAGE_NAME):latest --build-arg PROJECT=$(BIN_NAME) . -f Dockerfile

push-image: .check-project-id .check-env ## push-image
	docker -- push $(IMAGE_PATH)
	docker -- push $(IMAGE_NAME):$(ENV)
	docker -- push $(IMAGE_NAME):latest


push-handler: ## push-handler
	gcloud builds submit event-handler --config=event-handler/cloudbuild.yaml --project $(PROJECT_ID)

push-bq-worker: ## push-bq-worker
	gcloud builds submit bq-workers --config=bq-workers/parsers.cloudbuild.yaml --project $(PROJECT_ID) --substitutions=_SERVICE=github


help: ## ヘルプ
	@grep -E '^[0-9a-zA-Z_/()$$-]+:.*?## .*$$' $(lastword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.check-env:
ifndef ENV
	$(error ENV is required.)
endif

.check-project-id:
ifndef PROJECT_ID
	$(error PROJECT_ID is required.)
endif