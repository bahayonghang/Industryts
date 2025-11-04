# Spec Delta: Pipeline Configuration

## ADDED Requirements

### Requirement: TOML Configuration Format
The system SHALL support TOML-based configuration files for defining time series processing pipelines.

#### Scenario: Basic pipeline config
- **WHEN** user creates a TOML file with pipeline operations
- **THEN** the system SHALL parse and validate the configuration

#### Scenario: Invalid TOML syntax
- **WHEN** TOML file contains syntax errors
- **THEN** the system SHALL raise a descriptive error indicating the line and issue

### Requirement: Pipeline Metadata
Pipeline configurations SHALL include metadata about the pipeline name and optional time column specification.

#### Scenario: Named pipeline
- **WHEN** config includes [pipeline] section with name = "my_pipeline"
- **THEN** the pipeline SHALL be identifiable by that name

#### Scenario: Time column override
- **WHEN** config specifies time_column = "custom_time"
- **THEN** the system SHALL use that column instead of auto-detection

### Requirement: Operation Sequence
Pipeline configurations SHALL define operations as an ordered array that executes sequentially.

#### Scenario: Sequential execution
- **WHEN** config defines [[operations]] with multiple entries
- **THEN** operations SHALL execute in the order they appear in the config

#### Scenario: Operation dependencies
- **WHEN** operation B depends on output of operation A
- **THEN** operation A SHALL complete before operation B starts

### Requirement: Operation Type Specification
Each operation SHALL specify its type matching available operation categories.

#### Scenario: Data cleaning operation
- **WHEN** operation type = "fill_null"
- **THEN** the fill_null operation SHALL be instantiated

#### Scenario: Invalid operation type
- **WHEN** operation type is not recognized
- **THEN** the system SHALL raise an error listing valid operation types

### Requirement: Operation Parameters
Operations SHALL accept parameters specific to their type via TOML key-value pairs.

#### Scenario: Method parameter
- **WHEN** fill_null operation specifies method = "forward"
- **THEN** forward fill method SHALL be used

#### Scenario: Numeric parameters
- **WHEN** operation specifies window = 10
- **THEN** the window size SHALL be set to 10

#### Scenario: Array parameters
- **WHEN** lag operation specifies periods = [1, 2, 3]
- **THEN** lags 1, 2, and 3 SHALL be created

### Requirement: Column Selection in Config
Operations SHALL support column selection via TOML configuration.

#### Scenario: Specific columns
- **WHEN** operation specifies columns = ["temp", "pressure"]
- **THEN** only those columns SHALL be processed

#### Scenario: All columns
- **WHEN** operation omits columns parameter
- **THEN** all feature columns SHALL be processed by default

### Requirement: Configuration Validation
The system SHALL validate pipeline configurations before execution.

#### Scenario: Complete validation
- **WHEN** user loads a TOML config file
- **THEN** all operations, parameters, and column references SHALL be validated

#### Scenario: Missing required parameter
- **WHEN** operation is missing a required parameter
- **THEN** validation SHALL fail with error indicating the missing parameter

#### Scenario: Type mismatch
- **WHEN** parameter value has wrong type (e.g., string instead of number)
- **THEN** validation SHALL fail with error indicating expected type

### Requirement: Programmatic Pipeline API
The system SHALL provide a Python API for building pipelines programmatically.

#### Scenario: Method chaining
- **WHEN** user calls pipeline.fill_null().resample().lag()
- **THEN** operations SHALL be added to the pipeline in order

#### Scenario: Explicit operation addition
- **WHEN** user calls pipeline.add_operation(op_type, **params)
- **THEN** the operation SHALL be appended to the pipeline

### Requirement: Pipeline Execution
Pipelines SHALL execute all operations on input data and return transformed data.

#### Scenario: Successful execution
- **WHEN** user calls pipeline.process(dataframe)
- **THEN** all operations SHALL execute and return the final transformed DataFrame

#### Scenario: Execution error
- **WHEN** an operation fails during execution (e.g., column not found)
- **THEN** execution SHALL stop and raise an error with operation name and details

### Requirement: Pipeline from TOML
The system SHALL load pipelines from TOML files via a factory method.

#### Scenario: Load from file path
- **WHEN** user calls Pipeline.from_toml("config.toml")
- **THEN** the pipeline SHALL be constructed from the file contents

#### Scenario: Load from string
- **WHEN** user calls Pipeline.from_toml_string(toml_content)
- **THEN** the pipeline SHALL be constructed from the string

### Requirement: Pipeline Serialization
Pipelines SHALL be serializable back to TOML format.

#### Scenario: Save to TOML
- **WHEN** user calls pipeline.to_toml("output.toml")
- **THEN** the current pipeline configuration SHALL be written to the file

