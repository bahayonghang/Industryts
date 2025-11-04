# TimeSeriesData

`TimeSeriesData` 是 Industryts 的基础数据结构。它包装了一个 Polars DataFrame,并提供时间序列特定的功能和元数据。

## 概述

将 `TimeSeriesData` 视为一个专用容器:
- 以高性能列式格式存储您的时间序列数据
- 自动检测和管理时间列
- 提供便捷的数据加载和导出方法
- 通过 Rust 的类型系统确保类型安全

## 创建 TimeSeriesData

### 从 CSV 创建

创建 `TimeSeriesData` 最常见的方式是从 CSV 文件:

```python
import industryts as its

# 自动检测时间列
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# 或明确指定时间列
data = its.TimeSeriesData.from_csv(
    "sensor_data.csv",
    time_column="timestamp"
)
```

### 从 Parquet 创建

为了获得更好的性能和压缩:

```python
# 从 Parquet 加载
data = its.TimeSeriesData.from_parquet("sensor_data.parquet")
```

Parquet 的优势:
- **更快的加载**: 为分析优化的列式格式
- **更小的文件**: 内置压缩
- **类型保留**: 精确保持数据类型

### 从 Polars DataFrame 创建

如果您已经有一个 Polars DataFrame:

```python
import polars as pl
import industryts as its

# 创建 Polars DataFrame
df = pl.DataFrame({
    "DateTime": ["2024-01-01 00:00:00", "2024-01-01 01:00:00"],
    "temperature": [25.5, 25.8],
    "pressure": [101.3, 101.5]
})

# 转换为 TimeSeriesData
data = its.TimeSeriesData(df, time_column="DateTime")
```

::: tip
Industryts 基于 Polars 构建,因此转换是零拷贝且即时的!
:::

## 时间列检测

Industryts 自动检测常见名称的时间列:

```python
# 所有这些都会被自动检测
data = its.TimeSeriesData.from_csv("data1.csv")  # "DateTime" 列
data = its.TimeSeriesData.from_csv("data2.csv")  # "timestamp" 列
data = its.TimeSeriesData.from_csv("data3.csv")  # "tagTime" 列
```

**自动检测的名称**(不区分大小写):
- `DateTime`, `datetime`, `Datetime`
- `timestamp`, `Timestamp`
- `tagTime`, `time`, `Time`
- `date`, `Date`

如果您的时间列有不同的名称,请明确指定:

```python
data = its.TimeSeriesData.from_csv(
    "data.csv",
    time_column="custom_time_col"
)
```

## 访问数据

### 属性

```python
# 获取时间列名称
print(data.time_column)  # "DateTime"

# 获取特征列名称(除时间列外的所有列)
print(data.feature_columns)  # ["temperature", "pressure", "humidity"]

# 获取行数
print(len(data))  # 1000000
```

### 检查方法

```python
# 查看前几行
print(data.head())     # 前 5 行(默认)
print(data.head(10))   # 前 10 行

# 查看后几行
print(data.tail())     # 后 5 行(默认)
print(data.tail(20))   # 后 20 行

# 统计摘要
print(data.describe())
```

`head()` 的示例输出:
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

### 转换为其他格式

```python
# 转换为 Polars DataFrame(零拷贝)
df = data.to_polars()

# 转换为 CSV
data.to_csv("output.csv")

# 转换为 Parquet
data.to_parquet("output.parquet")
```

## 数据结构

在内部,`TimeSeriesData` 维护:

```python
TimeSeriesData {
    df: Polars DataFrame  # 实际数据
    time_column: str      # 时间列名称
    feature_columns: List[str]  # 特征列名称
}
```

### 时间列

时间列必须是:
- **类型**: Datetime (Polars `datetime` 类型)
- **格式**: ISO 8601 或标准日期时间字符串
- **唯一性**: 不要求(多行可以有相同的时间戳)
- **排序**: 不要求(操作可以在未排序的数据上工作)

### 特征列

特征列是:
- 所有数值列(int、float)
- 不包括时间列
- 用于 `standardize()`、`lag()` 等操作

## 零拷贝架构

Industryts 的关键性能特性之一是 Python 和 Rust 之间的零拷贝数据传输:

```python
# 加载数据: 零拷贝
df = pl.read_csv("data.csv")  # Python 中的 Polars DataFrame
data = its.TimeSeriesData(df)  # 零拷贝传输到 Rust

# 处理: 在 Rust 中操作
result = pipeline.process(data)  # 所有处理都在 Rust 中

# 检索结果: 零拷贝
df_out = result.to_polars()  # 零拷贝传输回 Python
```

这由 `pyo3-polars` 驱动,它实现了 Python 和 Rust 之间的直接内存共享。

## 常见模式

### 模式 1: 加载、检查、处理

```python
# 加载数据
data = its.TimeSeriesData.from_csv("sensors.csv")

# 检查数据结构
print(f"行数: {len(data)}")
print(f"时间列: {data.time_column}")
print(f"特征列: {data.feature_columns}")
print(data.head())

# 处理
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
result = pipeline.process(data)
```

### 模式 2: 从 pandas 转换

```python
import pandas as pd
import polars as pl
import industryts as its

# 使用 pandas 加载
df_pandas = pd.read_csv("data.csv")

# 转换为 Polars
df_polars = pl.from_pandas(df_pandas)

# 创建 TimeSeriesData
data = its.TimeSeriesData(df_polars, time_column="DateTime")
```

### 模式 3: 批量处理

```python
import glob

# 处理多个文件
for file in glob.glob("data/*.csv"):
    data = its.TimeSeriesData.from_csv(file)
    result = pipeline.process(data)  # 重用流程
    result.to_parquet(f"processed/{file.stem}.parquet")
```

## 性能特征

### 内存使用

```python
# Polars 使用的内存比 pandas 少约 50%
data = its.TimeSeriesData.from_csv("large_data.csv")
# 列式存储 + 压缩 = 高效的内存使用
```

### 加载速度

| 格式 | 100 万行 | 1000 万行 |
|--------|---------|----------|
| CSV | ~500ms | ~5s |
| Parquet | ~50ms | ~500ms |

**建议**: 对大数据集使用 Parquet

### 零拷贝传输

```python
# 无拷贝 - 即时
df = pl.read_csv("data.csv")
data = its.TimeSeriesData(df)  # <1ms

# 有拷贝(pandas → polars)
df_pandas = pd.read_csv("data.csv")
df_polars = pl.from_pandas(df_pandas)  # 复制数据
data = its.TimeSeriesData(df_polars)
```

## 最佳实践

### ✅ 推荐

- 对大数据集和频繁读取使用 Parquet
- 尽可能让 Industryts 自动检测时间列
- 重用 `Pipeline` 对象进行批量处理
- 在已有 Polars DataFrame 时直接使用

### ❌ 不推荐

- 不要使用 pandas DataFrame(先转换为 Polars)
- 创建 TimeSeriesData 后不要修改底层 DataFrame
- 不要假设时间列已排序(需要时明确排序)

## API 参考

查看完整的 [TimeSeriesData API 参考](/zh/api/timeseries) 了解所有方法和参数。

## 下一步

- **[Pipeline](/zh/guide/concepts/pipeline)** - 了解流程架构
- **[加载数据](/zh/guide/loading-data)** - 数据加载详细指南
- **[API 参考](/zh/api/timeseries)** - 完整的 API 文档
