# Spec Delta: Time Series Core

## ADDED Requirements

### Requirement: Rust Workspace Structure
The project SHALL use a Cargo workspace with two separate crates to maintain clean separation between core logic and Python bindings.

#### Scenario: Core library compilation without Python
- **WHEN** developing or testing core Rust logic
- **THEN** the industryts-core crate SHALL compile independently without PyO3 or Python runtime dependencies

#### Scenario: Python bindings build
- **WHEN** building the Python package
- **THEN** the industryts-py crate SHALL link against industryts-core and expose Python-compatible APIs

### Requirement: Project Structure
The project SHALL organize code into a standard maturin-compatible structure with Rust crates, Python package, examples, and tests.

#### Scenario: Package installation via uv
- **WHEN** running `uv add .` in the project directory
- **THEN** the package SHALL install successfully and import as `import industryts` in Python

#### Scenario: Development workflow
- **WHEN** running `uv run maturin develop`
- **THEN** the package SHALL build and install into the current Python environment for immediate testing

### Requirement: Time Column Detection
The system SHALL automatically detect the time column using common naming patterns while allowing manual override.

#### Scenario: Auto-detection with standard name
- **WHEN** a DataFrame has a column named "DateTime", "tagTime", "timestamp", "time", or "date" (case-insensitive)
- **THEN** the system SHALL use that column as the time index

#### Scenario: Auto-detection with first column
- **WHEN** no standard time column name is found
- **THEN** the system SHALL use the first column as the time index

#### Scenario: Manual override
- **WHEN** user specifies a time_column parameter
- **THEN** the system SHALL use the specified column regardless of auto-detection

### Requirement: Feature Column Identification
The system SHALL treat all non-time columns as feature columns for processing operations.

#### Scenario: Feature columns after time detection
- **WHEN** the time column is identified (auto or manual)
- **THEN** all remaining columns SHALL be classified as feature columns available for operations

### Requirement: Data Type Validation
The system SHALL validate that the time column contains datetime-compatible data.

#### Scenario: Valid datetime column
- **WHEN** the time column contains datetime, date, or Unix timestamp values
- **THEN** the system SHALL successfully create a TimeSeriesData instance

#### Scenario: Invalid time column type
- **WHEN** the time column contains non-temporal data (strings, booleans, etc.)
- **THEN** the system SHALL raise a descriptive error indicating the column type mismatch

### Requirement: PyO3 Data Conversion
The system SHALL provide bidirectional conversion between Python and Rust data structures using PyO3.

#### Scenario: Python to Rust conversion
- **WHEN** user passes a pandas DataFrame or Polars DataFrame to a Rust function
- **THEN** the system SHALL convert it to TimeSeriesData without data loss

#### Scenario: Rust to Python conversion
- **WHEN** a Rust function returns TimeSeriesData
- **THEN** the system SHALL convert it to a Python-compatible Polars DataFrame

### Requirement: Error Handling and Translation
The system SHALL provide clear, actionable error messages in Python for all Rust errors.

#### Scenario: Rust error in Python context
- **WHEN** a Rust operation fails (e.g., column not found, type mismatch)
- **THEN** the system SHALL raise a Python exception with the error message and context

#### Scenario: Stack trace preservation
- **WHEN** an error occurs in Rust code
- **THEN** the Python stack trace SHALL include the Rust function name and error details

### Requirement: Type Hints and IDE Support
The Python package SHALL include comprehensive type hints following PEP 561 for IDE autocomplete and static type checking.

#### Scenario: py.typed marker
- **WHEN** the package is installed
- **THEN** a `py.typed` marker file SHALL be present in the package root

#### Scenario: Rust binding stub file
- **WHEN** users import the internal _its module
- **THEN** an `_its.pyi` stub file SHALL provide type information for the Rust binding

#### Scenario: Python wrapper type hints
- **WHEN** users import industryts.TimeSeriesData or industryts.Pipeline
- **THEN** inline type hints SHALL be present in the .py source files

#### Scenario: IDE autocomplete
- **WHEN** user types `industryts.` in an IDE
- **THEN** the IDE SHALL show available classes, methods, and their signatures

#### Scenario: Static type checking with mypy
- **WHEN** running mypy on code using industryts
- **THEN** the type checker SHALL successfully validate types without errors (except where explicitly marked with type: ignore)

#### Scenario: Static type checking with pyright
- **WHEN** running pyright on code using industryts
- **THEN** the type checker SHALL successfully validate types without errors (except where explicitly marked with type: ignore)

