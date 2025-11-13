# 基础示例

本页面展示 Industryts 的基础使用示例。

## 传感器数据处理

### 场景

处理来自多个传感器的时间序列数据,包括温度、湿度和压力。

### 代码

```python
import industryts as its
import polars as pl
from datetime import datetime

# 1. 创建示例数据
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

# 2. 创建 TimeSeriesData
data = its.TimeSeriesData(df)
print(f"原始数据: {len(data)} 行")

# 3. 创建处理流程
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature", "humidity"], periods=[1, 2])
pipeline.rolling_mean(columns=["temperature"], window=24)
pipeline.standardize(columns=["temperature", "humidity"])

# 4. 处理数据
result = pipeline.process(data)
print(f"处理后数据: {len(result)} 行")

# 5. 导出结果
result.to_csv("processed_sensor_data.csv")
print("数据已保存")
```

## 多传感器数据聚合

### 场景

处理来自多个传感器的数据,并按传感器进行聚合。

### 代码

```python
import industryts as its
import polars as pl
from datetime import datetime

# 创建多传感器数据
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

# 创建处理流程
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

## 特征工程

### 场景

为机器学习模型创建特征。

### 代码

```python
import industryts as its
import polars as pl
from datetime import datetime

# 创建数据
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

# 创建特征
pipeline = its.Pipeline()
pipeline.lag(columns=["price"], periods=[1, 2, 3, 5, 7])  # 历史价格
pipeline.rolling_mean(columns=["price"], window=7)  # 7 天移动平均
pipeline.rolling_std(columns=["price"], window=7)  # 7 天标准差
pipeline.diff(columns=["price"], periods=1)  # 价格变化

result = pipeline.process(data)
print(result.to_polars())
```

## 时间序列重采样

### 场景

将高频数据重采样为低频。

### 代码

```python
import industryts as its
import polars as pl
from datetime import datetime

# 创建分钟级数据
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

# 重采样为小时级
pipeline = its.Pipeline()
pipeline.resample(method="mean", interval="1h")

result = pipeline.process(data)
print(f"原始数据: {len(data)} 行")
print(f"重采样后: {len(result)} 行")
```

## 数据清洗

### 场景

处理包含缺失值和异常值的数据。

### 代码

```python
import industryts as its
import polars as pl
from datetime import datetime

# 创建包含缺失值的数据
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

# 清洗数据
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")  # 前向填充
pipeline.clip(columns=["temperature"], min=15, max=30)  # 限制范围
pipeline.drop_null()  # 删除仍有缺失值的行

result = pipeline.process(data)
print(result.to_polars())
```

## 使用 TOML 配置

### 场景

使用配置文件定义可重现的处理流程。

### 配置文件 (pipeline.toml)

```toml
[pipeline]
name = "sensor_processing"
time_column = "DateTime"
description = "处理传感器数据的流程"

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

### Python 代码

```python
import industryts as its

# 从配置加载流程
pipeline = its.Pipeline.from_toml("pipeline.toml")

# 加载数据
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# 处理数据
result = pipeline.process(data)

# 导出结果
result.to_csv("output.csv")
```

## 完整工作流

### 场景

从数据加载到结果导出的完整工作流。

### 代码

```python
import industryts as its
import polars as pl
from datetime import datetime

# 1. 数据准备
print("1. 准备数据...")
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
print(f"   数据形状: {len(data)} 行, {len(data.feature_columns)} 列")

# 2. 数据清洗
print("2. 清洗数据...")
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.clip(columns=["temperature"], min=0, max=50)
pipeline.clip(columns=["humidity"], min=0, max=100)

# 3. 特征工程
print("3. 创建特征...")
pipeline.lag(columns=["temperature", "humidity"], periods=[1, 24])
pipeline.rolling_mean(columns=["temperature"], window=24)
pipeline.rolling_std(columns=["humidity"], window=24)

# 4. 数据标准化
print("4. 标准化数据...")
pipeline.standardize(columns=["temperature", "humidity"])

# 5. 处理
print("5. 处理数据...")
result = pipeline.process(data)
print(f"   处理后形状: {len(result)} 行")

# 6. 导出
print("6. 导出结果...")
result.to_csv("final_output.csv")
print("   完成!")
```

## 下一步

- [快速开始](/guide/quick-start) - 更多基础用法
- [API 参考](/api/core) - 完整的 API 文档
- [工业应用案例](/examples/industrial) - 更复杂的示例
