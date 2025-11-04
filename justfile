# Justfile for Industryts project
# Run with: just <command>
# List all commands: just --list

# Default recipe to display help
default:
    @just --list

# Build the wheel package
build:
    @echo "🔨 Building wheel package..."
    uv sync --all-extras
    @rm -rf target/wheels/*.whl 2>/dev/null || true
    uv run maturin build --release --skip-auditwheel
    @echo "✅ Build complete! Wheel files are in target/wheels/"

# Build and sync to .venv
sync: build
    @echo "📦 Installing wheel to .venv..."
    uv pip install --force-reinstall target/wheels/*.whl
    @echo "✅ Package installed to .venv!"

# Quick development build (faster, unoptimized)
dev:
    @echo "🚀 Installing in development mode..."
    uv sync --all-extras
    uv run maturin develop
    @echo "✅ Development build complete!"

# Build optimized release version
release:
    @echo "🎯 Building optimized release..."
    uv sync --all-extras
    uv run maturin build --release --strip --skip-auditwheel
    @echo "✅ Release build complete!"

# Build manylinux wheel for distribution
manylinux:
    @echo "🐧 Building manylinux2014 wheel..."
    uv sync --all-extras
    docker run --rm -v $(pwd):/io \
        quay.io/pypa/manylinux2014_x86_64 \
        sh -c "cd /io && maturin build --release --manylinux 2014"
    @echo "✅ Manylinux wheel built!"

# Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    rm -rf target/
    rm -rf py-industryts/target/
    rm -rf **/__pycache__/
    rm -rf **/*.pyc
    rm -rf **/*.so
    rm -rf .pytest_cache/
    rm -rf .mypy_cache/
    @echo "✅ Cleaned!"

# Run Rust tests
test-rust:
    @echo "🧪 Running Rust tests..."
    cargo test --workspace

# Run Python tests (requires package to be installed)
test-python:
    @echo "🧪 Running Python tests..."
    uv run pytest tests/ -v

# Run all tests
test: test-rust
    @echo "✅ All tests passed!"

# Type check Python code
typecheck:
    @echo "🔍 Type checking with mypy..."
    uv run mypy py-industryts/industryts --strict
    @echo "🔍 Type checking with pyright..."
    uv run pyright py-industryts/industryts
    @echo "✅ Type checking passed!"

# Check Rust code
check:
    @echo "🔍 Checking Rust code..."
    cargo check --workspace
    cargo clippy --workspace -- -D warnings
    @echo "✅ Rust checks passed!"

# Format code
fmt:
    @echo "✨ Formatting Rust code..."
    cargo fmt --all
    @echo "✨ Formatting Python code..."
    uv run ruff format py-industryts/
    @echo "✅ Code formatted!"

# Lint code
lint:
    @echo "🔍 Linting Rust code..."
    cargo clippy --workspace
    @echo "🔍 Linting Python code..."
    uv run ruff check py-industryts/
    @echo "✅ Linting complete!"

# Run example script
example:
    @echo "📝 Running example script..."
    uv run python examples/basic_usage.py

# Full CI workflow
ci: check test typecheck
    @echo "✅ All CI checks passed!"

# Setup development environment
setup:
    @echo "🔧 Setting up development environment..."
    @echo "Installing uv if not already installed..."
    @command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh
    @echo "Installing development dependencies..."
    uv sync
    @echo "Building package in development mode..."
    uv run maturin develop
    @echo "✅ Development environment ready!"

# Show project info
info:
    @echo "📊 Project Information"
    @echo "======================"
    @echo "Rust version: $(rustc --version)"
    @echo "Cargo version: $(cargo --version)"
    @echo "Python version: $(python --version)"
    @echo "uv version: $(uv --version)"
    @echo ""
    @echo "Project structure:"
    @tree -L 2 -I 'target|__pycache__|*.pyc|.git'

# Quick rebuild and test cycle
quick: dev example
    @echo "✅ Quick test cycle complete!"

# Watch mode - rebuild on file changes (requires cargo-watch)
watch:
    @echo "👀 Watching for changes..."
    cargo watch -x "check --workspace" -s "just dev"
