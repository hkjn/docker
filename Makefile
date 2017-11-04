USERNAME=hkjn
NAME=$(shell basename $(PWD))

RELEASE_SUPPORT := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))/.make-release-support
IMAGE=$(USERNAME)/$(NAME)
DOCKER_ARCH=$(shell . $(RELEASE_SUPPORT) ; getDockerArch)
DOCKER_DOWNLOAD_ARCH=$(shell . $(RELEASE_SUPPORT) ; getDockerDownloadArch)
VERSION=$(shell . $(RELEASE_SUPPORT) ; getVersion)

SHELL=/bin/bash

.PHONY: pre-build docker-build post-build build release patch-release minor-release major-release check-release showver \
	push do-push post-push

build: pre-build docker-build post-build

pre-build:

post-build:
	# TODO: Reenable
	#@echo "Squashing image.."
	#@ . $(RELEASE_SUPPORT); dockerSquash $(IMAGE):$(VERSION)-$(DOCKER_ARCH)

post-push:

docker-build: .release
	@echo "Building image.."
	docker build -t $(IMAGE):$(VERSION)-$(DOCKER_ARCH) --build-arg docker_arch=$(DOCKER_DOWNLOAD_ARCH) --build-arg docker_version=$(VERSION) .
	@echo "Tagging image.."
	docker tag $(IMAGE):$(VERSION)-$(DOCKER_ARCH) $(IMAGE):$(VERSION)-$(DOCKER_ARCH)

.release:
	@echo "0.0.0" > .release
	@echo INFO: .release created
	@cat .release

release: check-status check-release build push

push: do-push post-push

do-push:
	@echo "Pushing image.."
	docker push $(IMAGE):$(VERSION)-$(DOCKER_ARCH)

snapshot: build push

showver: .release
	@. $(RELEASE_SUPPORT); getVersion

check-release: .release
	@. $(RELEASE_SUPPORT) ; ! hasChanges || (echo "ERROR: there are still outstanding changes" >&2 && exit 1) ;
	@. $(RELEASE_SUPPORT) ; tagExists $(TAG) || (echo "ERROR: version not yet tagged in git." >&2 && exit 1) ;
	@. $(RELEASE_SUPPORT) ; ! differsFromRelease $(TAG) || (echo "ERROR: current directory differs from tagged $(TAG)." ; exit 1)
