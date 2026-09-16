.PHONY: build build-native build-universal install install-native uninstall clean test

# Default: Universal release (Apple Silicon + Intel)
build:
	@bash scripts/build.sh release true

# Faster local build for the current Apple Silicon toolchain
build-native:
	@bash scripts/build.sh release false

# Build universal binary (Apple Silicon + Intel)
build-universal:
	@bash scripts/build.sh release true

# Debug build (Apple Silicon only)
build-debug:
	@bash scripts/build.sh debug false

# Install to ~/Library/Input Methods/
install: build
	@bash scripts/install.sh

# Install universal binary
install-universal: build-universal
	@bash scripts/install.sh

install-native: build-native
	@bash scripts/install.sh

# Uninstall
uninstall:
	@bash scripts/uninstall.sh

# Clean build artifacts
clean:
	rm -rf build/
	cd engine && cargo clean

# Run Rust tests
test:
	cd engine && cargo test
