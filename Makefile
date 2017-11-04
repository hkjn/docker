USERNAME=hkjn
NAME=$(shell basename $(PWD))

IMAGE=$(USERNAME)/$(NAME)
DOCKER_ARCH=$(shell bash get_docker_arch)
DOCKER_DOWNLOAD_ARCH=$(shell bash get_docker_download_arch)
VERSION=$(shell cat VERSION)

SHELL=/bin/bash

.PHONY: pre-build docker-build post-build build push do-push post-push

build: pre-build docker-build post-build

pre-build:

post-build:
	@echo "Squashing image.."
	docker run --rm \
		   -v /var/run/docker.sock:/var/run/docker.sock \
		   hkjn/docker-squash \
		     -t $(IMAGE):$(VERSION)-$(DOCKER_ARCH) \
		        $(IMAGE):$(VERSION)-$(DOCKER_ARCH)

post-push:
	@echo "Pushing multi-arch manifest to $(IMAGE):$(VERSION).."
	docker run --rm -v $(HOME)/.docker:/root/.docker:ro \
	       hkjn/manifest-tool \
	       push from-args --platforms linux/amd64,linux/arm \
		              --template $(IMAGE):$(VERSION)-ARCH \
			      --target $(IMAGE):$(VERSION)
	@echo "Pushing multi-arch manifest to $(IMAGE).."
	docker run --rm -v $(HOME)/.docker:/root/.docker:ro \
	       hkjn/manifest-tool \
	       push from-args --platforms linux/amd64,linux/arm \
		              --template $(IMAGE):$(VERSION)-ARCH \
			      --target $(IMAGE)

docker-build:
	@echo "Building image.."
	docker build -t $(IMAGE):$(VERSION)-$(DOCKER_ARCH) \
	             --build-arg docker_arch=$(DOCKER_DOWNLOAD_ARCH) \
		     --build-arg docker_version=$(VERSION) .
	@echo "Tagging image.."
	docker tag $(IMAGE):$(VERSION)-$(DOCKER_ARCH) \
		   $(IMAGE):$(VERSION)-$(DOCKER_ARCH)

push: do-push post-push

do-push:
	@echo "Pushing image.."
	docker push $(IMAGE):$(VERSION)-$(DOCKER_ARCH)

