# Technical Design: Time Series Processing Library

## Context

Industrial time series data processing needs:
- High performance for large datasets (100K+ rows)
- Type safety to prevent data corruption
- Easy Python integration for data scientists
- Flexible configuration for different use cases
- Comprehensive feature engineering capabilities

**Stakeholders:**
- Data scientists using Python for time series analysis
- Data engineers building processing pipelines
- ML engineers requiring feature engineering

**Constraints:**
- Must use Polars for columnar data operations
- Must provide Python API via PyO3
- Must use uv package manager and maturin for builds
- First column is time column (name auto-detected or configurable)
- Must be portable across different Linux distributions (avoid glibc version conflicts)
- Must use Polars 1.35+ runtime separation features for better compatibility

## Goals / Non-Goals

### Goals
- ✅ Provide 10-100x performance improvement over pandas
- ✅ Support declarative TOML-based pipeline configuration
- ✅ Offer both programmatic and declarative APIs
- ✅ Auto-detect time column from common names (DateTime, tagTime, timestamp, etc.)
- ✅ Comprehensive feature engineering operations
- ✅ Type-safe Rust core with Python-friendly API
- ✅ **Cross-platform portability: Build manylinux-compliant wheels that work on any Linux distribution**
- ✅ **Separate runtime dependencies to avoid glibc version conflicts**

### Non-Goals
- ❌ Built-in ML models (focus on data processing only)
- ❌ Distributed computing (single-machine performance first)
- ❌ Real-time streaming (batch processing focus)
- ❌ GUI or web interface
- ❌ Database connectors (users handle I/O)

## Decisions

### Decision 1: Workspace Structure with Separate Crates

**Choice:** Use Cargo workspace with two crates:
- `industryts-core`: Pure Rust library with Polars operations
- `industryts-py`: PyO3 bindings wrapping the core

**Why:**
- Separates concerns: core logic vs. Python bindings
- Faster compilation during development (can build core without PyO3)
- Easier to test Rust logic independently
- Follows PyO3 best practices (per web search results)
- Enables potential future use of core library in pure Rust projects

**Alternatives Considered:**
- Single crate with PyO3 annotations everywhere
  - ❌ Slower compilation
  - ❌ Harder to test Rust logic
  - ❌ Mixes concerns

### Decision 2: Polars as Core Data Structure

**Choice:** Use `polars::DataFrame` and `polars::LazyFrame` as the underlying data structure.

**Why:**
- Polars is optimized for columnar operations (10-100x faster than pandas)
- Native Rust implementation (no FFI overhead)
- Lazy evaluation support for query optimization
- Arrow-compatible (future interop potential)
- Active development and good documentation

**Alternatives Considered:**
- Arrow DataFusion
  - ❌ More complex API
  - ❌ Overkill for single-machine use case
- Custom implementation
  - ❌ Reinventing the wheel
  - ❌ Months of development time

### Decision 3: Time Column Auto-Detection

**Choice:** Auto-detect time column using heuristics:
1. Check for column named "DateTime", "tagTime", "timestamp", "time", "date" (case-insensitive)
2. If multiple matches, use first column
3. Allow manual override via configuration

**Why:**
- User requirement: "默认第一列为时间列，其列名可能为DateTime、tagTime等"
- Reduces boilerplate configuration
- Follows principle of least surprise
- Still allows manual override when needed

**Alternatives Considered:**
- Always require explicit time column specification
  - ❌ More verbose
  - ❌ Doesn't match user requirement
- Use first column always
  - ❌ Not robust to schema changes

### Decision 4: TOML Configuration Format

**Choice:** Use TOML for pipeline configuration with this structure:

```toml
[pipeline]
name = "my_pipeline"
time_column = "DateTime"  # optional, auto-detected if omitted

[[operations]]
type = "fill_null"
method = "forward"
columns = ["feature1", "feature2"]

[[operations]]
type = "resample"
rule = "1h"
aggregation = "mean"

[[operations]]
type = "lag"
columns = ["feature1"]
periods = [1, 2, 3]
```

**Why:**
- TOML is declarative and human-readable
- Native Rust support via `serde`
- Allows version control of pipeline configurations
- Easy to validate and document
- Natural fit for configuration files

**Alternatives Considered:**
- YAML
  - ❌ More complex parsing
  - ❌ Indentation errors
- JSON
  - ❌ Harder to read/write manually
  - ❌ No comments support

### Decision 5: Dual API Design

