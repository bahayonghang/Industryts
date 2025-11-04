# TimeSeriesData

`TimeSeriesData` is the fundamental data structure in Industryts. It wraps a Polars DataFrame with time series-specific functionality and metadata.

## Overview

Think of `TimeSeriesData` as a specialized container that:
- Stores your time series data in a high-performance columnar format
- Automatically detects and manages the time column
- Provides convenient methods for loading and exporting data
- Ensures type safety through Rust's type system

## Creating TimeSeriesData

### From CSV

The most common way to create `TimeSeriesData` is from a CSV file:

```python
import industryts as its

# Auto-detect time column
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Or specify time column explicitly
data = its.TimeSeriesData.from_csv(
    "sensor_data.csv",
    time_column="timestamp"
)
```

###  From Parquet

For better performance and compression:

```python
# Load from Parquet
data = its.TimeSeriesData.from_parquet("sensor_data.parquet")
```

Parquet benefits:
- **Faster loading**: Columnar format optimized for analytics
- **Smaller files**: Built-in compression
- **Type preservation**: Maintains data types exactly

### From Polars DataFrame

If you already have a Polars DataFrame:

```python
import polars as pl
import industryts as its

# Create Polars DataFrame
df = pl.DataFrame({
    "DateTime": ["2024-01-01 00:00:00", "2024-01-01 01:00:00"],
    "temperature": [25.5, 25.8],
    "pressure": [101.3, 101.5]
})

# Convert to TimeSeriesData
data = its.TimeSeriesData(df, time_column="DateTime")
```

::: tip
Industryts is built on Polars, so conversion is zero-copy and instant!
:::

## Time Column Detection

Industryts automatically detects time columns with common names:

```python
# All of these are auto-detected
data = its.TimeSeriesData.from_csv("data1.csv")  # "DateTime" column
data = its.TimeSeriesData.from_csv("data2.csv")  # "timestamp" column
data = its.TimeSeriesData.from_csv("data3.csv")  # "tagTime" column
```

**Auto-detected names** (case-insensitive):
- `DateTime`, `datetime`, `Datetime`
- `timestamp`, `Timestamp`
- `tagTime`, `time`, `Time`
- `date`, `Date`

If your time column has a different name, specify it explicitly:

```python
data = its.TimeSeriesData.from_csv(
    "data.csv",
    time_column="custom_time_col"
)
```

## Accessing Data

### Properties

```python
# Get time column name
print(data.time_column)  # "DateTime"

# Get feature column names (all columns except time)
print(data.feature_columns)  # ["temperature", "pressure", "humidity"]

# Get number of rows
print(len(data))  # 1000000
```

### Inspection Methods

```python
# View first rows
print(data.head())     # First 5 rows (default)
print(data.head(10))   # First 10 rows

# View last rows
print(data.tail())     # Last 5 rows (default)
print(data.tail(20))   # Last 20 rows

# Statistical summary
print(data.describe())
```

Example output of `head()`:
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
```

### Converting to Other Formats

```python
# To Polars DataFrame (zero-copy)
df = data.to_polars()

# To CSV
data.to_csv("output.csv")

# To Parquet
data.to_parquet("output.parquet")
```

## Data Structure

Internally, `TimeSeriesData` maintains:

```python
TimeSeriesData {
    df: Polars DataFrame  # The actual data
    time_column: str      # Name of time column
    feature_columns: List[str]  # Names of feature columns
}
```

### Time Column

The time column must be:
- **Type**: Datetime (Polars `datetime` type)
- **Format**: ISO 8601 or standard datetime string
- **Uniqueness**: Not required (multiple rows can have same timestamp)
- **Sorting**: Not required (operations work on unsorted data)

### Feature Columns

Feature columns are:
- All numeric columns (int, float)
- Excluding the time column
- Used in operations like `standardize()`, `lag()`, etc.

## Zero-Copy Architecture

One of Industryts' key performance features is zero-copy data transfer between Python and Rust:

```python
# Loading data: zero-copy
df = pl.read_csv("data.csv")  # Polars DataFrame in Python
data = its.TimeSeriesData(df)  # Zero-copy transfer to Rust

# Processing: operates in Rust
result = pipeline.process(data)  # All processing in Rust

# Retrieving results: zero-copy
df_out = result.to_polars()  # Zero-copy transfer back to Python
```

This is powered by `pyo3-polars`, which enables direct memory sharing between Python and Rust.

## Common Patterns

### Pattern 1: Load, Inspect, Process

```python
# Load data
data = its.TimeSeriesData.from_csv("sensors.csv")

# Inspect data structure
print(f"Rows: {len(data)}")
print(f"Time: {data.time_column}")
print(f"Features: {data.feature_columns}")
print(data.head())

# Process
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
result = pipeline.process(data)
```

### Pattern 2: Convert from pandas

```python
import pandas as pd
import polars as pl
import industryts as its

# Load with pandas
df_pandas = pd.read_csv("data.csv")

# Convert to Polars
df_polars = pl.from_pandas(df_pandas)

# Create TimeSeriesData
data = its.TimeSeriesData(df_polars, time_column="DateTime")
```

### Pattern 3: Batch Processing

```python
import glob

# Process multiple files
for file in glob.glob("data/*.csv"):
    data = its.TimeSeriesData.from_csv(file)
    result = pipeline.process(data)  # Reuse pipeline
    result.to_parquet(f"processed/{file.stem}.parquet")
```

## Performance Characteristics

### Memory Usage

```python
# Polars uses ~50% less memory than pandas
data = its.TimeSeriesData.from_csv("large_data.csv")
# Columnar storage + compression = efficient memory use
```

### Loading Speed

| Format | 1M rows | 10M rows |
|--------|---------|----------|
| CSV | ~500ms | ~5s |
| Parquet | ~50ms | ~500ms |

**Recommendation**: Use Parquet for large datasets

### Zero-Copy Transfers

```python
# No copy - instant
df = pl.read_csv("data.csv")
data = its.TimeSeriesData(df)  # <1ms

# With copy (pandas → polars)
df_pandas = pd.read_csv("data.csv")
df_polars = pl.from_pandas(df_pandas)  # Copies data
data = its.TimeSeriesData(df_polars)
```

## Best Practices

### ✅ Do

- Use Parquet for large datasets and frequent reads
- Let Industryts auto-detect time columns when possible
- Reuse `Pipeline` objects for batch processing
- Use Polars DataFrames directly when already available

### ❌ Don't

- Don't use pandas DataFrames (convert to Polars first)
- Don't modify the underlying DataFrame after creating TimeSeriesData
- Don't assume time column is sorted (explicitly sort if required)

## API Reference

See the complete [TimeSeriesData API Reference](/en/api/timeseries) for all methods and parameters.

## Next Steps

- **[Pipeline](/en/guide/concepts/pipeline)** - Learn about pipeline architecture
- **[Loading Data](/en/guide/loading-data)** - Detailed guide on data loading
- **[API Reference](/en/api/timeseries)** - Complete API documentation
