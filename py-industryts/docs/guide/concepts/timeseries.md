# TimeSeriesData

`TimeSeriesData` 是 Industryts 的核心数据容器,用于存储和处理时间序列数据。

## 概述

`TimeSeriesData` 基于 Polars DataFrame,提供了针对时间序列数据的优化接口。它自动识别时间列,并提供了便捷的方法来访问和操作时间序列数据。

## 创建 TimeSeriesData

### 从 Polars DataFrame

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

### 从 CSV 文件

```python
data = its.TimeSeriesData.from_csv("sensor_data.csv")
```

### 从 Parquet 文件

```python
data = its.TimeSeriesData.from_parquet("sensor_data.parquet")
```

### 从 Polars LazyFrame

```python
lazy_df = pl.scan_csv("sensor_data.csv")
data = its.TimeSeriesData.from_lazy(lazy_df)
```

## 属性

### time_column

获取时间列的名称。

```python
time_col = data.time_column
print(f"时间列: {time_col}")  # 输出: 时间列: DateTime
```

### feature_columns

获取所有特征列的名称。

```python
features = data.feature_columns
print(f"特征列: {features}")  # 输出: 特征列: ['temperature', 'humidity']
```

### columns

获取所有列的名称。

```python
all_cols = data.columns
print(f"所有列: {all_cols}")  # 输出: 所有列: ['DateTime', 'temperature', 'humidity']
```

### shape

获取数据的形状 (行数, 列数)。

```python
rows, cols = data.shape
print(f"形状: {rows} 行, {cols} 列")
```

## 方法

### len()

获取数据行数。

```python
num_rows = len(data)
print(f"数据行数: {num_rows}")
```

### to_polars()

转换为 Polars DataFrame。

```python
df = data.to_polars()
print(df)
```

### to_csv()

导出为 CSV 文件。

```python
data.to_csv("output.csv")
```

### to_parquet()

导出为 Parquet 文件。

```python
data.to_parquet("output.parquet")
```

### describe()

获取数据统计信息。

```python
stats = data.describe()
print(stats)
```

### select()

选择特定列。

```python
subset = data.select(["temperature", "humidity"])
```

### filter()

过滤行。

```python
# 过滤温度大于 20 的行
filtered = data.filter(data["temperature"] > 20)
```

### head()

获取前 N 行。

```python
first_10 = data.head(10)
```

### tail()

获取后 N 行。

```python
last_10 = data.tail(10)
```

## 数据类型

TimeSeriesData 支持以下数据类型:

- **数值类型**: Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float32, Float64
- **字符串类型**: String, Utf8
- **时间类型**: Date, Datetime, Time, Duration
- **布尔类型**: Boolean
- **其他类型**: List, Struct, Categorical

## 时间列识别

TimeSeriesData 自动识别时间列。识别规则如下:

1. 列名为 `DateTime`, `Datetime`, `date`, `Date`, `time`, `Time` 的列
2. 数据类型为 `Date`, `Datetime`, `Time` 的列
3. 如果没有自动识别,可以手动指定

```python
# 手动指定时间列
data = its.TimeSeriesData(df, time_column="timestamp")
```

## 性能特性

### 零拷贝操作

TimeSeriesData 利用 Polars 的零拷贝特性,使得数据操作非常高效。

```python
# 这些操作都是零拷贝的
subset = data.select(["temperature"])
filtered = data.filter(data["temperature"] > 20)
```

### 列式存储

数据以列式格式存储,这使得:
- 按列操作非常快
- 内存使用效率高
- 易于并行处理

### 惰性计算

某些操作支持惰性计算,只在需要时执行。

```python
# 创建 LazyFrame
lazy_data = data.lazy()

# 添加操作 (不立即执行)
lazy_result = lazy_data.select(["temperature"]).filter(...)

# 执行计算
result = lazy_result.collect()
```

## 常见操作

### 查看数据

```python
# 查看前 5 行
print(data.head())

# 查看后 5 行
print(data.tail())

# 查看统计信息
print(data.describe())
```

### 数据选择

```python
# 选择特定列
temp_only = data.select(["temperature"])

# 选择多列
subset = data.select(["temperature", "humidity"])

# 选择除了某列的所有列
without_humidity = data.select([col for col in data.columns if col != "humidity"])
```

### 数据过滤

```python
# 简单过滤
hot_days = data.filter(data["temperature"] > 25)

# 多条件过滤
hot_and_humid = data.filter(
    (data["temperature"] > 25) & (data["humidity"] > 60)
)

# 时间范围过滤
from datetime import datetime
start = datetime(2024, 1, 5)
end = datetime(2024, 1, 10)
subset = data.filter(
    (data["DateTime"] >= start) & (data["DateTime"] <= end)
)
```

### 数据排序

```python
# 按温度排序
sorted_data = data.sort("temperature")

# 按时间降序排序
sorted_desc = data.sort("DateTime", descending=True)
```

## 下一步

- [Pipeline](/guide/concepts/pipeline) - 了解数据处理流程
- [Operations](/guide/concepts/operations) - 了解可用的操作
- [快速开始](/guide/quick-start) - 实际使用示例
