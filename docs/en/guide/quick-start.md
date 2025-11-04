# Quick Start

This guide will walk you through creating your first time series processing pipeline with Industryts. You'll learn the basics in less than 10 minutes!

## Prerequisites

Make sure you have Industryts installed:

```bash
pip install industryts
```

See the [Installation Guide](/en/guide/installation) for detailed instructions.

## Your First Pipeline

Let's process sensor data from an industrial system. We'll clean missing values, create lag features, and standardize the data.

### Step 1: Prepare Sample Data

Create a CSV file `sensor_data.csv` with time series data:

```csv
DateTime,temperature,pressure,humidity
2024-01-01 00:00:00,25.5,101.3,45.2
2024-01-01 01:00:00,25.8,101.5,44.8
2024-01-01 02:00:00,,101.2,45.5
2024-01-01 03:00:00,26.1,101.4,44.2
2024-01-01 04:00:00,26.3,101.6,43.9
2024-01-01 05:00:00,26.5,,44.5
2024-01-01 06:00:00,26.8,101.8,44.1
```

::: tip
In real scenarios, you'd load data from your data sources. Industryts supports CSV, Parquet, and Polars DataFrames.
:::

### Step 2: Load Data

```python
import industryts as its

# Load time series data
# Industryts auto-detects the time column (DateTime, timestamp, etc.)
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Inspect the data
print(data.head())
print(f"Time column: {data.time_column}")
print(f"Feature columns: {data.feature_columns}")
```

Expected output:
```
shape: (5, 4)
┌─────────────────────┬─────────────┬──────────┬──────────┐
│ DateTime            │ temperature │ pressure │ humidity │
│ ---                 │ ---         │ ---      │ ---      │
│ datetime[μs]        │ f64         │ f64      │ f64      │
╞═════════════════════╪═════════════╪══════════╪══════════╡
│ 2024-01-01 00:00:00 │ 25.5        │ 101.3    │ 45.2     │
│ 2024-01-01 01:00:00 │ 25.8        │ 101.5    │ 44.8     │
│ 2024-01-01 02:00:00 │ null        │ 101.2    │ 45.5     │
│ 2024-01-01 03:00:00 │ 26.1        │ 101.4    │ 44.2     │
│ 2024-01-01 04:00:00 │ 26.3        │ 101.6    │ 43.9     │
└─────────────────────┴─────────────┴──────────┴──────────┘

Time column: DateTime
Feature columns: ['temperature', 'pressure', 'humidity']
```

::: tip Auto-Detection
Industryts automatically detects time columns with common names like:
- `DateTime`, `datetime`, `Datetime`
- `timestamp`, `Timestamp`
- `tagTime`, `time`, `Time`
- `date`, `Date`

You can also specify it manually: `TimeSeriesData.from_csv("data.csv", time_column="my_time")`
:::

### Step 3: Build a Pipeline (Programmatic API)

Now let's build a processing pipeline:

```python
# Create pipeline
pipeline = its.Pipeline()

# Add operations
pipeline.fill_null(method="forward")  # ✅ Forward fill missing values
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])  # ✅ Create lag features
pipeline.standardize()  # ✅ Standardize all feature columns

# Process the data
result = pipeline.process(data)

# Inspect results
print(result.head())
```

Expected output shows new lag columns and standardized values:
```
shape: (5, 7)
┌─────────────────────┬─────────────┬──────────┬──────────┬─────────────────┬─────────────────┬─────────────────┐
│ DateTime            │ temperature │ pressure │ humidity │ temperature_lag1│ temperature_lag2│ temperature_lag3│
│ ---                 │ ---         │ ---      │ ---      │ ---             │ ---             │ ---             │
│ datetime[μs]        │ f64         │ f64      │ f64      │ f64             │ f64             │ f64             │
╞═════════════════════╪═════════════╪══════════╪══════════╪═════════════════╪═════════════════╪═════════════════╡
│ 2024-01-01 00:00:00 │ -1.52       │ -1.34    │ 1.42     │ null            │ null            │ null            │
│ 2024-01-01 01:00:00 │ -1.21       │ -0.89    │ 0.98     │ 25.5            │ null            │ null            │
│ 2024-01-01 02:00:00 │ -1.21       │ -1.56    │ 1.87     │ 25.8            │ 25.5            │ null            │
│ ...                 │ ...         │ ...      │ ...      │ ...             │ ...             │ ...             │
└─────────────────────┴─────────────┴──────────┴──────────┴─────────────────┴─────────────────┴─────────────────┘
```

### Step 4: Save Results

```python
# Save to CSV
result.to_csv("processed_data.csv")

# Or save to Parquet for better performance
result.to_parquet("processed_data.parquet")

# Or get as Polars DataFrame for further processing
df = result.to_polars()
print(df.describe())
```

## Declarative API with TOML

For reproducible workflows, define your pipeline in a TOML configuration file.

### Create `pipeline.toml`

