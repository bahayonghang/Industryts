# Installation Guide

This guide covers how to install the Industryts Python package.

## System Requirements

- **Python**: 3.12+
- **Operating System**: Linux, macOS, Windows
- **Memory**: Minimum 2GB RAM (4GB+ recommended)

## Install from PyPI

The easiest way to install is using pip:

```bash
pip install industryts
```

Or using uv (recommended):

```bash
uv add industryts
```

## Install from Source

If you want to build from source or contribute to development:

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/industryts.git
cd industryts
```

### 2. Install Dependencies

#### Install Rust (if not already installed)

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### Install uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 3. Build and Install

#### Development Mode (recommended for development)

```bash
cd py-industryts
uv run maturin develop
```

#### Release Mode

```bash
cd py-industryts
uv run maturin build --release
pip install target/wheels/*.whl
```

## Verify Installation

After installation, verify it worked:

```python
import industryts as its

print(f"Industryts version: {its.__version__}")

# Create simple time series data
import polars as pl
from datetime import datetime

df = pl.DataFrame({
    "DateTime": pl.datetime_range(
        start=datetime(2024, 1, 1),
        end=datetime(2024, 1, 10),
        interval="1d",
        eager=True
    ),
    "value": [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
})

data = its.TimeSeriesData(df)
print(f"Successfully created TimeSeriesData: {len(data)} rows")
```

## Troubleshooting

### ImportError: No module named 'industryts'

Make sure the package is properly installed:

```bash
# Check installation
pip list | grep industryts

# Reinstall
pip install --force-reinstall industryts
```

### Compilation Errors (when installing from source)

Make sure you have the Rust toolchain installed:

```bash
rustc --version
cargo --version
```

If not installed, run:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Version Incompatibility

Ensure your Python version is 3.12+:

```bash
python --version
```

## Optional Dependencies

### For Jupyter Notebooks

```bash
pip install jupyter ipython
```

### For Data Visualization

```bash
pip install matplotlib seaborn plotly
```

### For Additional Data Format Support

```bash
pip install pyarrow openpyxl
```

## Next Steps

- [Quick Start](/en/guide/quick-start) - Create your first processing pipeline
- [API Reference](/en/api/core) - Complete API documentation
- [Examples](/en/examples/basic) - Real-world usage examples
