# Quick Start

This guide will help you get started with Industryts and create your first time series processing pipeline.

## Basic Example

### 1. Import and Load Data

```python
import industryts as its
import polars as pl
from datetime import datetime, timedelta

# Create sample time series data
dates = pl.datetime_range(
    start=datetime(2024, 1, 1),
    end=datetime(2024, 1, 31),
    interval="1h",
    eager=True
)

df = pl.DataFrame({
    "DateTime": dates,
    "temperature": [20.0 + i * 0.1 for i in range(len(dates))],
    "humidity": [50.0 + i * 0.05 for i in range(len(dates))],
    "pressure": [1013.0 + i * 0.01 for i in range(len(dates))]
})

# Create TimeSeriesData
data = its.TimeSeriesData(df)
print(f"Data shape: {len(data)} rows, {len(data.feature_columns)} columns")
```

### 2. Create Processing Pipeline

```python
# Create Pipeline
pipeline = its.Pipeline()

# Add operations
pipeline.fill_null(method="forward")  # Fill missing values
pipeline.lag(columns=["temperature"], periods=[1, 2])  # Create lag features
pipeline.standardize(columns=["temperature", "humidity"])  # Standardize

# Process data
result = pipeline.process(data)
print(f"Processed data shape: {len(result)} rows")
```

### 3. Export Results

```python
# Convert to Polars DataFrame
result_df = result.to_polars()
print(result_df)

# Export to CSV
result.to_csv("processed_data.csv")
```

## Using TOML Configuration

### Create Configuration File

Create `pipeline.toml`:

```toml
[pipeline]
name = "sensor_processing"
time_column = "DateTime"

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
columns = ["temperature"]
periods = [1, 2]

[[operations]]
type = "standardize"
columns = ["temperature", "humidity"]
```

### Load and Use from Configuration

```python
import industryts as its

# Load pipeline from TOML
pipeline = its.Pipeline.from_toml("pipeline.toml")

# Load data
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Process data
result = pipeline.process(data)

# Export results
result.to_csv("output.csv")
```

## Common Operations

### Data Cleaning

```python
pipeline = its.Pipeline()

# Fill missing values
pipeline.fill_null(method="forward")  # Forward fill
pipeline.fill_null(method="backward")  # Backward fill
pipeline.fill_null(method="mean")  # Mean fill

# Drop missing values
pipeline.drop_null()

# Clip values
pipeline.clip(columns=["temperature"], min=0, max=50)
```

### Feature Engineering

```python
pipeline = its.Pipeline()

# Lag features
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])

# Rolling statistics
pipeline.rolling_mean(columns=["temperature"], window=24)
pipeline.rolling_std(columns=["temperature"], window=24)

# Differences
pipeline.diff(columns=["temperature"], periods=1)

# Standardization
pipeline.standardize(columns=["temperature", "humidity"])

# Normalization
pipeline.normalize(columns=["temperature"], min=0, max=1)
```

### Time Operations

```python
pipeline = its.Pipeline()

# Resample
pipeline.resample(method="mean", interval="1h")

# Extract time features
pipeline.extract_time_features(columns=["DateTime"])

# Time window aggregation
pipeline.time_window_aggregate(
    window="1d",
    aggregations={"temperature": "mean", "humidity": "max"}
)
```

### Data Aggregation

```python
pipeline = its.Pipeline()

# Group aggregation
pipeline.groupby(
    by=["sensor_id"],
    aggregations={"temperature": "mean", "humidity": "max"}
)

# Multi-column aggregation
pipeline.aggregate(
    aggregations={
        "temperature": ["mean", "std", "min", "max"],
        "humidity": ["mean"]
    }
)
```

## Complete Workflow Example

```python
import industryts as its
import polars as pl
from datetime import datetime

# 1. Load data
data = its.TimeSeriesData.from_csv("sensor_data.csv")
print(f"Original data: {len(data)} rows")

# 2. Create processing pipeline
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature", "humidity"], periods=[1, 2])
pipeline.rolling_mean(columns=["temperature"], window=24)
pipeline.standardize(columns=["temperature", "humidity"])

# 3. Process data
result = pipeline.process(data)
print(f"Processed data: {len(result)} rows")

# 4. Export results
result.to_csv("processed_sensor_data.csv")
print("Data saved to processed_sensor_data.csv")

# 5. View results
result_df = result.to_polars()
print(result_df.head())
```

## Performance Tips

1. **Use TOML Configuration**: For production, use TOML configs for reproducibility
2. **Batch Processing**: Processing large amounts at once is faster than multiple small batches
3. **Operation Order**: Filter first, then compute-intensive operations
4. **Type Hints**: Leverage Python type hints for better IDE support

## Next Steps

- [Core Concepts](/en/guide/concepts/timeseries) - Deep dive into TimeSeriesData
- [API Reference](/en/api/core) - Complete API documentation
- [Examples](/en/examples/basic) - More real-world usage examples