#### Scenario: Programmatic to declarative
- **WHEN** user builds a pipeline programmatically then calls to_toml()
- **THEN** the resulting TOML SHALL be valid and loadable

### Requirement: Operation Categories in Config
TOML configurations SHALL support all operation categories with their specific parameters.

#### Scenario: Data cleaning operations
- **WHEN** config includes fill_null, drop_nulls, remove_outliers
- **THEN** all cleaning operations SHALL be available and configurable

#### Scenario: Time operations
- **WHEN** config includes resample, rolling, align
- **THEN** all time operations SHALL be available and configurable

#### Scenario: Feature engineering operations
- **WHEN** config includes lag, extract_datetime, diff, cyclical_encode
- **THEN** all feature engineering operations SHALL be available and configurable

#### Scenario: Aggregation operations
- **WHEN** config includes group_by_time, cumsum, expanding
- **THEN** all aggregation operations SHALL be available and configurable

#### Scenario: Transformation operations
- **WHEN** config includes standardize, scale, log_transform, boxcox
- **THEN** all transformation operations SHALL be available and configurable

### Requirement: Complex Parameter Types
Configurations SHALL support complex parameter types including nested structures.

#### Scenario: Dictionary parameters
- **WHEN** operation requires column-specific parameters as a dict
- **THEN** TOML SHALL support nested table syntax

#### Scenario: Multiple aggregations
- **WHEN** resample needs different aggregations per column
- **THEN** config SHALL support mapping columns to aggregation methods

### Requirement: Configuration Comments
TOML configurations SHALL support comments for documentation.

#### Scenario: Inline comments
- **WHEN** config includes # comments
- **THEN** comments SHALL be preserved and ignored during parsing

### Requirement: Configuration Validation Errors
Validation errors SHALL provide clear, actionable messages.

#### Scenario: Line number in error
- **WHEN** validation fails
- **THEN** error message SHALL include the line number in the TOML file

#### Scenario: Suggestion in error
- **WHEN** parameter name is misspelled
- **THEN** error message SHALL suggest the correct parameter name if similar

### Requirement: Default Parameters
Operations SHALL have sensible defaults for optional parameters.

#### Scenario: Fill method default
- **WHEN** fill_null omits method parameter
- **THEN** default method "forward" SHALL be used

#### Scenario: Window default
- **WHEN** rolling operation omits window parameter
- **THEN** a reasonable default (e.g., 10) SHALL be used

### Requirement: Pipeline Composition
Users SHALL be able to compose multiple pipeline configurations.

#### Scenario: Load and extend
- **WHEN** user loads a base pipeline and adds more operations
- **THEN** the extended pipeline SHALL include all operations

#### Scenario: Merge pipelines
- **WHEN** user combines two pipeline configs
- **THEN** operations from both SHALL be included in order

### Requirement: Dry Run Mode
Pipelines SHALL support validation without execution.

#### Scenario: Validate pipeline
- **WHEN** user calls pipeline.validate(dataframe)
- **THEN** all operations SHALL be checked against the data schema without execution

#### Scenario: Schema compatibility
- **WHEN** validation runs
- **THEN** column existence and type compatibility SHALL be verified

### Requirement: Pipeline Introspection
Users SHALL be able to inspect pipeline structure programmatically.

#### Scenario: List operations
- **WHEN** user calls pipeline.operations
- **THEN** a list of operation names and parameters SHALL be returned

#### Scenario: Operation count
- **WHEN** user calls len(pipeline)
- **THEN** the number of operations SHALL be returned

### Requirement: Error Recovery
The system SHALL provide options for error handling during pipeline execution.

#### Scenario: Fail fast (default)
- **WHEN** an operation fails and strict mode is on
- **THEN** execution SHALL stop immediately with error

#### Scenario: Continue on error
- **WHEN** user enables continue_on_error mode
- **THEN** failed operations SHALL be logged and skipped, execution continues

### Requirement: Operation Logging
Pipelines SHALL log operation execution for debugging and monitoring.

#### Scenario: Execution logging
- **WHEN** pipeline executes with logging enabled
- **THEN** each operation SHALL log start, duration, and result

#### Scenario: Progress reporting
- **WHEN** processing large datasets
- **THEN** pipeline SHALL report progress (e.g., "3/10 operations completed")

### Requirement: Configuration Schema Documentation
The system SHALL provide schema documentation for all valid TOML configurations.

#### Scenario: Schema reference
- **WHEN** user consults documentation
- **THEN** all operation types, parameters, and valid values SHALL be documented

#### Scenario: Example configs
- **WHEN** user explores examples directory
- **THEN** complete TOML examples for common use cases SHALL be available