**Choice:** Provide two APIs:
1. **Programmatic API** (Python methods):
   ```python
   pipeline = its.Pipeline()
   pipeline.fill_null(method="forward")
   pipeline.resample(rule="1h", agg="mean")
   result = pipeline.process(df)
   ```

2. **Declarative API** (TOML config):
   ```python
   pipeline = its.Pipeline.from_toml("config.toml")
   result = pipeline.process(df)
   ```

**Why:**
- Programmatic API: Better for Jupyter notebooks and exploratory analysis
- Declarative API: Better for production pipelines and reproducibility
- Both APIs share the same underlying implementation
- Users can choose based on their workflow

**Alternatives Considered:**
- Only programmatic API
  - ❌ Doesn't meet TOML requirement
- Only declarative API
  - ❌ Too rigid for exploration

### Decision 6: Operation Categories

**Choice:** Organize operations into 5 categories:
1. **Data Cleaning**: Missing values, outliers, duplicates
2. **Time Operations**: Resampling, rolling windows, alignment
3. **Feature Engineering**: Lags, date features, window stats, differencing
4. **Aggregation**: Group by time, cumulative operations
5. **Transformations**: Scaling, normalization, log/box-cox

**Why:**
- Matches industry-standard time series workflow
- Based on web search results (feature engineering best practices)
- Clear mental model for users
- Easy to document and navigate
- Logical separation of concerns

### Decision 7: PyO3 Wrapper Pattern

**Choice:** Use the wrapper pattern for PyO3 bindings:
- Core types (TimeSeriesData, Pipeline) live in `industryts-core`
- PyO3 wrapper types (PyTimeSeriesData, PyPipeline) in `industryts-py`
- Wrappers delegate to core types without duplicating logic

**Why:**
- Follows Polars' architecture (per web search)
- Keeps core library clean of Python concerns
- Easier to maintain and test
- Better compilation times

**Alternatives Considered:**
- Direct #[pyclass] annotations on core types
  - ❌ Pollutes core library with PyO3 attributes
  - ❌ Slower compilation

### Decision 8: Cross-Platform Compatibility and manylinux Wheels

**Choice:** Build manylinux-compliant wheels using Docker-based builds with maturin and support Polars runtime separation features.

**Strategy:**
1. **Build Environment**: Use official `pyo3/maturin` Docker image (based on manylinux2014)
2. **Target Platform**: manylinux2014 (glibc 2.17+) for maximum compatibility
3. **Polars Runtime**: Leverage Polars 1.35+ runtime options:
   - Use `polars[rtcompat]` for compatibility with older CPUs and cross-platform scenarios
   - Support `polars[rt64]` for large datasets (>2^32 rows)
4. **Build Automation**: Use `cibuildwheel` for multi-platform wheel building
5. **Verification**: Use `auditwheel` to verify manylinux compliance
6. **Alternative Linker**: Support Zig linker (maturin v0.12.7+) as alternative to Docker

**Why:**
- **glibc Compatibility**: Rust 1.64+ requires glibc 2.17 minimum; manylinux2014 provides this baseline
- **Portability Issue Resolution**: User experienced glibc version conflicts (newer glibc on build server → incompatible on target servers)
- **Docker Isolation**: Building in manylinux2014 container ensures old enough glibc for broad compatibility
- **Industry Standard**: manylinux is the PyPI standard for portable Linux wheels
- **Polars 1.35+ Features**: Runtime separation (`rtcompat` extra) explicitly addresses CPU compatibility and cross-platform issues
- **Future-Proof**: Automated CI/CD with cibuildwheel builds for multiple Python versions and platforms

**Technical Implementation:**

```toml
# pyproject.toml
[build-system]
requires = ["maturin>=1.0,<2.0"]
build-backend = "maturin"

[project]
dependencies = [
    "polars[rtcompat]>=1.35.0",  # Runtime compatibility mode
]

[tool.maturin]
features = ["pyo3/abi3-py38"]  # Stable ABI for multi-version compatibility
compatibility = "manylinux2014"  # Target platform
```

```dockerfile
# Dockerfile for reproducible builds
FROM quay.io/pypa/manylinux2014_x86_64

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /io
CMD ["maturin", "build", "--release", "--manylinux", "2014"]
```

```yaml
# .github/workflows/build-wheels.yml (CI/CD example)
- name: Build wheels
  uses: PyO3/maturin-action@v1
  with:
    manylinux: 2014
    args: --release --out dist --find-interpreter

- name: Verify wheel compatibility
  run: auditwheel show dist/*.whl
```

**Alternatives Considered:**

