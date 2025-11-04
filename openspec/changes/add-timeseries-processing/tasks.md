# Implementation Tasks

## 1. Project Setup and Structure (Following Polars Pattern)
- [ ] 1.1 Initialize root directory with Cargo.toml workspace
- [ ] 1.2 Create `crates/` directory for Rust crates
- [ ] 1.3 Create `crates/industryts-core/` with Cargo.toml
- [ ] 1.4 Create `py-industryts/` directory for Python bindings
- [ ] 1.5 Create `py-industryts/Cargo.toml` for PyO3 binding crate
- [ ] 1.6 Configure root `pyproject.toml` with maturin build-system
- [ ] 1.7 Set up `uv` package manager configuration
- [ ] 1.8 Create `py-industryts/industryts/` Python package structure
- [ ] 1.9 Create Makefile for common tasks (develop, test, build)
- [ ] 1.10 Set up .gitignore for Rust and Python

## 2. Type Hints and Stubs (PEP 561 Compliance)
- [ ] 2.1 Add `py.typed` marker file to `py-industryts/industryts/`
- [ ] 2.2 Create `_its.pyi` stub file for Rust binding module
- [ ] 2.3 Add type hints to all Python wrapper modules (.py files)
- [ ] 2.4 Configure pyproject.toml to include py.typed in distribution
- [ ] 2.5 Test type checking with mypy
- [ ] 2.6 Test type checking with pyright
- [ ] 2.7 Verify IDE autocomplete (VS Code, PyCharm)
- [ ] 2.8 Add type: ignore comments where necessary for Rust bindings

## 3. Core Data Structures (Rust)
- [ ] 3.1 Implement TimeSeriesData wrapper around Polars DataFrame
- [ ] 3.2 Add time column detection and validation logic
- [ ] 3.3 Implement column type inference for features
- [ ] 3.4 Create error types for time series operations
- [ ] 3.5 Add PyO3 conversions for TimeSeriesData (Python ↔ Rust)

## 4. Data Cleaning Operations
- [ ] 4.1 Implement missing value handling (forward fill, backward fill, interpolate)
- [ ] 4.2 Implement outlier detection (IQR, Z-score methods)
- [ ] 4.3 Implement outlier handling (capping, removal)
- [ ] 4.4 Implement duplicate removal with time-based logic
- [ ] 4.5 Add PyO3 bindings for all cleaning operations

## 5. Time Operations
- [ ] 5.1 Implement time index validation and setting
- [ ] 5.2 Implement resampling (upsample, downsample with aggregation)
- [ ] 5.3 Implement rolling window operations (mean, std, min, max, sum)
- [ ] 5.4 Implement time alignment for multiple series
- [ ] 5.5 Implement time-based filtering (date ranges, time of day)
- [ ] 5.6 Add PyO3 bindings for all time operations

## 6. Feature Engineering
- [ ] 6.1 Implement lag features generation (single and multiple lags)
- [ ] 6.2 Implement date/time feature extraction (hour, day, month, weekday, etc.)
- [ ] 6.3 Implement differencing (first-order, seasonal)
- [ ] 6.4 Implement window statistics (moving average, moving std, etc.)
- [ ] 6.5 Implement cyclical encoding (sin/cos for time features)
- [ ] 6.6 Implement Fourier transform features (optional)
- [ ] 6.7 Add PyO3 bindings for all feature engineering operations

## 7. Aggregation Operations
- [ ] 7.1 Implement group by with time bins (hourly, daily, weekly, etc.)
- [ ] 7.2 Implement cumulative operations (cumsum, cumprod, cummax, cummin)
- [ ] 7.3 Implement custom aggregation functions support
- [ ] 7.4 Implement expanding window aggregations
- [ ] 7.5 Add PyO3 bindings for all aggregation operations

## 8. Transformation Operations
- [ ] 8.1 Implement standardization (z-score normalization)
- [ ] 8.2 Implement min-max scaling
- [ ] 8.3 Implement log transformation
- [ ] 8.4 Implement Box-Cox transformation
- [ ] 8.5 Implement robust scaling (using median and IQR)
- [ ] 8.6 Add PyO3 bindings for all transformation operations

## 9. Pipeline Configuration System
- [ ] 9.1 Design TOML configuration schema for pipelines
- [ ] 9.2 Implement TOML parser using serde
- [ ] 9.3 Implement Pipeline struct that holds operation sequence
- [ ] 9.4 Implement operation factory from TOML config
- [ ] 9.5 Implement pipeline execution engine
- [ ] 9.6 Add validation for pipeline configurations
- [ ] 9.7 Add PyO3 bindings for Pipeline (from_toml, process methods)

## 10. Python API Design
- [ ] 10.1 Create Python __init__.py with clean API surface
- [ ] 10.2 Implement TimeSeriesData wrapper class in timeseries.py
- [ ] 10.3 Implement Pipeline class wrapper in pipeline.py
- [ ] 10.4 Create operation submodules (operations/cleaning.py, etc.)
- [ ] 10.5 Add type hints for all Python functions
- [ ] 10.6 Create comprehensive docstrings following NumPy style
- [ ] 10.7 Implement error handling and exception translation

## 11. Testing
- [ ] 11.1 Write Rust unit tests for core operations
- [ ] 11.2 Write Rust integration tests for pipeline execution
- [ ] 11.3 Write Python unit tests using pytest
- [ ] 11.4 Write Python integration tests with sample datasets
- [ ] 11.5 Add property-based tests (hypothesis/proptest)
- [ ] 11.6 Add benchmark tests comparing to pandas
- [ ] 11.7 Test type checking integration (mypy, pyright)

## 12. Documentation and Examples
- [ ] 12.1 Create README.md with quick start guide
- [ ] 12.2 Create example TOML configuration files
- [ ] 12.3 Create Python usage examples (Jupyter notebooks)
- [ ] 12.4 Document all configuration options
- [ ] 12.5 Create performance comparison benchmarks
- [ ] 12.6 Write API reference documentation
- [ ] 12.7 Document type checking setup for users

## 13. Build and Distribution
- [ ] 13.1 Configure maturin for wheel building with manylinux2014 target
- [ ] 13.2 Create Dockerfile for reproducible manylinux2014 builds
- [ ] 13.3 Set up GitHub Actions workflow with maturin-action
- [ ] 13.4 Configure cibuildwheel for multi-platform builds
- [ ] 13.5 Add auditwheel verification to build pipeline
- [ ] 13.6 Test installation via uv and pip on multiple platforms
- [ ] 13.7 Test wheels on CentOS 7 (glibc 2.17) for compatibility
- [ ] 13.8 Test wheels on Ubuntu 18.04, 20.04, 22.04
- [ ] 13.9 Configure Polars dependency with rtcompat extra
- [ ] 13.10 Document build process and minimum system requirements
- [ ] 13.11 Create development setup instructions
- [ ] 13.12 Prepare for PyPI distribution (optional)

## 14. Cross-Platform Compatibility Verification
- [ ] 14.1 Verify wheel builds in manylinux2014 Docker container
- [ ] 14.2 Test on systems with glibc 2.17 (minimum requirement)
- [ ] 14.3 Test on systems with newer glibc (2.28+, 2.31+)
- [ ] 14.4 Test on different CPU architectures (with/without AVX)
- [ ] 14.5 Verify Polars rtcompat mode functionality
- [ ] 14.6 Test stable ABI compatibility across Python 3.8-3.12
- [ ] 14.7 Document tested platform matrix in README
