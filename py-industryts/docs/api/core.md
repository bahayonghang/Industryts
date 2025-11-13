# 核心类

本页面介绍 Industryts 的核心类。

## TimeSeriesData

`TimeSeriesData` 是时间序列数据的主要容器,基于 Polars DataFrame。

### 创建 TimeSeriesData

```python
import industryts as its
import polars as pl
from datetime import datetime

# 从 Polars DataFrame 创建
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

# 从 CSV 加载
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# 从 Polars LazyFrame 创建
lazy_df = pl.scan_csv("sensor_data.csv")
data = its.TimeSeriesData.from_lazy(lazy_df)
```

### 主要属性

```python
# 获取时间列名
time_column = data.time_column

# 获取特征列名
feature_columns = data.feature_columns

# 获取数据行数
num_rows = len(data)

# 获取底层 Polars DataFrame
df = data.to_polars()
```

### 主要方法

```python
# 转换为 Polars DataFrame
df = data.to_polars()

# 导出为 CSV
data.to_csv("output.csv")

# 导出为 Parquet
data.to_parquet("output.parquet")

# 获取列信息
columns = data.columns

# 获取数据统计信息
stats = data.describe()

# 选择列
subset = data.select(["temperature", "humidity"])

# 过滤行
filtered = data.filter(data["temperature"] > 20)
```

## Pipeline

`Pipeline` 是数据处理流程的主要类,支持链式调用和 TOML 配置。

### 创建 Pipeline

```python
import industryts as its

# 创建空 Pipeline
pipeline = its.Pipeline()

# 从 TOML 加载
pipeline = its.Pipeline.from_toml("pipeline.toml")

# 从 JSON 加载
pipeline = its.Pipeline.from_json("pipeline.json")
```

### 添加操作

```python
pipeline = its.Pipeline()

# 链式调用
pipeline.fill_null(method="forward") \
    .lag(columns=["temperature"], periods=[1, 2]) \
    .standardize(columns=["temperature", "humidity"]) \
    .resample(method="mean", interval="1h")

# 或分别添加
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature"], periods=[1, 2])
pipeline.standardize(columns=["temperature", "humidity"])
```

### 处理数据

```python
# 处理 TimeSeriesData
result = pipeline.process(data)

# 处理 Polars DataFrame
df = pl.read_csv("data.csv")
result = pipeline.process(df)

# 获取处理后的 DataFrame
result_df = result.to_polars()
```

### 导出配置

```python
# 导出为 TOML
pipeline.to_toml("pipeline.toml")

# 导出为 JSON
pipeline.to_json("pipeline.json")

# 获取配置字典
config = pipeline.to_dict()
```

## 操作类型

### 数据清洗

#### fill_null

填充缺失值。

```python
pipeline.fill_null(
    method="forward",  # "forward", "backward", "mean", "median", "zero"
    columns=None  # 指定列,None 表示所有列
)
```

#### drop_null

删除包含缺失值的行。

```python
pipeline.drop_null(columns=None)
```

#### clip

限制值的范围。

```python
pipeline.clip(
    columns=["temperature"],
    min=0,
    max=50
)
```

### 特征工程

#### lag

创建滞后特征。

```python
pipeline.lag(
    columns=["temperature", "humidity"],
    periods=[1, 2, 3]
)
```

#### rolling_mean

计算滚动平均。

```python
pipeline.rolling_mean(
    columns=["temperature"],
    window=24,
    min_periods=1
)
```

#### rolling_std

计算滚动标准差。

```python
pipeline.rolling_std(
    columns=["temperature"],
    window=24,
    min_periods=1
)
```

#### diff

计算差分。

```python
pipeline.diff(
    columns=["temperature"],
    periods=1
)
```

#### standardize

标准化 (z-score)。

```python
pipeline.standardize(columns=["temperature", "humidity"])
```

#### normalize

归一化到指定范围。

```python
pipeline.normalize(
    columns=["temperature"],
    min=0,
    max=1
)
```

### 时间操作

#### resample

重采样时间序列。

```python
pipeline.resample(
    method="mean",  # "mean", "sum", "min", "max", "first", "last"
    interval="1h"  # "1s", "1m", "1h", "1d", "1w", "1mo", "1y"
)
```

#### extract_time_features

提取时间特征。

```python
pipeline.extract_time_features(
    columns=["DateTime"],
    features=["year", "month", "day", "hour", "minute", "second", "dayofweek"]
)
```

### 聚合

#### groupby

分组聚合。

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

多列聚合。

```python
pipeline.aggregate(
    aggregations={
        "temperature": ["mean", "std", "min", "max"],
        "humidity": ["mean", "median"]
    }
)
```

## 异常处理

```python
import industryts as its

try:
    pipeline = its.Pipeline()
    pipeline.fill_null(method="invalid")  # 无效的方法
    result = pipeline.process(data)
except ValueError as e:
    print(f"错误: {e}")
except Exception as e:
    print(f"未知错误: {e}")
```

## 下一步

- [TimeSeriesData 详解](/api/timeseries) - 深入了解 TimeSeriesData
- [Pipeline 详解](/api/pipeline) - 深入了解 Pipeline
- [操作参考](/api/operations) - 所有操作的详细参考
