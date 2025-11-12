# Examples and Use Cases

## Basic Usage

### Creating Time Series Data

```rust
use industryts_core::TimeSeriesData;
use polars::prelude::*;

// Create a DataFrame with time series data
let dates = vec![
    1704067200000i64, // 2024-01-01
    1704153600000,    // 2024-01-02
    1704240000000,    // 2024-01-03
];

let time_series = Series::new("DateTime".into(), dates)
    .cast(&DataType::Datetime(TimeUnit::Milliseconds, None))
    .unwrap();

let df = DataFrame::new(vec![
    time_series.into(),
    Series::new("temperature".into(), &[20.5, 21.2, 19.8]).into(),
    Series::new("humidity".into(), &[65.0, 70.0, 68.0]).into(),
]).unwrap();

// Create TimeSeriesData
let ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();
println!("Time column: {}", ts.time_column());
println!("Features: {:?}", ts.feature_columns());
```

### Basic Pipeline

```rust
use industryts_core::{Pipeline, TimeSeriesData};
use industryts_core::operations::FillNullOperation;
use industryts_core::config::FillMethod;

let mut pipeline = Pipeline::new();
pipeline.add_operation(Box::new(
    FillNullOperation::new(FillMethod::Forward, None)
));

let result = pipeline.process(ts).unwrap();
println!("Processed {} rows", result.len());
```

## Advanced Usage

### Using Builder API

```rust
use industryts_core::pipeline::PipelineBuilder;
use industryts_core::operations::{
    FillNullOperation, LagOperation, StandardizeOperation
};
use industryts_core::config::FillMethod;

let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(
        FillNullOperation::new(FillMethod::Forward, None)
    ))
    .add_operation(Box::new(
        LagOperation::new(vec![1, 2, 3], None)
    ))
    .add_operation(Box::new(
        StandardizeOperation::new(None)
    ))
    .build();

let result = pipeline.process(ts).unwrap();
```

### Execution with Metrics

```rust
use industryts_core::ExecutionContext;

let mut context = ExecutionContext::new();
context.add_metadata("run_id".to_string(), "20250101_001".to_string());
context.add_metadata("environment".to_string(), "production".to_string());

let (result, context) = pipeline.process_with_context(ts, context).unwrap();

// Get execution summary
let summary = context.summary();
println!("=== Pipeline Execution Summary ===");
println!("Total operations: {}", summary.total_operations);
println!("Total duration: {:.2}s", summary.total_duration.as_secs_f64());
println!("Rows processed: {}", summary.total_rows_processed);
println!("Average throughput: {:.0} rows/sec", summary.average_throughput);

// Get detailed metrics
println!("\n=== Operation Details ===");
for metrics in context.metrics() {
    println!("{}: {} -> {} rows ({:.2}s, {:.0} rows/sec)",
        metrics.operation_name,
        metrics.input_rows,
        metrics.output_rows,
        metrics.duration.as_secs_f64(),
        metrics.throughput());
}
```

### Loading from TOML Configuration

```rust
use industryts_core::Pipeline;

// Load pipeline from TOML file
let pipeline = Pipeline::from_toml("config/pipeline.toml").unwrap();

// Execute
let result = pipeline.process(ts).unwrap();

// Save configuration
pipeline.to_toml("config/output.toml").unwrap();
```

Example TOML configuration:

```toml
[pipeline]
name = "data_processing"
time_column = "DateTime"

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
periods = [1, 2, 3]

[[operations]]
type = "standardize"
```

### Using Operation Registry

```rust
use industryts_core::pipeline::OperationRegistry;
use industryts_core::core::OperationCategory;
use industryts_core::operations::FillNullOperation;
use industryts_core::config::FillMethod;

// Create and populate registry
let mut registry = OperationRegistry::new();

registry.register(
    "fill_forward".to_string(),
    OperationCategory::DataQuality,
    "Fill null values using forward fill".to_string(),
    || Box::new(FillNullOperation::new(FillMethod::Forward, None)),
);

registry.register(
    "fill_backward".to_string(),
    OperationCategory::DataQuality,
    "Fill null values using backward fill".to_string(),
    || Box::new(FillNullOperation::new(FillMethod::Backward, None)),
);

// List operations by category
println!("Data Quality Operations:");
for op_info in registry.list_by_category(OperationCategory::DataQuality) {
    println!("  - {}: {}", op_info.name, op_info.description);
}

// Create operation dynamically
let operation = registry.create("fill_forward").unwrap();
```

### Working with Metadata

