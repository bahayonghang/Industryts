# Migration Guide v0.1.x → v0.2.0

## Overview

IndustryTS v0.2.0 introduces a redesigned architecture with improved modularity and new features. **All existing code remains compatible** - you can upgrade without breaking changes.

## Backward Compatibility

### ✅ What Still Works

All v0.1.x public APIs are fully functional:

```rust
use industryts_core::{TimeSeriesData, Pipeline};
use industryts_core::operations::{FillNullOperation, LagOperation};

let ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();
let mut pipeline = Pipeline::new();
pipeline.add_operation(Box::new(FillNullOperation::new(...)));
let result = pipeline.process(ts).unwrap();
```

### ⚠️ Deprecated Imports

These imports are marked as `#[deprecated]` but still work:

```rust
// Old way (deprecated)
use industryts_core::timeseries::TimeSeriesData;

// New way (recommended)
use industryts_core::TimeSeriesData;
```

## Step-by-Step Migration

### Step 1: Update Imports

#### Before
```rust
use industryts_core::timeseries::TimeSeriesData;
use industryts_core::pipeline::Operation;
```

#### After
```rust
use industryts_core::{TimeSeriesData, Operation};
// Or more explicitly:
use industryts_core::core::{TimeSeriesData, Operation};
```

### Step 2: Use Builder API (Optional)

The new Builder API simplifies pipeline construction:

#### Before
```rust
let mut pipeline = Pipeline::new();
pipeline.add_operation(Box::new(FillNullOperation::new(...)));
pipeline.add_operation(Box::new(LagOperation::new(...)));
```

#### After
```rust
use industryts_core::pipeline::PipelineBuilder;

let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(FillNullOperation::new(...)))
    .add_operation(Box::new(LagOperation::new(...)))
    .build();
```

### Step 3: Add Execution Context (Optional)

Track execution metrics and performance:

```rust
use industryts_core::ExecutionContext;

let mut context = ExecutionContext::new();
let (result, context) = pipeline.process_with_context(ts, context).unwrap();

let summary = context.summary();
println!("Operations: {}", summary.total_operations);
println!("Duration: {:?}", summary.total_duration);
println!("Throughput: {:.2} rows/sec", summary.average_throughput);
```

### Step 4: Use Operation Registry (Optional)

Dynamically register and discover operations:

```rust
use industryts_core::pipeline::OperationRegistry;
use industryts_core::core::OperationCategory;

let mut registry = OperationRegistry::new();
registry.register(
    "fill_null".to_string(),
    OperationCategory::DataQuality,
    "Fill null values".to_string(),
    || Box::new(FillNullOperation::new(...)),
);

// Query operations
for op in registry.list_by_category(OperationCategory::DataQuality) {
    println!("Operation: {}", op.name);
}

// Create operation dynamically
let op = registry.create("fill_null").unwrap();
```

## New Features

### 1. Enhanced TimeSeriesData

#### Metadata Support
```rust
let mut ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();

// Add tags
ts.add_tag("source".to_string(), "sensor_01".to_string());
ts.add_tag("location".to_string(), "warehouse".to_string());

// Read tags
if let Some(source) = ts.get_tag("source") {
    println!("Data source: {}", source);
}

// Access metadata
let metadata = ts.metadata();
println!("Time column: {}", metadata.time_column);
println!("Features: {:?}", metadata.feature_columns);
```

### 2. Operation Validation

```rust
impl Operation for MyOperation {
    fn validate(&self, data: &TimeSeriesData) -> Result<()> {
        if data.feature_columns().is_empty() {
            return Err(IndustrytsError::InvalidOperation(
                "No feature columns found".to_string()
            ));
        }
        Ok(())
    }

    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData> {
        self.validate(&data)?;
        // ... implementation
        Ok(data)
    }

    fn name(&self) -> &str {
        "my_operation"
    }
}
```

### 3. Operation Metadata

```rust
impl Operation for MyOperation {
    fn metadata(&self) -> OperationMetadata {
        OperationMetadata {
            name: "my_operation".to_string(),
            description: "My custom operation".to_string(),
            version: "1.0.0".to_string(),
            category: OperationCategory::Transform,
        }
    }

    // ... other methods
}

let op = MyOperation::new();
let metadata = op.metadata();
println!("Operation: {} v{}", metadata.name, metadata.version);
```

### 4. Execution Metrics

```rust
let (result, context) = pipeline.process_with_context(ts, context).unwrap();

for metrics in context.metrics() {
    println!("{}: {} -> {} rows ({:.2}s, {:.0} rows/sec)",
        metrics.operation_name,
        metrics.input_rows,
        metrics.output_rows,
        metrics.duration.as_secs_f64(),
        metrics.throughput());
}
```

## Migration Checklist

- [ ] Update import statements (optional but recommended)
- [ ] If using Builder API, update pipeline construction (optional)
- [ ] If needing metrics, add ExecutionContext (optional)
- [ ] Run tests to ensure everything works
- [ ] Update documentation and comments

## FAQ

### Q: Do I need to migrate immediately?

**A**: No. All existing code continues to work. Migrate at your own pace.

### Q: Will new code break my existing code?

**A**: No. v0.2.0 is fully backward compatible with v0.1.x.

### Q: How do I handle deprecated imports?

**A**: The compiler will issue warnings. You can:
1. Ignore them (code still works)
2. Update imports as shown above

### Q: Is there a performance impact?

**A**: No. The new architecture maintains the same performance characteristics.

### Q: How do I create custom operations?

**A**: See [Architecture Guide](./architecture.md) for detailed instructions.

## Troubleshooting

### Compilation Warnings

If you see deprecation warnings:

```
warning: use of deprecated item: 'timeseries::TimeSeriesData'
```

Update your imports:

```rust
// Change from:
use industryts_core::timeseries::TimeSeriesData;

// To:
use industryts_core::TimeSeriesData;
```

### Import Errors

If you get import errors after updating:

```rust
// Make sure you're importing from the right place:
use industryts_core::{TimeSeriesData, Operation, Pipeline};
use industryts_core::core::{ExecutionContext, OperationCategory};
use industryts_core::pipeline::{PipelineBuilder, OperationRegistry};
```

## Version Information

- **Current Version**: v0.2.0
- **Minimum Supported**: v0.1.x (fully compatible)
- **Rust Version**: 1.70+
- **Polars Version**: 0.51+

## Getting Help

- 📖 [Architecture Guide](./architecture.md)
- 💡 [Examples](./examples.md)
- 🔍 Source code documentation
- 💬 GitHub Issues

## Summary

v0.2.0 brings significant improvements while maintaining full backward compatibility. You can:

1. **Keep existing code as-is** - everything still works
2. **Gradually adopt new features** - use Builder API, ExecutionContext, etc.
3. **Update imports** - recommended but not required
4. **Enjoy new capabilities** - metrics, validation, registry, etc.

Happy upgrading! 🚀
