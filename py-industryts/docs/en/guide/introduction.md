# Introduction

Industryts is a high-performance time series processing library designed specifically for industrial data. It combines the power of Rust with the ease of Python, providing 10-100x faster data processing compared to pandas.

## Core Features

### 🚀 Blazing Fast Performance
- Built on Rust with Polars' columnar storage
- Zero-copy data transfer
- Parallel processing capabilities
- 10-100x faster than pandas for typical time series operations

### 🐍 Python-Friendly
- Pythonic API design
- Full type hints
- Similar programming patterns to pandas
- Seamless integration with Python data science ecosystem

### 📊 Comprehensive Operations
- Data cleaning and preprocessing
- Time series resampling
- Feature engineering
- Data transformations and aggregations
- All operations optimized for industrial data

### ⚙️ Dual API Design
- **Programmatic API**: Flexible Python API for interactive development
- **Declarative API**: TOML-based configuration for production and reproducible workflows

## Architecture

```
┌─────────────────────────────────────────┐
│         Python API Layer                │
│  (industryts Python Package)            │
├─────────────────────────────────────────┤
│         PyO3 Bindings                   │
│  (Python ↔ Rust Communication)          │
├─────────────────────────────────────────┤
│      Rust Core Engine                   │
│  (industryts-core)                      │
├─────────────────────────────────────────┤
│   Polars DataFrame Engine               │
│  (Columnar Storage + Parallel)          │
└─────────────────────────────────────────┘
```

## Main Components

### TimeSeriesData
Core container for time series data, based on Polars DataFrame.

```python
import industryts as its

# Load from CSV
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Create from Polars DataFrame
import polars as pl
df = pl.read_csv("data.csv")
data = its.TimeSeriesData(df)
```

### Pipeline
Data processing pipeline with method chaining and TOML configuration support.

```python
# Programmatic API
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
pipeline.standardize(columns=["temperature", "pressure"])

# Process data
result = pipeline.process(data)
```

### Operations
Various data processing operations including:
- Data Cleaning: `fill_null`, `drop_null`, `clip`
- Time Operations: `resample`, `lag`, `rolling`
- Feature Engineering: `standardize`, `normalize`, `one_hot_encode`
- Aggregation: `groupby`, `aggregate`

## Use Cases

### Sensor Data Processing
- Real-time data cleaning and preprocessing
- Feature extraction and engineering
- Anomaly detection

### Industrial Monitoring
- Equipment performance analysis
- Predictive maintenance
- Energy optimization

### Financial Time Series
- Stock data analysis
- Technical indicator calculation
- Risk assessment

### IoT Data
- Large-scale data processing
- Real-time stream processing
- Multi-source data fusion

## Performance Comparison

Benchmarks on 1M rows × 10 columns dataset:

| Operation | pandas | industryts | Speedup |
|-----------|--------|------------|---------|
| Resample | 2.3s | 0.05s | 46x |
| Rolling Mean | 1.8s | 0.03s | 60x |
| Lag Features | 1.2s | 0.02s | 60x |
| Full Pipeline | 12.5s | 0.15s | 83x |

## Next Steps

- [Installation Guide](/en/guide/installation) - Detailed installation instructions
- [Quick Start](/en/guide/quick-start) - Create your first processing pipeline
- [Core Concepts](/en/guide/concepts/timeseries) - Deep dive into TimeSeriesData