```rust
use industryts_core::TimeSeriesData;

let mut ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();

// Add tags
ts.add_tag("source".to_string(), "sensor_01".to_string());
ts.add_tag("location".to_string(), "warehouse_a".to_string());
ts.add_tag("unit".to_string(), "celsius".to_string());

// Read tags
if let Some(source) = ts.get_tag("source") {
    println!("Data source: {}", source);
}

// Access metadata
let metadata = ts.metadata();
println!("Time column: {}", metadata.time_column);
println!("Feature columns: {:?}", metadata.feature_columns);
println!("Tags: {:?}", metadata.tags);
```

## Real-World Scenarios

### Scenario 1: Sensor Data Processing

```rust
// Load sensor data
let ts = TimeSeriesData::new(sensor_df, Some("timestamp")).unwrap();

// Build processing pipeline
let pipeline = PipelineBuilder::new()
    // Fill missing values from sensor failures
    .add_operation(Box::new(
        FillNullOperation::new(FillMethod::Forward, None)
    ))
    // Create lagged features for anomaly detection
    .add_operation(Box::new(
        LagOperation::new(vec![1, 2, 3], None)
    ))
    // Normalize for machine learning
    .add_operation(Box::new(
        StandardizeOperation::new(None)
    ))
    .build();

// Execute with metrics
let mut context = ExecutionContext::new();
context.add_metadata("sensor_id".to_string(), "TEMP_001".to_string());

let (result, context) = pipeline.process_with_context(ts, context).unwrap();

// Log results
let summary = context.summary();
println!("Processed {} rows in {:.2}s", 
    summary.total_rows_processed,
    summary.total_duration.as_secs_f64());
```

### Scenario 2: Financial Time Series

```rust
// Load stock price data
let ts = TimeSeriesData::new(stock_df, Some("date")).unwrap();

// Add metadata
let mut ts = ts;
ts.add_tag("symbol".to_string(), "AAPL".to_string());
ts.add_tag("exchange".to_string(), "NASDAQ".to_string());

// Build analysis pipeline
let pipeline = PipelineBuilder::new()
    // Handle missing data
    .add_operation(Box::new(
        FillNullOperation::new(FillMethod::Mean, None)
    ))
    // Create technical indicators (lagged features)
    .add_operation(Box::new(
        LagOperation::new(vec![1, 5, 20], None)
    ))
    // Normalize for comparison
    .add_operation(Box::new(
        StandardizeOperation::new(None)
    ))
    .build();

let result = pipeline.process(ts).unwrap();
```

### Scenario 3: Time Series with Validation

```rust
use industryts_core::core::Operation;

// Create custom operation with validation
struct CustomAnalysis {
    threshold: f64,
}

impl Operation for CustomAnalysis {
    fn validate(&self, data: &TimeSeriesData) -> Result<()> {
        if data.len() < 10 {
            return Err(IndustrytsError::InvalidOperation(
                "Need at least 10 data points".to_string()
            ));
        }
        Ok(())
    }

    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData> {
        self.validate(&data)?;
        // Process data
        Ok(data)
    }

    fn name(&self) -> &str {
        "custom_analysis"
    }
}

// Use in pipeline
let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(CustomAnalysis { threshold: 0.5 }))
    .build();

let result = pipeline.process(ts).unwrap();
```

## Performance Tips

### 1. Reuse Pipelines

```rust
// Good: Create once, use many times
let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(FillNullOperation::new(...)))
    .build();

for ts in time_series_list {
    let result = pipeline.process(ts).unwrap();
}
```

### 2. Selective Column Operations

```rust
// Specify columns to reduce processing
let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(
        FillNullOperation::new(
            FillMethod::Forward,
            Some(vec!["temperature".to_string(), "humidity".to_string()])
        )
    ))
    .build();
```

### 3. Optional Metrics Collection

```rust
// Only collect metrics when needed
if debug_mode {
    let mut context = ExecutionContext::new();
    let (result, context) = pipeline.process_with_context(ts, context).unwrap();
    // Analyze metrics
} else {
    let result = pipeline.process(ts).unwrap();
}
```

## Error Handling

```rust
use industryts_core::error::IndustrytsError;

match pipeline.process(ts) {
    Ok(result) => {
        println!("Success: {} rows processed", result.len());
    }
    Err(IndustrytsError::TimeColumnNotFound(col)) => {
        eprintln!("Time column not found: {}", col);
    }
    Err(IndustrytsError::ColumnNotFound(col)) => {
        eprintln!("Column not found: {}", col);
    }
    Err(IndustrytsError::InvalidOperation(msg)) => {
        eprintln!("Invalid operation: {}", msg);
    }
    Err(e) => {
        eprintln!("Error: {}", e);
    }
}
```

## Next Steps

- See [Architecture Guide](./architecture.md) for detailed design
- Check [Migration Guide](./migration.md) for upgrading from v0.1.x
- Review source code documentation for API details