#### Scenario: Generic type support
- **WHEN** users use type annotations like `DataFrame`, `Literal`, `Optional`
- **THEN** type checkers SHALL correctly infer and validate types

### Requirement: Build System Configuration
The project SHALL use maturin as the build backend configured in pyproject.toml.

#### Scenario: Wheel building
- **WHEN** running `maturin build`
- **THEN** the system SHALL produce a platform-specific wheel file (.whl)

#### Scenario: Source distribution
- **WHEN** running `maturin sdist`
- **THEN** the system SHALL produce a source distribution (.tar.gz)

### Requirement: Python Version Compatibility
The package SHALL support Python 3.8+ using PyO3's stable ABI (abi3).

#### Scenario: Installation on Python 3.8
- **WHEN** installing the package on Python 3.8
- **THEN** the package SHALL install and import successfully

#### Scenario: Installation on Python 3.12
- **WHEN** installing the package on Python 3.12
- **THEN** the package SHALL install and import successfully using the same wheel

### Requirement: Documentation and Examples
The project SHALL include comprehensive README, API documentation, and usage examples.

#### Scenario: Quick start guide
- **WHEN** a new user reads README.md
- **THEN** they SHALL be able to install the package and run a basic example within 5 minutes

#### Scenario: Example notebooks
- **WHEN** exploring the examples/ directory
- **THEN** users SHALL find Jupyter notebooks demonstrating common use cases

### Requirement: Cross-Platform Wheel Compatibility
The package SHALL build manylinux-compliant wheels that work across different Linux distributions without glibc version conflicts.

#### Scenario: Build in manylinux2014 container
- **WHEN** building production wheels
- **THEN** the build MUST occur in a manylinux2014 Docker container (not on developer's machine)

#### Scenario: Wheel verification
- **WHEN** a wheel is built
- **THEN** it SHALL pass `auditwheel` verification for manylinux2014 compliance

#### Scenario: Installation on older systems
- **WHEN** installing the wheel on CentOS 7 or systems with glibc 2.17+
- **THEN** the package SHALL install and import successfully without glibc version errors

#### Scenario: Installation on newer systems
- **WHEN** installing the wheel on Ubuntu 20.04+ or Fedora with newer glibc
- **THEN** the package SHALL install and import successfully

### Requirement: Polars Runtime Compatibility
The package SHALL use Polars 1.35+ with runtime compatibility features to ensure portability across different CPU architectures.

#### Scenario: Default runtime compatibility
- **WHEN** installing the package
- **THEN** it SHALL depend on `polars[rtcompat]>=1.35.0` for maximum compatibility

#### Scenario: Old CPU compatibility
- **WHEN** running on CPUs without AVX support (pre-2011)
- **THEN** the package SHALL work correctly using Polars rtcompat mode

#### Scenario: Large dataset support
- **WHEN** users need to process datasets with >2^32 rows
- **THEN** documentation SHALL explain how to install with `polars[rt64]` extra

### Requirement: Build Automation and CI/CD
The project SHALL include automated build pipelines for reproducible, compliant wheel building.

#### Scenario: GitHub Actions workflow
- **WHEN** code is pushed to the repository
- **THEN** CI SHALL automatically build wheels using maturin-action with manylinux2014

#### Scenario: Multi-platform builds
- **WHEN** creating a release
- **THEN** CI SHALL build wheels for Linux (x86_64, aarch64), macOS, and Windows

#### Scenario: Build verification
- **WHEN** wheels are built in CI
- **THEN** `auditwheel show` SHALL be run to verify compliance

### Requirement: Minimum System Requirements Documentation
The package SHALL clearly document minimum system requirements.

#### Scenario: README requirements section
- **WHEN** users read README.md
- **THEN** minimum glibc version (2.17+) SHALL be clearly stated

#### Scenario: Platform compatibility table
- **WHEN** users check compatibility
- **THEN** documentation SHALL list tested platforms (CentOS 7+, Ubuntu 18.04+, etc.)

### Requirement: Stable ABI Support
The package SHALL use PyO3's stable ABI (abi3) for compatibility across Python versions.

#### Scenario: Single wheel for multiple Python versions
- **WHEN** building with abi3-py38 feature
- **THEN** the same wheel SHALL work on Python 3.8, 3.9, 3.10, 3.11, and 3.12

#### Scenario: No recompilation needed
- **WHEN** users upgrade Python minor version
- **THEN** the installed wheel SHALL continue to work without reinstallation

