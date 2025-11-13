# Basic Examples

This page shows basic usage examples of Industryts.

## Sensor Data Processing

### Scenario

Process time series data from multiple sensors including temperature, humidity, and pressure.

### Code

```python
import industryts as its
import polars as pl
from datetime import datetime

# 1. Create sample data
dates = pl.datetime_range(
    start=datetime(2024, 1, 1),
    end=datetime(2024, 1, 31),
    interval="1h",
    eager=True
)

df = pl.DataFrame({
    "DateTime": dates,
    "sensor_id": ["A"] * len(dates),
    "temperature": [20.0 + i * 0.1 for i in range(len(dates))],
    "humidity": [50.0 + i * 0.05 for i in range(len(dates))],
    "pressure": [1013.0 + i * 0.01 for i in range(len(dates))]
})

# 2. Create TimeSeriesData
data = its.TimeSeriesData(df)
print(f"Original data: {len(data)} rows")

# 3. Create processing pipeline
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature", "humidity"], periods=[1, 2])
pipeline.rolling_mean(columns=["temperature"], window=24)
pipeline.standardize(columns=["temperature", "humidity"])

# 4. Process data
result = pipeline.process(data)
print(f"Processed data: {len(result)} rows")

# 5. Export results
result.to_csv("processed_sensor_data.csv")
print("Data saved")
```

## Multi-Sensor Data Aggregation

### Scenario

Process data from multiple sensors and aggregate by sensor.

### Code

```python
import industryts as its
import polars as pl
from datetime import datetime

# Create multi-sensor data
dates = pl.datetime_range(
    start=datetime(2024, 1, 1),
    end=datetime(2024, 1, 10),
    interval="1h",
    eager=True
)

df = pl.DataFrame({
    "DateTime": dates,
    "sensor_id": ["A"] * (len(dates) // 2) + ["B"] * (len(dates) - len(dates) // 2),
    "temperature": [20.0 + i * 0.1 for i in range(len(dates))],
    "humidity": [50.0 + i * 0.05 for i in range(len(dates))]
})

data = its.TimeSeriesData(df)

# Create processing pipeline
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.groupby(
    by=["sensor_id"],
    aggregations={
        "temperature": "mean",
        "humidity": "max"
    }
)

result = pipeline.process(data)
print(result.to_polars())
```

## Feature Engineering

### Scenario

Create features for machine learning models.

### Code

```python
import industryts as its
import polars as pl
from datetime import datetime

# Create data
dates = pl.datetime_range(
    start=datetime(2024, 1, 1),
    end=datetime(2024, 1, 31),
    interval="1d",
    eager=True
)

df = pl.DataFrame({
    "DateTime": dates,
    "price": [100.0 + i * 0.5 for i in range(len(dates))]
})

data = its.TimeSeriesData(df)

# Create features
pipeline = its.Pipeline()
pipeline.lag(columns=["price"], periods=[1, 2, 3, 5, 7])  # Historical prices
pipeline.rolling_mean(columns=["price"], window=7)  # 7-day moving average
pipeline.rolling_std(columns=["price"], window=7)  # 7-day standard deviation
pipeline.diff(columns=["price"], periods=1)  # Price changes

result = pipeline.process(data)
print(result.to_polars())
```

## Time Series Resampling

### Scenario

Resample high-frequency data to lower frequency.

### Code

```python
import industryts as its
import polars as pl
from datetime import datetime

# Create minute-level data
dates = pl.datetime_range(
    start=datetime(2024, 1, 1),
    end=datetime(2024, 1, 2),
    interval="1m",
    eager=True
)

df = pl.DataFrame({
    "DateTime": dates,
    "value": list(range(len(dates)))
})

data = its.TimeSeriesData(df)

# Resample to hourly
pipeline = its.Pipeline()
pipeline.resample(method="mean", interval="1h")

result = pipeline.process(data)
print(f"Original data: {len(data)} rows")
print(f"Resampled: {len(result)} rows")
```

## Data Cleaning

### Scenario

Handle data with missing values and outliers.

### Code

```python
import industryts as its
import polars as pl
from datetime import datetime

# Create data with missing values
dates = pl.datetime_range(
    start=datetime(2024, 1, 1),
    end=datetime(2024, 1, 10),
    interval="1d",
    eager=True
)

values = [20.0, None, 22.0, 21.0, None, 23.0, 20.5, 21.5, None, 22.0]

df = pl.DataFrame({
    "DateTime": dates,
    "temperature": values
})

data = its.TimeSeriesData(df)

# Clean data
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")  # Forward fill
pipeline.clip(columns=["temperature"], min=15, max=30)  # Limit range
pipeline.drop_null()  # Drop remaining null values

result = pipeline.process(data)
print(result.to_polars())
```

## Using TOML Configuration

### Scenario

Define reproducible processing pipelines using configuration files.

### Configuration File (pipeline.toml)

```toml
[pipeline]
name = "sensor_processing"
time_column = "DateTime"
description = "Pipeline for processing sensor data"

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
columns = ["temperature", "humidity"]
periods = [1, 2]

[[operations]]
type = "rolling_mean"
columns = ["temperature"]
window = 24

[[operations]]
type = "standardize"
columns = ["temperature", "humidity"]
```

### Python Code

```python
import industryts as its

# Load pipeline from configuration
pipeline = its.Pipeline.from_toml("pipeline.toml")

# Load data
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Process data
result = pipeline.process(data)

# Export results
result.to_csv("output.csv")
```

## Complete Workflow

### Scenario

Complete workflow from data loading to result export.

### Code

```python
import industryts as its
import polars as pl
from datetime import datetime

# 1. Prepare data
print("1. Preparing data...")
dates = pl.datetime_range(
    start=datetime(2024, 1, 1),
    end=datetime(2024, 3, 31),
    interval="1h",
    eager=True
)

df = pl.DataFrame({
    "DateTime": dates,
    "temperature": [20.0 + i * 0.01 for i in range(len(dates))],
    "humidity": [50.0 + i * 0.005 for i in range(len(dates))],
    "pressure": [1013.0 + i * 0.001 for i in range(len(dates))]
})

data = its.TimeSeriesData(df)
print(f"   Data shape: {len(data)} rows, {len(data.feature_columns)} columns")

# 2. Clean data
print("2. Cleaning data...")
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.clip(columns=["temperature"], min=0, max=50)
pipeline.clip(columns=["humidity"], min=0, max=100)

# 3. Create features
print("3. Creating features...")
pipeline.lag(columns=["temperature", "humidity"], periods=[1, 24])
pipeline.rolling_mean(columns=["temperature"], window=24)
pipeline.rolling_std(columns=["humidity"], window=24)

# 4. Normalize data
print("4. Normalizing data...")
pipeline.standardize(columns=["temperature", "humidity"])

# 5. Process
print("5. Processing data...")
result = pipeline.process(data)
print(f"   Processed shape: {len(result)} rows")

# 6. Export
print("6. Exporting results...")
result.to_csv("final_output.csv")
print("   Done!")
```

## Next Steps

- [Quick Start](/en/guide/quick-start) - More basic usage
- [API Reference](/en/api/core) - Complete API documentation
- [Industrial Use Cases](/en/examples/industrial) - More complex examples
