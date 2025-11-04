# Introduction

## What is Industryts?

Industryts is a high-performance time series processing library specifically designed for industrial data. Built with **Rust** and powered by **Polars**, it delivers **10-100x performance improvements** over pandas while maintaining a Python-friendly API.

## Why Industryts?

### The Challenge

Industrial time series data presents unique challenges:

- **Scale**: Millions of rows from sensors and equipment
- **Frequency**: High-frequency data requiring efficient downsampling
- **Missing Data**: Sensor failures and communication issues
- **Feature Engineering**: Complex lag features and transformations
- **Production Requirements**: Fast, memory-efficient, reproducible pipelines

Traditional tools like pandas struggle with these requirements, especially at scale.

### The Solution

Industryts addresses these challenges through:

1. **Rust-Powered Core**: Type-safe, memory-efficient processing engine
2. **Polars Integration**: Columnar data format for optimal performance
3. **Zero-Copy Architecture**: Efficient data transfer between Python and Rust
4. **Dual API Design**: Programmatic flexibility and declarative reproducibility

## Key Features

### ⚡ Exceptional Performance

```python
# Process 1M rows in milliseconds, not seconds
data = its.TimeSeriesData.from_csv("sensors.csv")  # 1M rows × 10 features
pipeline.process(data)  # ~150ms vs ~12.5s in pandas (83x faster)
```

Performance gains come from:
- **Columnar Processing**: Polars' Arrow-based format enables SIMD operations
- **Rust Zero-Cost Abstractions**: No runtime overhead from safety guarantees
- **Lazy Evaluation**: Optimize entire pipeline before execution (planned)

### 🦀 Type Safety

Rust's type system catches errors at compile time:

```rust
// Rust core - type errors caught during development
pub struct LagOperation {
    pub columns: Option<Vec<String>>,
    pub periods: Vec<i64>,  // Must be Vec<i64>, not Vec<f64>
}
```

Python API includes full type hints:

```python
def lag(
    self,
    columns: Optional[List[str]] = None,
    periods: List[int] = [1]
) -> None:
    """Create lag features with type-checked parameters."""
```

### 🐍 Python-Friendly API

Familiar patterns for pandas users:

```python
# Load data (similar to pandas)
data = its.TimeSeriesData.from_csv("data.csv")

# Inspect data
print(data.head())
print(data.describe())

# Build pipeline (method chaining)
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
```

### ⚙️ Declarative Pipelines

Define pipelines in TOML for reproducibility:

```toml
[pipeline]
name = "production_pipeline"
time_column = "DateTime"

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
columns = ["temperature"]
periods = [1, 2, 3]
```

Benefits:
- **Version Control**: Track pipeline changes in git
- **Code Review**: Review data processing logic separately
- **Reproducibility**: Identical results across environments
- **Documentation**: Self-documenting pipeline structure

## Architecture Overview

Industryts follows a three-layer architecture inspired by Polars:

```
┌─────────────────────────────────────────────────────────┐
│  Python API Layer (py-industryts/industryts/)           │
│  - TimeSeriesData, Pipeline classes                     │
│  - I/O helpers (CSV, Parquet)                           │
│  - Type hints and documentation                         │
└────────────────────┬────────────────────────────────────┘
                     │  pyo3-polars (zero-copy)
┌────────────────────▼────────────────────────────────────┐
│  PyO3 Bindings (py-industryts/src/)                     │
│  - Python-Rust bridge via PyO3                          │
│  - DataFrame conversion                                 │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│  Rust Core (crates/industryts-core/)                    │
│  - TimeSeriesData struct                                │
│  - Operation trait and implementations                  │
│  - Pipeline orchestration                               │
│  - Polars DataFrame operations                          │
└─────────────────────────────────────────────────────────┘
```

### Key Design Principles

1. **Separation of Concerns**
   - Pure Rust core library for business logic
   - Separate Python bindings for API ergonomics
   - Clear boundaries between layers

2. **Zero-Copy Data Transfer**
   - `pyo3-polars` enables efficient DataFrame sharing
   - No serialization overhead between Python and Rust
   - Direct memory access where possible

3. **Trait-Based Operations**
   - `Operation` trait for composable pipelines
   - Type-safe operation chaining
   - Easy to extend with custom operations

4. **Configuration-Driven**
   - TOML-based declarative pipelines
   - Reproducible workflows
   - Version-controlled data processing

## When to Use Industryts

### ✅ Ideal Use Cases

- **Industrial IoT**: Sensor data from manufacturing, energy, utilities
- **Large-Scale Time Series**: Millions of rows requiring fast processing
- **Feature Engineering**: Complex lag features for ML pipelines
- **Production Pipelines**: High-performance, reproducible workflows
- **Real-Time Processing**: Low-latency data transformation

### ⚠️ Consider Alternatives

- **Small Datasets**: pandas is fine for <100K rows
- **Complex Statistical Models**: Use statsmodels, scikit-learn
- **Time Series Forecasting**: Use Prophet, statsforecast, or specialized libraries
- **Ad-Hoc Analysis**: pandas' flexibility may be more convenient

## Comparison with Other Tools

### vs. pandas

| Feature | pandas | Industryts |
|---------|--------|------------|
| Performance | Baseline | 10-100x faster |
| Memory Usage | Higher | Lower (columnar) |
| Type Safety | Runtime | Compile-time (core) |
| API Learning Curve | Familiar | Similar |
| Lazy Evaluation | No | Planned |
| Declarative Pipelines | No | Yes (TOML) |

### vs. Polars

| Feature | Polars | Industryts |
|---------|--------|------------|
| General Purpose | Yes | Time Series Focus |
| Built-in Time Ops | Basic | Comprehensive |
| Industrial Focus | No | Yes |
| Declarative Pipelines | No | Yes (TOML) |
| API | Polars-style | pandas-like |

### vs. Dask

| Feature | Dask | Industryts |
|---------|------|------------|
| Distributed | Yes | No (single-node) |
| Performance (single-node) | Slower | Faster |
| Setup Complexity | Higher | Lower |
| Time Series Operations | Limited | Comprehensive |

## What's Next?

- **[Installation](/en/guide/installation)** - Get Industryts installed
- **[Quick Start](/en/guide/quick-start)** - Your first pipeline
- **[Core Concepts](/en/guide/concepts/timeseries)** - Understand the architecture
- **[API Reference](/en/api/timeseries)** - Detailed API documentation