```toml
[pipeline]
name = "sensor_processing"
time_column = "DateTime"  # Optional: auto-detected by default

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
columns = ["temperature"]
periods = [1, 2, 3]

[[operations]]
type = "standardize"
# columns not specified = standardize all feature columns
```

### Use the TOML Pipeline

```python
import industryts as its

# Load pipeline from config
pipeline = its.Pipeline.from_toml("pipeline.toml")

# Load and process data
data = its.TimeSeriesData.from_csv("sensor_data.csv")
result = pipeline.process(data)

# Save results
result.to_csv("processed_data.csv")
```

::: tip Why TOML?
- **Version Control**: Track pipeline changes in git
- **Code Review**: Review data processing separately from code
- **Reproducibility**: Same results across environments
- **Documentation**: Self-documenting structure
:::

## Understanding Operations

Let's break down what each operation does:

### 1. fill_null - Handle Missing Values ✅

```python
pipeline.fill_null(method="forward")
```

Fills null values using forward propagation. Available methods:
- `"forward"` - Use previous valid value
- `"backward"` - Use next valid value
- `"mean"` - Use column mean
- `"zero"` - Fill with 0

[Learn more about fill_null](/en/guide/cleaning#fill-null)

### 2. lag - Create Lag Features ✅

```python
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
```

Creates lag features for time series forecasting:
- `temperature_lag1`: Value from 1 period ago
- `temperature_lag2`: Value from 2 periods ago
- `temperature_lag3`: Value from 3 periods ago

[Learn more about lag features](/en/guide/features#lag-features)

### 3. standardize - Z-Score Normalization ✅

```python
pipeline.standardize()  # All feature columns
# Or specify columns
pipeline.standardize(columns=["temperature", "pressure"])
```

Standardizes data to mean=0, std=1 using z-score:
```
z = (x - mean) / std
```

[Learn more about standardization](/en/guide/transforms#standardization)

## Operation Status

| Operation | Status | Documentation |
|-----------|--------|---------------|
| fill_null | ✅ Implemented | [Guide](/en/guide/cleaning#fill-null) |
| lag | ✅ Implemented | [Guide](/en/guide/features#lag-features) |
| standardize | ✅ Implemented | [Guide](/en/guide/transforms#standardization) |
| resample | 🚧 Pending Polars 0.51 API | [Guide](/en/guide/time-ops#resample) |
| rolling | 📋 Planned | Coming soon |
| outlier detection | 📋 Planned | Coming soon |

## Common Patterns

### Pattern 1: Basic Cleaning Pipeline

```python
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.standardize()
```

### Pattern 2: Feature Engineering for ML

```python
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature", "pressure"], periods=[1, 2, 3, 6, 12])
pipeline.standardize()
```

### Pattern 3: Multiple Operations on Same Column

```python
pipeline = its.Pipeline()
pipeline.fill_null(method="mean")  # Clean first
pipeline.lag(columns=["temperature"], periods=[1])  # Then lag
pipeline.standardize(columns=["temperature", "temperature_lag1"])  # Standardize both
```

## Performance Tips

1. **Use Release Builds**: Debug builds are ~10x slower
   ```bash
   # Always use release for production
   make build
   ```

2. **Batch Operations**: Process multiple files efficiently
   ```python
   for file in files:
       data = its.TimeSeriesData.from_csv(file)
       result = pipeline.process(data)  # Pipeline is reused
       result.to_parquet(f"processed_{file}")
   ```

3. **Column Selection**: Specify columns to reduce memory usage
   ```python
   # Only lag specific columns, not all features
   pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
   ```

## What's Next?

Now that you've created your first pipeline, explore more:

- **[Core Concepts](/en/guide/concepts/timeseries)** - Understand TimeSeriesData and Pipeline
- **[Data Cleaning](/en/guide/cleaning)** - Master missing value handling
- **[Feature Engineering](/en/guide/features)** - Create powerful lag features
- **[TOML Configuration](/en/guide/toml/structure)** - Build declarative pipelines
- **[API Reference](/en/api/timeseries)** - Complete API documentation
- **[Examples](/en/examples/basic)** - Real-world use cases

## Troubleshooting

### Issue: "No time column found"

**Solution**: Specify the time column explicitly
```python
data = its.TimeSeriesData.from_csv("data.csv", time_column="my_timestamp")
```

### Issue: "Cannot create lag with empty DataFrame"

**Solution**: Ensure your data has at least `max(periods) + 1` rows
```python
# For periods=[1,2,3], need at least 4 rows
data = its.TimeSeriesData.from_csv("data.csv")
print(len(data))  # Should be >= 4
```

### Issue: "Memory error on large dataset"

**Solution**: Process in chunks or use Parquet format
```python
# Use Parquet for better compression
data = its.TimeSeriesData.from_parquet("large_data.parquet")
```

## Get Help

- **Documentation**: [Full User Guide](/en/guide/loading-data)
- **Examples**: [Real-world examples](/en/examples/basic)
- **Issues**: [GitHub Issues](https://github.com/yourusername/industryts/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/industryts/discussions)
