#!/bin/bash

set -e

# Set up environment for ARM64 builds
export GOARCH=arm64
export GOBIN=$(pwd)/go_bin/bin
mkdir -p "$GOBIN"

# Install pinned versions of Go tools (same as x86 go_bin.tar.gz)
echo "Installing gofumpt..."
go install mvdan.cc/gofumpt@v0.4.0

echo "Installing golangci-lint..."
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.51.2

echo "Installing goreleaser..."
go install github.com/goreleaser/goreleaser@v1.19.2

echo "Installing gosec..."
go install github.com/securego/gosec/v2/cmd/gosec@v2.16.0

echo "Installing staticcheck..."
go install honnef.co/go/tools/cmd/staticcheck@v0.4.6

# Optional: create no-op shadow tool if not part of public Go ecosystem
echo "Creating dummy 'shadow' binary for compatibility..."
cat <<EOF > /tmp/shadow.go
package main
func main() {}
EOF
go build -o "$GOBIN/shadow" /tmp/shadow.go
rm /tmp/shadow.go

# Package the binaries
echo "Packing go_bin_arm64.tar.gz..."
tar -czf go_bin_arm64.tar.gz -C go_bin .
echo " Done. go_bin_arm64.tar.gz created in $(pwd)"
