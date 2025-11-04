# Installation

## Requirements

### System Requirements

- **Python**: 3.9+ (compatible with 3.9, 3.10, 3.11, 3.12, 3.13)
- **Operating System**:
  - Linux (glibc 2.17+, e.g., CentOS 7+, Ubuntu 18.04+)
  - macOS (x86_64 or arm64/M1/M2)
  - Windows (x86_64)

### Optional Dependencies

- **For large datasets** (>4.2B rows): Polars with 64-bit row indices
  ```bash
  pip install polars[rt64]
  ```

## Install from PyPI

The recommended way to install Industryts is via pip:

::: code-group

```bash [pip]
pip install industryts
```

```bash [uv (recommended)]
# uv is faster and more reliable
uv add industryts
```

```bash [with optional dependencies]
pip install industryts polars[rt64]
```

:::

### Verify Installation

```python
import industryts as its

print(its.__version__)
print(its.TimeSeriesData)  # Should show class info
```

## Install from Source

For development or to use the latest features:

### Prerequisites

1. **Rust**: 1.70 or later
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   ```

2. **Python**: 3.9 or later
   ```bash
   python --version  # Should be 3.9+
   ```

3. **uv** (recommended package manager):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

### Development Installation

::: code-group

```bash [Using uv (recommended)]
# Clone the repository
git clone https://github.com/yourusername/industryts.git
cd industryts

# Install development dependencies
uv sync --dev

# Build and install in development mode (fast compile, debug symbols)
uv run maturin develop

# Or use make for convenience
make develop
```

```bash [Using pip]
# Clone the repository
git clone https://github.com/yourusername/industryts.git
cd industryts

# Install build dependencies
pip install maturin

# Build and install in development mode
maturin develop

# Install Python dependencies
pip install -e ".[dev]"
```

:::

### Release Build

For production use or benchmarking, build with optimizations:

```bash
# Release build (slower compile, maximum performance)
make build

# Or directly with maturin
uv run maturin develop --release
```

::: tip Performance Difference
Debug builds are ~10x slower than release builds. Always use release builds for benchmarking!
:::

### Run Tests

```bash
# Run all tests (Rust + Python)
make test

# Run only Rust tests
cargo test

# Run only Python tests
pytest
```

### Type Checking

```bash
# Run type checkers
make typecheck

# Or manually
mypy py-industryts/industryts
pyright py-industryts/industryts
```

## Platform-Specific Notes

### Linux

**Wheels are built with manylinux2014** for maximum compatibility (glibc 2.17+).

If you encounter `ImportError: libgomp.so.1: cannot open shared object file`:

```bash
# On Ubuntu/Debian
sudo apt-get install libgomp1

# On CentOS/RHEL
sudo yum install libgomp
```

### macOS

**Both Intel (x86_64) and Apple Silicon (arm64) are supported.**

On macOS, you may need to install Xcode Command Line Tools:

```bash
xcode-select --install
```

### Windows

**Windows wheels are available for x86_64 (64-bit).**

If you're building from source on Windows:

1. Install **Visual Studio 2019 or later** with "C++ build tools"
2. Use **Rust stable toolchain** (MSVC variant, not GNU)

```powershell
# Install Rust (if not already installed)
# Download from: https://rustup.rs

# Verify Rust toolchain
rustup show
# Should show: stable-x86_64-pc-windows-msvc

# Build
maturin develop
```

## Troubleshooting

### Common Issues

#### Issue: "No module named 'industryts'"

**Cause**: Installation didn't complete or wrong Python environment.

**Solution**:
```bash
# Check installed packages
pip list | grep industryts

# Reinstall
pip uninstall industryts
pip install industryts
```

#### Issue: "ImportError: cannot import name 'TimeSeriesData'"

**Cause**: Incomplete build or outdated installation.

**Solution**:
```bash
# For source installations, rebuild
make clean
make develop

# For PyPI installations, reinstall
pip install --force-reinstall --no-cache-dir industryts
```

#### Issue: "error: linking with `cc` failed"

**Cause**: Missing C/C++ compiler or linker.

**Solution**:
```bash
# On Ubuntu/Debian
sudo apt-get install build-essential

# On CentOS/RHEL
sudo yum groupinstall "Development Tools"

# On macOS
xcode-select --install
```

#### Issue: Slow performance compared to benchmarks

**Cause**: Using debug build instead of release build.

**Solution**:
```bash
# Always use release build for production/benchmarks
make build
# Or
uv run maturin develop --release
```

### Getting Help

If you encounter issues not covered here:

1. **Check existing issues**: [GitHub Issues](https://github.com/yourusername/industryts/issues)
2. **Search discussions**: [GitHub Discussions](https://github.com/yourusername/industryts/discussions)
3. **Open a new issue**: Provide:
   - Python version (`python --version`)
   - Rust version (`rustc --version`)
   - OS and version
   - Full error message and traceback

## Next Steps

- **[Quick Start](/en/guide/quick-start)** - Your first pipeline
- **[Core Concepts](/en/guide/concepts/timeseries)** - Understand the fundamentals
- **[API Reference](/en/api/timeseries)** - Detailed API documentation

## Upgrading

To upgrade to the latest version:

::: code-group

```bash [pip]
pip install --upgrade industryts
```

```bash [uv]
uv add --upgrade industryts
```

:::

Check the [CHANGELOG](https://github.com/yourusername/industryts/blob/main/CHANGELOG.md) for breaking changes before upgrading.
