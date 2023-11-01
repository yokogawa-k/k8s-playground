# vi: set ft=make ts=2 sw=2 sts=0 noet:

SHELL := /bin/bash

UNBOUND_IMAGE_NAME := unbound-distroless
CLUSTERS := $(shell kind get clusters)
CLUSTER_NAME ?= $(word 1,$(CLUSTERS))

.PHONY: default
default: help

# http://postd.cc/auto-documented-makefile/
.PHONY: help help-common
help: help-common

help-common:
	@grep -E '^[\/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m %-30s\033[0m %s\n", $$1, $$2}'

.PHONY: node-dns/image-build node-dns/image-load node-dns/build node-dns/diff node-dns/apply
node-dns/image-build: ## node-dns イメージをビルド
	@echo "https://github.com/klutchell/unbound-docker を利用する場合"
	@echo "$(UNBOUND_IMAGE_NAME) という名前で build を行う"
	@echo "作成後は node-dns/image-load で kind にロードしてください"

node-dns/image-load: ## node-dns イメージを kind にロード
	kind load --name $(CLUSTER_NAME) docker-image $(UNBOUND_IMAGE_NAME):latest

node-dns/build: ## node-dns/kustomization.yaml を元に build
	kubectl kustomize ./node-dns

node-dns/diff: ## 既存のリソースと node-dns/kustomization.yaml の diff の取得
	kubectl diff -k ./node-dns

node-dns/apply: ## node-dns/kustomization.yaml の変更を適用
	kubectl apply -k ./node-dns

node-dns/log: ## node-dns のログを表示
	kubectl logs -f -n kube-system -l k8s-app=node-dns

node-dns/debug: ## node-dns のデバッグ用コンテナを起動
	# gcr.io/distroless/base-debian12 を利用しているのはデバッグツールが入ってるので
	# 専用の debug 用イメージを用意するほうが良いかも
	kubectl debug -n kube-system $(shell kubectl get -n kube-system -l appname=node-dns pods -o json | jq .items[0].metadata.name) -it --image=gcr.io/distroless/base-debian12:debug --target=unbound -- sh

.PHONY: install-inspektor-gadget
install-inspektor-gadget: ## inspektor-gadget をインストール
	kubectl krew install gadget
	kubectl gadget deploy