1. **Build on developer's machine directly**
   - ❌ **This is what caused the user's problem**: Newer glibc version makes wheels incompatible with older servers
   - ❌ Not reproducible across different environments
   - ❌ Difficult to ensure consistent builds

2. **Use system Python build tools**
   - ❌ Doesn't guarantee manylinux compliance
   - ❌ Requires manual dependency management

3. **Target newer manylinux standard (e.g., manylinux_2_28)**
   - ❌ Less portable (requires glibc 2.28+)
   - ❌ Won't run on older CentOS/RHEL servers
   - ❌ Defeats the purpose of solving the compatibility issue

4. **Static linking of all dependencies**
   - ❌ Not possible with glibc on Linux
   - ❌ Increases binary size significantly
   - ✅ maturin automatically bundles required shared libraries (e.g., with patchelf)

**Risk Mitigation for glibc Issues:**
- **Always build in manylinux2014 container**, never on local development machine for production wheels
- Verify builds with `auditwheel` before distribution
- Test wheels on multiple target platforms (CentOS 7, Ubuntu 18.04, etc.)
- Document minimum system requirements clearly (glibc 2.17+)

**Polars Runtime Compatibility:**
- Include `polars[rtcompat]` as default dependency for maximum compatibility
- Document option to switch to `polars[rt64]` for large datasets
- Test on different CPU architectures (AVX vs non-AVX)

## Technical Architecture

### Project Structure

**Following Polars Architecture Pattern:**

```
industryts/
├── Cargo.toml                          # Workspace definition
├── pyproject.toml                      # Python package config (maturin)
├── README.md
├── Makefile                            # Build tasks (maturin develop, test, etc.)
├── .github/
│   └── workflows/
│       └── build-wheels.yml            # CI/CD for manylinux wheels
├── Dockerfile                          # manylinux2014 build environment
│
├── crates/                             # Rust crates (Polars pattern)
│   ├── industryts-core/                # Pure Rust core library
│   │   ├── Cargo.toml
│   │   ├── src/
│   │   │   ├── lib.rs
│   │   │   ├── timeseries.rs          # TimeSeriesData struct
│   │   │   ├── operations/            # Operation implementations
│   │   │   │   ├── mod.rs
│   │   │   │   ├── cleaning.rs        # Missing values, outliers
│   │   │   │   ├── time_ops.rs        # Resampling, rolling
│   │   │   │   ├── feature_eng.rs     # Lag, datetime features
│   │   │   │   ├── aggregation.rs     # Group by, cumulative
│   │   │   │   └── transform.rs       # Scaling, normalization
│   │   │   ├── pipeline.rs            # Pipeline orchestration
│   │   │   ├── config.rs              # TOML config structs
│   │   │   ├── error.rs               # Error types
│   │   │   └── utils.rs               # Helper functions
│   │   ├── tests/                     # Rust unit tests
│   │   └── benches/                   # Benchmarks
│   │
│   └── industryts-ops/                 # Optional: Additional operations crate
│       └── ...                         # (for future extensions)
│
├── py-industryts/                      # Python bindings (analogous to py-polars)
│   ├── Cargo.toml                      # PyO3 binding crate config
│   ├── pyproject.toml                  # Python package metadata (symlink to root)
│   ├── Makefile                        # Python-specific build tasks
│   │
│   ├── src/                            # Rust PyO3 binding code
│   │   └── lib.rs                      # PyO3 module definition (_its)
│   │
│   ├── industryts/                     # Python package (installed as 'industryts')
│   │   ├── __init__.py                 # Package entry, re-exports
│   │   ├── _its.pyi                    # Type stubs for Rust binding (_its)
│   │   ├── py.typed                    # PEP 561 marker
│   │   │
│   │   ├── timeseries.py               # TimeSeriesData wrapper class
│   │   ├── pipeline.py                 # Pipeline class
│   │   ├── config.py                   # Configuration helpers
│   │   ├── exceptions.py               # Custom exceptions
│   │   ├── schema.py                   # Schema utilities
│   │   │
│   │   ├── operations/                 # Operation modules
│   │   │   ├── __init__.py
│   │   │   ├── cleaning.py            # Data cleaning operations
│   │   │   ├── time_ops.py            # Time operations
│   │   │   ├── feature_eng.py         # Feature engineering
│   │   │   ├── aggregation.py         # Aggregation operations
│   │   │   └── transform.py           # Transformations
│   │   │
│   │   ├── io/                         # I/O utilities (optional)
│   │   │   ├── __init__.py
│   │   │   └── toml.py                # TOML loading helpers
│   │   │
│   │   └── testing/                    # Testing utilities
│   │       ├── __init__.py
│   │       └── assert_frame.py        # Test helpers
│   │
│   ├── tests/                          # Python tests
│   │   ├── unit/
│   │   │   ├── test_timeseries.py
│   │   │   ├── test_pipeline.py
│   │   │   └── operations/
│   │   │       ├── test_cleaning.py
│   │   │       ├── test_time_ops.py
│   │   │       └── ...
│   │   └── integration/
│   │       └── test_e2e.py
│   │
│   └── docs/                           # Python API docs (optional)
│       └── ...
│
├── examples/                           # Usage examples
│   ├── configs/
│   │   ├── basic_pipeline.toml
│   │   ├── feature_engineering.toml
│   │   └── production_pipeline.toml
│   ├── notebooks/
│   │   ├── 01_quickstart.ipynb
│   │   ├── 02_feature_engineering.ipynb
│   │   └── 03_production_pipeline.ipynb
│   └── scripts/
│       ├── benchmark_vs_pandas.py
│       └── process_large_dataset.py
│
└── docs/                               # Project-level docs
    ├── architecture.md
    ├── api-reference.md
    └── development.md
```

