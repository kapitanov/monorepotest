all: install

GO_INSTALL := ../../scripts/go-install.sh

install: install-gotestsum install-gocover-cobertura install-golangci-lint install-semver

install-gotestsum:
	$(GO_INSTALL) gotest.tools/gotestsum@v1.12.0

install-gocover-cobertura:
	$(GO_INSTALL) github.com/boumenot/gocover-cobertura@v1.2.0

install-golangci-lint:
	$(GO_INSTALL) github.com/golangci/golangci-lint/cmd/golangci-lint@v1.61.0

install-semver:
	$(GO_INSTALL) github.com/maykonlf/semver-cli/cmd/semver@v1.0.2
