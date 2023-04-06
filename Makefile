# Copyright 2023 leopoldxx & ksdpmx
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

NAME ?= kubectl-watch
OUTPUT := .

GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
GOPATH ?= $(shell go env GOPATH)
GOBIN ?= $(GOPATH)/bin
BUILDARG ?=

BUILDTIME := $(shell date '+%Y%m%d-%H%M%S')
VERSION := $(shell git describe --tags --always)-${BUILDTIME}-${GOARCH}
COMMIT := $(shell git rev-parse --short HEAD)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

LDFLAGS += -X "main.Version=${VERSION}"
LDFLAGS += -X "main.GoVersion=$(shell go version)"
LDFLAGS += -X "main.Branch=${BRANCH}"
LDFLAGS += -X "main.Commit=${COMMIT}"
LDFLAGS += -X "main.BuildTime=${BUILDTIME}"


all: fmt vet lint binary

.PHONY: binary
binary: $(NAME)

.PHONY: $(NAME)
$(NAME):
	go build $(BUILDARG) -trimpath -o ${OUTPUT}/${NAME} -ldflags '$(LDFLAGS)' ./main.go

.PHONY: fmt
fmt:
	go fmt $(BUILDARG) ./...

.PHONY: vet
vet:
	go vet $(BUILDARG) ./...

.PHONY: lint
lint: golangci-lint
	${LINT} run ./...

.PHONY: golangci-lint
golangci-lint:
ifeq (, $(shell which golangci-lint))
	@{ \
		set -e ;\
		curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.52.2 ;\
	}
LINT=$(GOBIN)/golangci-lint
else
LINT=$(shell which golangci-lint)
endif
