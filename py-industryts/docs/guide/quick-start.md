# 快速开始

本指南将帮助你快速上手 Industryts,创建第一个时间序列处理流程。

## 基础示例

### 1. 导入和加载数据

```python
import industryts as its
import polars as pl
from datetime import datetime, timedelta

# 创建示例时间序列数据
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

# 创建 TimeSeriesData
data = its.TimeSeriesData(df)
print(f"数据形状: {len(data)} 行, {len(data.feature_columns)} 列")
```

### 2. 创建处理流程

```python
# 创建 Pipeline
pipeline = its.Pipeline()

# 添加操作
pipeline.fill_null(method="forward")  # 填充缺失值
pipeline.lag(columns=["temperature"], periods=[1, 2])  # 创建滞后特征
pipeline.standardize(columns=["temperature", "humidity"])  # 标准化

# 处理数据
result = pipeline.process(data)
print(f"处理后的数据形状: {len(result)} 行")
```

### 3. 导出结果

```python
# 转换为 Polars DataFrame
result_df = result.to_polars()
print(result_df)

# 导出为 CSV
result.to_csv("processed_data.csv")
```

## 使用 TOML 配置

### 创建配置文件

创建 `pipeline.toml`:

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

### 从配置加载和使用

```python
import industryts as its

# 从 TOML 加载流程
pipeline = its.Pipeline.from_toml("pipeline.toml")

# 加载数据
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# 处理数据
result = pipeline.process(data)

# 导出结果
result.to_csv("output.csv")
```

## 常见操作

### 数据清洗

```python
pipeline = its.Pipeline()

# 填充缺失值
pipeline.fill_null(method="forward")  # 前向填充
pipeline.fill_null(method="backward")  # 后向填充
pipeline.fill_null(method="mean")  # 均值填充

# 删除缺失值
pipeline.drop_null()

# 值限制
pipeline.clip(columns=["temperature"], min=0, max=50)
```

### 特征工程

```python
pipeline = its.Pipeline()

# 滞后特征
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])

# 滚动统计
pipeline.rolling_mean(columns=["temperature"], window=24)
pipeline.rolling_std(columns=["temperature"], window=24)

# 差分
pipeline.diff(columns=["temperature"], periods=1)

# 标准化
pipeline.standardize(columns=["temperature", "humidity"])

# 归一化
pipeline.normalize(columns=["temperature"], min=0, max=1)
```

### 时间操作

```python
pipeline = its.Pipeline()

# 重采样
pipeline.resample(method="mean", interval="1h")

# 提取时间特征
pipeline.extract_time_features(columns=["DateTime"])

# 时间窗口聚合
pipeline.time_window_aggregate(
    window="1d",
    aggregations={"temperature": "mean", "humidity": "max"}
)
```

### 数据聚合

```python
pipeline = its.Pipeline()

# 分组聚合
pipeline.groupby(
    by=["sensor_id"],
    aggregations={"temperature": "mean", "humidity": "max"}
)

# 多列聚合
pipeline.aggregate(
    aggregations={
        "temperature": ["mean", "std", "min", "max"],
        "humidity": ["mean"]
    }
)
```

## 完整工作流示例

```python
import industryts as its
import polars as pl
from datetime import datetime

# 1. 加载数据
data = its.TimeSeriesData.from_csv("sensor_data.csv")
print(f"原始数据: {len(data)} 行")

# 2. 创建处理流程
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature", "humidity"], periods=[1, 2])
pipeline.rolling_mean(columns=["temperature"], window=24)
pipeline.standardize(columns=["temperature", "humidity"])

# 3. 处理数据
result = pipeline.process(data)
print(f"处理后数据: {len(result)} 行")

# 4. 导出结果
result.to_csv("processed_sensor_data.csv")
print("数据已保存到 processed_sensor_data.csv")

# 5. 查看结果
result_df = result.to_polars()
print(result_df.head())
```

## 性能提示

1. **使用 TOML 配置**: 对于生产环境,使用 TOML 配置确保可重现性
2. **批量处理**: 一次性处理大量数据比多次小批量处理更快
3. **选择合适的操作顺序**: 先进行过滤,再进行计算密集的操作
4. **使用类型提示**: 充分利用 Python 类型提示获得更好的 IDE 支持

## 下一步

- [核心概念](/guide/concepts/timeseries) - 深入理解 TimeSeriesData
- [API 参考](/api/core) - 完整的 API 文档
- [示例](/examples/basic) - 更多实际使用示例