**Key Design Decisions Based on Polars:**

1. **`crates/` Directory**: All Rust crates live here (Polars pattern), making it clear what's Rust code
2. **`py-industryts/` Directory**: Python bindings analogous to `py-polars/`, containing:
   - Rust PyO3 binding code in `src/`
   - Python package in `industryts/` subdirectory
3. **Rust Binding Module**: The PyO3 module is named `_its` (internal), exposed via Python wrappers
4. **Type Stubs**:
   - `_its.pyi`: Type stubs ONLY for the Rust binding module (following Polars `_plr.pyi` pattern)
   - Python `.py` files use inline type hints (no separate `.pyi` needed)
   - `py.typed` marker enables type checking
5. **Modular Python Package**: Operations organized in submodules for clarity
6. **Build Configuration**:
   - Root `pyproject.toml` with maturin backend
   - `Makefile` for common tasks (`make develop`, `make test`, `make build`)
7. **Examples & Tests**: Clearly separated, with notebooks and config examples

### Data Flow

```
Python DataFrame/CSV
        ↓
[Conversion to Polars]
        ↓
TimeSeriesData (Rust)
        ↓
[Time column detection/validation]
        ↓
Pipeline Operations (Rust)
   - Data Cleaning
   - Time Operations
   - Feature Engineering
   - Aggregation
   - Transformations
        ↓
TimeSeriesData (Rust)
        ↓
[Conversion to Python]
        ↓
Python DataFrame/CSV
```

### Key Types

```rust
// crates/industryts-core/src/timeseries.rs
pub struct TimeSeriesData {
    df: DataFrame,
    time_column: String,
    feature_columns: Vec<String>,
}

// crates/industryts-core/src/pipeline.rs
pub struct Pipeline {
    operations: Vec<Box<dyn Operation>>,
    config: PipelineConfig,
}

pub trait Operation: Send + Sync {
    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData>;
    fn name(&self) -> &str;
}

// py-industryts/src/lib.rs (PyO3 binding - exposed as _its module)
#[pymodule]
fn _its(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<PyTimeSeriesData>()?;
    m.add_class::<PyPipeline>()?;
    Ok(())
}

#[pyclass(name = "TimeSeriesData")]
pub struct PyTimeSeriesData {
    inner: TimeSeriesData,
}

#[pyclass(name = "Pipeline")]
pub struct PyPipeline {
    inner: Pipeline,
}
```

```python
# py-industryts/industryts/__init__.py (Python wrapper layer)
from __future__ import annotations
from typing import TYPE_CHECKING

# Import Rust binding (the _its module compiled by PyO3)
from industryts import _its

# Re-export main classes with Python wrappers
from industryts.timeseries import TimeSeriesData
from industryts.pipeline import Pipeline
from industryts.operations import *

__all__ = [
    "TimeSeriesData",
    "Pipeline",
    # ... operation exports
]
```

```python
# py-industryts/industryts/_its.pyi (Type stubs for Rust binding)
"""Type stubs for the _its Rust extension module."""

from __future__ import annotations
from typing import Any

class TimeSeriesData:
    """Rust-backed TimeSeriesData (internal)."""
    def __init__(self, data: Any, time_column: str | None = None) -> None: ...
    def to_polars(self) -> Any: ...
    # ... more methods

class Pipeline:
    """Rust-backed Pipeline (internal)."""
    def __init__(self) -> None: ...
    def process(self, data: TimeSeriesData) -> TimeSeriesData: ...
    # ... more methods
```

