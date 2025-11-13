# Core Classes

This page introduces the core classes of Industryts.

## TimeSeriesData

`TimeSeriesData` is the main container for time series data, based on Polars DataFrame.

### Creating TimeSeriesData

```python
import industryts as its
import polars as pl
from datetime import datetime

# Create from Polars DataFrame
df = pl.DataFrame({
    "DateTime": pl.datetime_range(
        start=datetime(2024, 1, 1),
        end=datetime(2024, 1, 10),
        interval="1d",
        eager=True
    ),
    "temperature": [20.0, 21.0, 19.5, 22.0, 21.5, 20.5, 21.0, 20.0, 21.5, 22.0],
    "humidity": [50.0, 52.0, 48.0, 55.0, 51.0, 49.0, 50.0, 51.0, 52.0, 53.0]
})

data = its.TimeSeriesData(df)

# Load from CSV
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Create from Polars LazyFrame
lazy_df = pl.scan_csv("sensor_data.csv")
data = its.TimeSeriesData.from_lazy(lazy_df)
```

### Main Properties

```python
# Get time column name
time_column = data.time_column

# Get feature column names
feature_columns = data.feature_columns

# Get number of rows
num_rows = len(data)

# Get underlying Polars DataFrame
df = data.to_polars()
```

### Main Methods

```python
# Convert to Polars DataFrame
df = data.to_polars()

# Export to CSV
data.to_csv("output.csv")

# Export to Parquet
data.to_parquet("output.parquet")

# Get column information
columns = data.columns

# Get data statistics
stats = data.describe()

# Select columns
subset = data.select(["temperature", "humidity"])

# Filter rows
filtered = data.filter(data["temperature"] > 20)
```

## Pipeline

`Pipeline` is the main class for data processing workflows, supporting method chaining and TOML configuration.

### Creating Pipeline

```python
import industryts as its

# Create empty Pipeline
pipeline = its.Pipeline()

# Load from TOML
pipeline = its.Pipeline.from_toml("pipeline.toml")

# Load from JSON
pipeline = its.Pipeline.from_json("pipeline.json")
```

### Adding Operations

```python
pipeline = its.Pipeline()

# Method chaining
pipeline.fill_null(method="forward") \
    .lag(columns=["temperature"], periods=[1, 2]) \
    .standardize(columns=["temperature", "humidity"]) \
    .resample(method="mean", interval="1h")

# Or add separately
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature"], periods=[1, 2])
pipeline.standardize(columns=["temperature", "humidity"])
```

### Processing Data

```python
# Process TimeSeriesData
result = pipeline.process(data)

# Process Polars DataFrame
df = pl.read_csv("data.csv")
result = pipeline.process(df)

# Get processed DataFrame
result_df = result.to_polars()
```

### Export Configuration

```python
# Export to TOML
pipeline.to_toml("pipeline.toml")

# Export to JSON
pipeline.to_json("pipeline.json")

# Get configuration dictionary
config = pipeline.to_dict()
```

## Operation Types

### Data Cleaning

#### fill_null

Fill missing values.

```python
pipeline.fill_null(
    method="forward",  # "forward", "backward", "mean", "median", "zero"
    columns=None  # Specify columns, None for all
)
```

#### drop_null

Drop rows with missing values.

```python
pipeline.drop_null(columns=None)
```

#### clip

Limit value range.

```python
pipeline.clip(
    columns=["temperature"],
    min=0,
    max=50
)
```

### Feature Engineering

#### lag

Create lag features.

```python
pipeline.lag(
    columns=["temperature", "humidity"],
    periods=[1, 2, 3]
)
```

#### rolling_mean

Calculate rolling mean.

```python
pipeline.rolling_mean(
    columns=["temperature"],
    window=24,
    min_periods=1
)
```

#### rolling_std

Calculate rolling standard deviation.

```python
pipeline.rolling_std(
    columns=["temperature"],
    window=24,
    min_periods=1
)
```

#### diff

Calculate differences.

```python
pipeline.diff(
    columns=["temperature"],
    periods=1
)
```

#### standardize

Standardize (z-score).

```python
pipeline.standardize(columns=["temperature", "humidity"])
```

#### normalize

Normalize to specified range.

```python
pipeline.normalize(
    columns=["temperature"],
    min=0,
    max=1
)
```

### Time Operations

#### resample

Resample time series.

```python
pipeline.resample(
    method="mean",  # "mean", "sum", "min", "max", "first", "last"
    interval="1h"  # "1s", "1m", "1h", "1d", "1w", "1mo", "1y"
)
```

#### extract_time_features

Extract time features.

```python
pipeline.extract_time_features(
    columns=["DateTime"],
    features=["year", "month", "day", "hour", "minute", "second", "dayofweek"]
)
```

### Aggregation

#### groupby

Group aggregation.

```python
pipeline.groupby(
    by=["sensor_id"],
    aggregations={
        "temperature": "mean",
        "humidity": "max",
        "pressure": "min"
    }
)
```

#### aggregate

Multi-column aggregation.

```python
pipeline.aggregate(
    aggregations={
        "temperature": ["mean", "std", "min", "max"],
        "humidity": ["mean", "median"]
    }
)
```

## Exception Handling

```python
import industryts as its

try:
    pipeline = its.Pipeline()
    pipeline.fill_null(method="invalid")  # Invalid method
    result = pipeline.process(data)
except ValueError as e:
    print(f"Error: {e}")
except Exception as e:
    print(f"Unknown error: {e}")
```

## Next Steps

- [TimeSeriesData Details](/en/api/timeseries) - Deep dive into TimeSeriesData
- [Pipeline Details](/en/api/pipeline) - Deep dive into Pipeline
- [Operations Reference](/en/api/operations) - Detailed reference for all operations
