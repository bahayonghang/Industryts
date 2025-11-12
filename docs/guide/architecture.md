# Architecture Guide

## Overview

IndustryTS v0.2.0 introduces a redesigned architecture for time series processing with improved modularity, extensibility, and type safety.

## Core Modules

### `core/` - Core Abstractions

The foundation of the library providing fundamental abstractions:

#### `data.rs` - TimeSeriesData
- **Purpose**: Wraps Polars DataFrames with time series-specific functionality
- **Features**:
  - Automatic time column detection
  - Feature column management
  - Metadata support with tags
  - Type-safe access patterns

```rust
use industryts_core::TimeSeriesData;

let ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();
ts.add_tag("source".to_string(), "sensor_01".to_string());
```

#### `operation.rs` - Operation Trait
- **Purpose**: Defines the interface for all time series operations
- **Features**:
  - Unified execution interface
  - Operation validation
  - Metadata support
  - Category classification

```rust
pub trait Operation: Send + Sync {
    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData>;
    fn name(&self) -> &str;
    fn validate(&self, data: &TimeSeriesData) -> Result<()>;
    fn metadata(&self) -> OperationMetadata;
}
```

#### `context.rs` - ExecutionContext
- **Purpose**: Tracks pipeline execution and collects metrics
- **Features**:
  - Operation execution history
  - Performance metrics collection
  - Custom metadata storage
  - Execution summary generation

```rust
let mut context = ExecutionContext::new();
let (result, context) = pipeline.process_with_context(ts, context).unwrap();
let summary = context.summary();
```

### `pipeline/` - Pipeline Engine

The execution engine for chaining and managing operations:

#### `executor.rs` - Pipeline
- **Purpose**: Executes a sequence of operations
- **Features**:
  - Sequential operation execution
  - TOML configuration support
  - Execution context integration
  - Backward compatible API

#### `builder.rs` - PipelineBuilder
- **Purpose**: Fluent API for pipeline construction
- **Features**:
  - Method chaining
  - Simplified pipeline building
  - Mutable and immutable variants

```rust
let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(FillNullOperation::new(...)))
    .add_operation(Box::new(LagOperation::new(...)))
    .build();
```

#### `registry.rs` - OperationRegistry
- **Purpose**: Dynamic operation registration and discovery
- **Features**:
  - Runtime operation registration
  - Category-based querying
  - Factory pattern support
  - Operation information storage

```rust
let mut registry = OperationRegistry::new();
registry.register(
    "fill_null".to_string(),
    OperationCategory::DataQuality,
    "Fill null values".to_string(),
    || Box::new(FillNullOperation::new(...)),
);
```

### `operations/` - Operation Implementations

Operations organized by category:

#### `data_quality/` - Data Quality Operations
- `FillNullOperation`: Handle missing values
- Future: Validation, Outlier detection

#### `temporal/` - Temporal Operations
- Placeholder for future implementations
- Planned: Resample, Shift, Aggregation

#### `features/` - Feature Engineering
- `LagOperation`: Create lagged features
- Future: Rolling windows, Differences, Statistics

#### `transform/` - Data Transformation
- `StandardizeOperation`: Z-score normalization
- `NormalizeOperation`: Min-max normalization
- Future: Scaling, Encoding

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    User Code                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────────┐
        │   Create TimeSeriesData (core)     │
        │   - DataFrame                      │
        │   - Time column name               │
        │   - Feature columns                │
        │   - Metadata tags                  │
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │   Build Pipeline (pipeline)        │
        │   - Using Builder or direct API    │
        │   - Add Operations                 │
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │   Execute Pipeline (executor)      │
        │   - process()                      │
        │   - process_with_context()         │
        └────────────┬───────────────────────┘
                     │
        ┌────────────┴───────────────────────┐
        │                                    │
        ▼                                    ▼
    ┌─────────────┐                  ┌──────────────────┐
    │ Operation 1 │                  │ ExecutionContext │
    │ (Operation) │──────────────────│ - Metrics        │
    └──────┬──────┘                  │ - History        │
           │                         │ - Metadata       │
           ▼                         └──────────────────┘
    ┌─────────────┐
    │ Operation 2 │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ Operation N │
    └──────┬──────┘
           │
           ▼
    ┌──────────────────────────┐
    │ Result TimeSeriesData    │
    │ + ExecutionSummary       │
    └──────────────────────────┘
```

## Key Concepts

### TimeSeriesData
- Wraps Polars DataFrame
- Manages time and feature columns
- Supports metadata tags
- Type-safe access patterns

### Operation
- Unified interface for all operations
- Supports validation before execution
- Provides metadata about the operation
- Categorized for organization

### Pipeline
- Chains multiple operations
- Executes sequentially
- Supports configuration via TOML
- Optional execution context tracking

### ExecutionContext
- Tracks operation execution
- Collects performance metrics
- Stores custom metadata
- Generates execution summary

## Backward Compatibility

All v0.1.x APIs remain available:

```rust
// Old way (still works)
use industryts_core::timeseries::TimeSeriesData;

// New way (recommended)
use industryts_core::TimeSeriesData;
```

## Extension Points

### Adding New Operations

1. Implement the `Operation` trait
2. Add to appropriate category module
3. Update module exports
4. Add tests

```rust
pub struct MyOperation {
    // configuration
}

impl Operation for MyOperation {
    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData> {
        // implementation
        Ok(data)
    }

    fn name(&self) -> &str {
        "my_operation"
    }
}
```

### Adding New Categories

1. Create category directory in `operations/`
2. Implement operations in category
3. Update `OperationCategory` enum
4. Update `operations/mod.rs`

## Performance Considerations

- No additional data copying overhead
- Execution context is optional
- Polars integration maintains high performance
- Lazy evaluation support for future versions

## Testing

All core modules have comprehensive test coverage:

```bash
uv run cargo test --lib
# 16/16 tests pass
```

## Related Documentation

- [Migration Guide](./migration.md) - Upgrading from v0.1.x
- [API Reference](./api-reference.md) - Detailed API documentation
- [Examples](./examples.md) - Code examples and use cases
