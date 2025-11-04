# Proposal: Add Time Series Processing Library

## Why

Industrial time series data processing requires high-performance, type-safe operations that can handle large datasets efficiently. Python-based solutions (pandas, numpy) are slow for large-scale data, while pure Python libraries lack the performance needed for production workloads. A Rust-based library using Polars provides 10-100x performance improvements while maintaining a Python-friendly API.

This library enables data scientists and engineers to process time series data with:
- High-performance columnar processing via Polars
- Type-safe operations through Rust
- Easy Python integration via PyO3
- Declarative pipeline configuration via TOML
- Comprehensive feature engineering capabilities

## What Changes

- **NEW**: Create a Rust-based time series processing library (`industryts`)
- **NEW**: Implement PyO3 bindings for Python integration
- **NEW**: Build project structure using maturin and uv package manager
- **NEW**: Implement time series processing operations in 5 categories:
  - Data Cleaning (missing values, outliers, duplicates)
  - Time Operations (resampling, rolling windows, time alignment)
  - Feature Engineering (lag features, date/time features, window statistics)
  - Aggregation (group by time bins, cumulative operations)
  - Transformations (normalization, scaling, log/box-cox transforms)
- **NEW**: Create TOML-based pipeline configuration system
- **NEW**: Provide dual API: programmatic Python API and declarative TOML config
- **NEW**: **Cross-platform portability: Build manylinux2014-compliant wheels to avoid glibc version conflicts**
- **NEW**: **Use Polars 1.35+ with runtime compatibility mode (`rtcompat`) for maximum portability**
- **NEW**: **Set up Docker-based reproducible builds and CI/CD for multi-platform wheel distribution**

## Impact

### Affected Specs
- `timeseries-core`: Core library architecture, project structure, Python bindings
- `timeseries-processing`: All time series processing operations and categories
- `pipeline-config`: TOML configuration format and pipeline execution system

### Affected Code
This is a new project, so all code will be net-new:
- `Cargo.toml`: Rust workspace configuration
- `pyproject.toml`: Python package configuration
- `industryts-core/`: Core Rust library with Polars-based operations
- `industryts-py/`: PyO3 Python bindings
- `python/industryts/`: Python package structure
- `examples/`: Example usage and TOML configurations
- `tests/`: Rust and Python test suites

### Performance Impact
Expected 10-100x performance improvement over pandas-based solutions for typical time series operations on datasets with 100K+ rows.

### Breaking Changes
None (new project).
