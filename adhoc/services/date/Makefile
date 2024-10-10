all: compile test lint docker

generate:
	go generate ./...

version:
	@mkdir -p ../../artifacts/version
	../../scripts/go-version.sh > ../../artifacts/version/services-date

compile: generate version
	../../scripts/go-build.sh

test:
	../../scripts/go-test.sh

lint:
	../../scripts/go-lint.sh

docker: compile version
	../../scripts/docker-build.sh services-date