```python
# py-industryts/industryts/timeseries.py (Python wrapper with full type hints)
"""TimeSeriesData wrapper with Python-friendly API."""
from __future__ import annotations
from typing import TYPE_CHECKING, Literal

import polars as pl
from industryts import _its

if TYPE_CHECKING:
    from polars import DataFrame

class TimeSeriesData:
    """High-level TimeSeriesData wrapper.

    This wraps the Rust _its.TimeSeriesData with a more Pythonic API.
    """

    def __init__(
        self,
        data: DataFrame | dict[str, list] | str,
        time_column: str | None = None,
        *,
        auto_detect_time: bool = True,
    ) -> None:
        """Initialize TimeSeriesData.

        Args:
            data: Input data (Polars DataFrame, dict, or file path)
            time_column: Name of time column (auto-detected if None)
            auto_detect_time: Auto-detect time column from common names
        """
        # Convert to Polars DataFrame if needed
        if isinstance(data, str):
            df = pl.read_csv(data)
        elif isinstance(data, dict):
            df = pl.DataFrame(data)
        else:
            df = data

        # Delegate to Rust implementation
        self._data = _its.TimeSeriesData(df, time_column)

    def to_polars(self) -> DataFrame:
        """Convert to Polars DataFrame."""
        return self._data.to_polars()

    # ... more methods with full type hints
```

## Risks / Trade-offs

### Risk 1: PyO3 Learning Curve
**Risk:** Team unfamiliar with PyO3 may struggle with lifetime management and Python GIL.

**Mitigation:**
- Use simple wrapper pattern (no complex lifetimes)
- Reference PyO3 examples and pyo3-polars crate
- Start with simple operations, iterate

### Risk 2: Polars API Changes
**Risk:** Polars is still evolving; API changes may require rework.

**Mitigation:**
- Pin to specific Polars version (0.x.y)
- Abstract Polars operations behind our interfaces
- Monitor Polars release notes

### Risk 3: Performance Not Meeting Expectations
**Risk:** Rust implementation might not achieve 10-100x speedup.

**Mitigation:**
- Benchmark early and often
- Use Polars lazy evaluation where possible
- Profile and optimize hot paths
- Document realistic performance expectations

### Risk 4: TOML Configuration Complexity
**Risk:** Complex pipelines may be hard to express in TOML.

**Mitigation:**
- Start with simple operations
- Support programmatic API as fallback
- Allow composing TOML configs
- Provide validation with clear error messages

### Risk 5: Cross-Platform Compatibility and glibc Version Conflicts
**Risk:** Building on a development machine with newer glibc will create wheels that fail on production servers with older glibc versions. This was the user's actual experience.

**Impact:**
- Wheels built on modern Ubuntu/Fedora won't work on CentOS 7 or older RHEL
- ImportError or "version 'GLIBC_X.XX' not found" errors on target systems
- Difficult to debug without access to target environment

**Mitigation:**
- **Mandatory**: Always build production wheels in manylinux2014 Docker container
- Never distribute wheels built on developer machines
- Use `auditwheel` to verify manylinux compliance before any distribution
- Set up CI/CD (GitHub Actions) to automate compliant builds
- Test on oldest supported platform (CentOS 7, glibc 2.17)
- Document minimum glibc requirement (2.17+) clearly in README
- Use Polars `rtcompat` extra for maximum CPU compatibility

## Migration Plan

N/A (new project, no migration needed)

## Open Questions

1. **Should we support custom operations defined in Python?**
   - Pros: More flexible for users
   - Cons: Performance penalty, complexity
   - Decision: Defer to v2.0 if needed

2. **Should we support reading from/writing to databases?**
   - Pros: Convenient for users
   - Cons: Many DB connectors to support, scope creep
   - Decision: Users handle I/O, we focus on processing

3. **Should we support multi-threaded parallel processing?**
   - Pros: Even better performance
   - Cons: Complexity, GIL issues in Python
   - Decision: Polars already parallelizes internally; explicit multi-threading is v2.0

4. **What level of pandas API compatibility should we target?**
   - Pros: Easier migration for pandas users
   - Cons: Limits our API design
   - Decision: Provide familiar method names but don't aim for 100% compatibility

5. **Should we support GPU acceleration?**
   - Pros: Potential for massive speedups
   - Cons: Limited Polars GPU support, complexity, hardware requirements
   - Decision: Out of scope for v1.0; revisit if demand exists
