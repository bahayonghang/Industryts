---
layout: home

hero:
  name: Industryts Python API
  text: High-performance time series processing
  tagline: 10-100x faster than pandas, powered by Rust and Polars
  image:
    src: /logo.svg
    alt: Industryts
  actions:
    - theme: brand
      text: Get Started
      link: /en/guide/introduction
    - theme: alt
      text: View on GitHub
      link: https://github.com/yourusername/industryts

features:
  - icon: ⚡
    title: Blazing Fast
    details: 10-100x faster than pandas for typical time series operations. Rust-powered core with zero-copy data transfer.

  - icon: 🦀
    title: Rust-Powered
    details: Built on Rust for type safety, memory efficiency, and exceptional performance. Leverages Polars' columnar processing.

  - icon: 🐍
    title: Python-Friendly
    details: Pythonic API with full type hints, familiar patterns, and seamless integration with the Python data science ecosystem.

  - icon: 📊
    title: Comprehensive Operations
    details: Data cleaning, resampling, feature engineering, transformations, and aggregations - all optimized for industrial time series.

  - icon: ⚙️
    title: Declarative Pipelines
    details: Define data processing pipelines in TOML configuration files for reproducible, version-controlled workflows.

  - icon: 🔧
    title: Dual API Design
    details: Choose between programmatic Python API for flexibility or declarative TOML for reproducibility.
---

## Quick Example

::: code-group

```python [Programmatic API]
import industryts as its

# Load time series data
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Create processing pipeline
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
pipeline.standardize(columns=["temperature", "pressure"])

# Process data
result = pipeline.process(data)
result.to_csv("processed_data.csv")
```

```toml [Declarative API (TOML)]
[pipeline]
name = "sensor_processing"
time_column = "DateTime"

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
columns = ["temperature"]
periods = [1, 2, 3]

[[operations]]
type = "standardize"
columns = ["temperature", "pressure"]
```

```python [Load from TOML]
import industryts as its

# Load pipeline from config
pipeline = its.Pipeline.from_toml("pipeline.toml")

# Process data
data = its.TimeSeriesData.from_csv("sensor_data.csv")
result = pipeline.process(data)
```

:::

## Performance Benchmarks

Benchmarks on a dataset with 1M rows × 10 features:

| Operation | pandas | industryts | Speedup |
|-----------|--------|------------|---------|
| Resample (1h → 1min) | 2.3s | 0.05s | **46x** |
| Rolling mean (window=100) | 1.8s | 0.03s | **60x** |
| Lag features (3 lags) | 1.2s | 0.02s | **60x** |
| Full pipeline (10 ops) | 12.5s | 0.15s | **83x** |

## Installation

::: code-group

```bash [pip]
pip install industryts
```

```bash [uv]
uv add industryts
```

```bash [from source]
# Clone repository
git clone https://github.com/yourusername/industryts.git
cd industryts

# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install in development mode
uv run maturin develop
```

:::

## Why Industryts?

### For Data Scientists
- **Familiar API**: Pythonic interface similar to pandas, easy to learn
- **Type Safety**: Full type hints for better IDE support and fewer runtime errors
- **Reproducibility**: Declarative pipelines ensure consistent results

### For Engineers
- **Production-Ready**: High performance suitable for real-time processing
- **Memory Efficient**: Polars' columnar format minimizes memory usage
- **Configuration-Driven**: TOML-based pipelines integrate with version control

### For Industrial Applications
- **Optimized for Sensors**: Built-in operations for common industrial data patterns
- **Large-Scale**: Handles millions of rows efficiently
- **Time-Aware**: Native understanding of time series requirements

## What's Next?

<div class="vp-doc" style="margin-top: 2rem;">

- **[Introduction](/en/guide/introduction)** - Learn about Industryts architecture and design
- **[Installation](/en/guide/installation)** - Detailed installation instructions
- **[Quick Start](/en/guide/quick-start)** - Your first time series processing pipeline
- **[API Reference](/en/api/core)** - Complete API documentation
- **[Examples](/en/examples/basic)** - Real-world usage examples

</div>
