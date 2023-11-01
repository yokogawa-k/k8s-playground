# vi: set ft=make ts=2 sw=2 sts=0 noet:

SHELL := /bin/bash

KIND_TAGS_URL := https://registry.hub.docker.com/v2/repositories/kindest/node/tags
KIND_TAGS_CACHE := .kind_tags.cache
_KIND_TAGS_CACHE_CHECK := $(shell find . -name $(KIND_TAGS_CACHE) -mtime -1)
VERSIONS := $(shell \
						if [ -z $(_KIND_TAGS_CACHE_CHECK) ]; then \
							curl -s $(KIND_TAGS_URL) | \
								jq -r .results[].name | \
								grep -v -e TEST | \
								sort --version-sort >$(KIND_TAGS_CACHE); \
						fi; \
						cat $(KIND_TAGS_CACHE))
CLUSTERS := $(shell kind get clusters)
CLUSTER_NAME ?= $(word 1,$(CLUSTERS))
CONTAINER_ID = $(shell kubectl get pods -l app=nginx --output='jsonpath={.items[0].metadata.name}')
WORKER_NODE  = $(shell kubectl get node --output='jsonpath={.items[1].metadata.name}')
SAMPLE_APP_IMAGE = sample-app:1.0

.PHONY: _default
_default: help

# http://postd.cc/auto-documented-makefile/
.PHONY: help _help-common
help: _help-common _help-list-versions _help-list-delete-cluster

_help-common:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m %-30s\033[0m %s\n", $$1, $$2}'

debug-node: ## debug node
	kubectl alpha debug node/$(WORKER_NODE) -it --image=alpine

debug-app: ## debug nginx pods
	kubectl alpha debug $(CONTAINER_ID) -it --image=alpine --copy-to=my-debugger --share-processes=true

deploy: load-local-image ## apply sample app deployment
	kubectl apply -f app-deployment.yaml

load-local-image: build-sample-app-image
	kind load --name $(CLUSTER_NAME) docker-image $(SAMPLE_APP_IMAGE)

build-sample-app-image:
	docker build -t $(SAMPLE_APP_IMAGE) ./sample-app/

_create-cluster:
	kind create cluster --name kind-$(VER) --image kindest/node:$(VER) --config kind-multi-node.yaml

_delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)

refresh-kind-versions: ## refresh kind version check file (default: expire in 1 day)
	rm -v $(KIND_TAGS_CACHE)

define list-versions
.PHONY: $(1) _help-$(1)
$(1):
	make VER=$(1) _create-cluster

_help-$(1):
	@printf "\033[36m %-30s\033[0m %s\n" "$(1)" "Kubernetes $(1) で Cluster を作成"
endef

$(foreach _ver,$(VERSIONS),$(eval $(call list-versions,$(_ver))))
.PHONY: _help-list-versions
_help-list-versions: $(addprefix _help-,$(VERSIONS))

define list-cluster-tasks
.PHONY: load-local-image-to-cluster-$(1)
load-local-image-to-cluster-$(1):
	make CLUSTER_NAME=$(1) load-local-image

.PHONY: delete-cluster-$(1) _help-delete-cluster-$(1)
delete-cluster-$(1):
	make CLUSTER_NAME=$(1) _delete-cluster

_help-delete-cluster-$(1):
	@printf "\033[36m %-30s\033[0m %s\n" "delete-cluster-$(1)" "$(1) の Cluster を削除"
endef

$(foreach _cluster,$(CLUSTERS),$(eval $(call list-cluster-tasks,$(_cluster))))

.PHONY: _help-list-delete-cluster
_help-list-delete-cluster: $(addprefix _help-delete-cluster-,$(CLUSTERS))

