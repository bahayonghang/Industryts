# TimeSeriesData

`TimeSeriesData` is the core data container in Industryts for storing and processing time series data.

## Overview

`TimeSeriesData` is based on Polars DataFrame and provides an optimized interface for time series data. It automatically identifies the time column and provides convenient methods to access and manipulate time series data.

## Creating TimeSeriesData

### From Polars DataFrame

```python
import industryts as its
import polars as pl
from datetime import datetime

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
```

### From CSV File

```python
data = its.TimeSeriesData.from_csv("sensor_data.csv")
```

### From Parquet File

```python
data = its.TimeSeriesData.from_parquet("sensor_data.parquet")
```

### From Polars LazyFrame

```python
lazy_df = pl.scan_csv("sensor_data.csv")
data = its.TimeSeriesData.from_lazy(lazy_df)
```

## Properties

### time_column

Get the name of the time column.

```python
time_col = data.time_column
print(f"Time column: {time_col}")  # Output: Time column: DateTime
```

### feature_columns

Get names of all feature columns.

```python
features = data.feature_columns
print(f"Feature columns: {features}")  # Output: Feature columns: ['temperature', 'humidity']
```

### columns

Get names of all columns.

```python
all_cols = data.columns
print(f"All columns: {all_cols}")  # Output: All columns: ['DateTime', 'temperature', 'humidity']
```

### shape

Get data shape (rows, columns).

```python
rows, cols = data.shape
print(f"Shape: {rows} rows, {cols} columns")
```

## Methods

### len()

Get number of rows.

```python
num_rows = len(data)
print(f"Number of rows: {num_rows}")
```

### to_polars()

Convert to Polars DataFrame.

```python
df = data.to_polars()
print(df)
```

### to_csv()

Export to CSV file.

```python
data.to_csv("output.csv")
```

### to_parquet()

Export to Parquet file.

```python
data.to_parquet("output.parquet")
```

### describe()

Get data statistics.

```python
stats = data.describe()
print(stats)
```

### select()

Select specific columns.

```python
subset = data.select(["temperature", "humidity"])
```

### filter()

Filter rows.

```python
# Filter rows where temperature > 20
filtered = data.filter(data["temperature"] > 20)
```

### head()

Get first N rows.

```python
first_10 = data.head(10)
```

### tail()

Get last N rows.

```python
last_10 = data.tail(10)
```

## Data Types

TimeSeriesData supports the following data types:

- **Numeric Types**: Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float32, Float64
- **String Types**: String, Utf8
- **Time Types**: Date, Datetime, Time, Duration
- **Boolean Type**: Boolean
- **Other Types**: List, Struct, Categorical

## Time Column Detection

TimeSeriesData automatically detects the time column. Detection rules:

1. Columns named `DateTime`, `Datetime`, `date`, `Date`, `time`, `Time`
2. Columns with data type `Date`, `Datetime`, `Time`
3. Manual specification if auto-detection fails

```python
# Manually specify time column
data = its.TimeSeriesData(df, time_column="timestamp")
```

## Performance Features

### Zero-Copy Operations

TimeSeriesData leverages Polars' zero-copy capabilities for efficient data operations.

```python
# These operations are all zero-copy
subset = data.select(["temperature"])
filtered = data.filter(data["temperature"] > 20)
```

### Columnar Storage

Data is stored in columnar format, which provides:
- Very fast column-wise operations
- High memory efficiency
- Easy parallelization

### Lazy Evaluation

Some operations support lazy evaluation, executing only when needed.

```python
# Create LazyFrame
lazy_data = data.lazy()

# Add operations (not executed immediately)
lazy_result = lazy_data.select(["temperature"]).filter(...)

# Execute computation
result = lazy_result.collect()
```

## Common Operations

### View Data

```python
# View first 5 rows
print(data.head())

# View last 5 rows
print(data.tail())

# View statistics
print(data.describe())
```

### Data Selection

```python
# Select specific column
temp_only = data.select(["temperature"])

# Select multiple columns
subset = data.select(["temperature", "humidity"])

# Select all columns except one
without_humidity = data.select([col for col in data.columns if col != "humidity"])
```

### Data Filtering

```python
# Simple filter
hot_days = data.filter(data["temperature"] > 25)

# Multiple conditions
hot_and_humid = data.filter(
    (data["temperature"] > 25) & (data["humidity"] > 60)
)

# Time range filter
from datetime import datetime
start = datetime(2024, 1, 5)
end = datetime(2024, 1, 10)
subset = data.filter(
    (data["DateTime"] >= start) & (data["DateTime"] <= end)
)
```

### Data Sorting

```python
# Sort by temperature
sorted_data = data.sort("temperature")

# Sort by time in descending order
sorted_desc = data.sort("DateTime", descending=True)
```

## Next Steps

- [Pipeline](/en/guide/concepts/pipeline) - Learn about data processing pipelines
- [Operations](/en/guide/concepts/operations) - Learn about available operations
- [Quick Start](/en/guide/quick-start) - Practical usage examples
