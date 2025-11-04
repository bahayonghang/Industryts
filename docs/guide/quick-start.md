# 快速开始

本指南将带您创建第一个 Industryts 时间序列处理流程。您将在不到 10 分钟内掌握基础知识!

## 先决条件

确保已安装 Industryts:

```bash
pip install industryts
```

详细安装说明请参阅[安装指南](/guide/installation)。

## 您的第一个流程

让我们处理来自工业系统的传感器数据。我们将清洗缺失值、创建滞后特征并标准化数据。

### 步骤 1: 准备示例数据

创建包含时间序列数据的 CSV 文件 `sensor_data.csv`:

```csv
DateTime,temperature,pressure,humidity
2024-01-01 00:00:00,25.5,101.3,45.2
2024-01-01 01:00:00,25.8,101.5,44.8
2024-01-01 02:00:00,,101.2,45.5
2024-01-01 03:00:00,26.1,101.4,44.2
2024-01-01 04:00:00,26.3,101.6,43.9
2024-01-01 05:00:00,26.5,,44.5
2024-01-01 06:00:00,26.8,101.8,44.1
```

::: tip
在实际场景中,您会从数据源加载数据。Industryts 支持 CSV、Parquet 和 Polars DataFrames。
:::

### 步骤 2: 加载数据

```python
import industryts as its

# 加载时间序列数据
# Industryts 自动检测时间列 (DateTime, timestamp 等)
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# 检查数据
print(data.head())
print(f"时间列: {data.time_column}")
print(f"特征列: {data.feature_columns}")
```

预期输出:
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

时间列: DateTime
特征列: ['temperature', 'pressure', 'humidity']
```

::: tip 自动检测
Industryts 自动检测常见名称的时间列,如:
- `DateTime`, `datetime`, `Datetime`
- `timestamp`, `Timestamp`
- `tagTime`, `time`, `Time`
- `date`, `Date`

您也可以手动指定: `TimeSeriesData.from_csv("data.csv", time_column="my_time")`
:::

### 步骤 3: 构建流程(编程式 API)

现在让我们构建一个处理流程:

```python
# 创建流程
pipeline = its.Pipeline()

# 添加操作
pipeline.fill_null(method="forward")  # ✅ 向前填充缺失值
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])  # ✅ 创建滞后特征
pipeline.standardize()  # ✅ 标准化所有特征列

# 处理数据
result = pipeline.process(data)

# 检查结果
print(result.head())
```

预期输出显示新的滞后列和标准化后的值:
```
shape: (5, 7)
┌─────────────────────┬─────────────┬──────────┬──────────┬─────────────────┬─────────────────┬─────────────────┐
│ DateTime            │ temperature │ pressure │ humidity │ temperature_lag1│ temperature_lag2│ temperature_lag3│
│ ---                 │ ---         │ ---      │ ---      │ ---             │ ---             │ ---             │
│ datetime[μs]        │ f64         │ f64      │ f64      │ f64             │ f64             │ f64             │
╞═════════════════════╪═════════════╪══════════╪══════════╪═════════════════╪═════════════════╪═════════════════╡
│ 2024-01-01 00:00:00 │ -1.52       │ -1.34    │ 1.42     │ null            │ null            │ null            │
│ 2024-01-01 01:00:00 │ -1.21       │ -0.89    │ 0.98     │ 25.5            │ null            │ null            │
│ 2024-01-01 02:00:00 │ -1.21       │ -1.56    │ 1.87     │ 25.8            │ 25.5            │ null            │
│ ...                 │ ...         │ ...      │ ...      │ ...             │ ...             │ ...             │
└─────────────────────┴─────────────┴──────────┴──────────┴─────────────────┴─────────────────┴─────────────────┘
```

### 步骤 4: 保存结果

```python
# 保存为 CSV
result.to_csv("processed_data.csv")

# 或保存为 Parquet 以获得更好的性能
result.to_parquet("processed_data.parquet")

# 或获取 Polars DataFrame 以进行进一步处理
df = result.to_polars()
print(df.describe())
```

## 使用 TOML 的声明式 API

对于可重现的工作流,在 TOML 配置文件中定义您的流程。

### 创建 `pipeline.toml`

```toml
[pipeline]
name = "sensor_processing"
time_column = "DateTime"  # 可选: 默认自动检测

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
columns = ["temperature"]
periods = [1, 2, 3]

[[operations]]
type = "standardize"
# columns 未指定 = 标准化所有特征列
```

### 使用 TOML 流程

```python
import industryts as its

# 从配置加载流程
pipeline = its.Pipeline.from_toml("pipeline.toml")

# 加载和处理数据
data = its.TimeSeriesData.from_csv("sensor_data.csv")
result = pipeline.process(data)

# 保存结果
result.to_csv("processed_data.csv")
```

::: tip 为什么使用 TOML?
- **版本控制**: 在 git 中跟踪流程变更
- **代码审查**: 将数据处理与代码分开审查
- **可重现性**: 跨环境获得相同结果
- **文档化**: 自我文档化的结构
:::

## 理解操作

让我们分解每个操作的作用:

### 1. fill_null - 处理缺失值 ✅

```python
pipeline.fill_null(method="forward")
```

使用向前传播填充空值。可用方法:
- `"forward"` - 使用前一个有效值
- `"backward"` - 使用下一个有效值
- `"mean"` - 使用列均值
- `"zero"` - 填充为 0

[了解更多关于 fill_null](/guide/cleaning#fill-null)

### 2. lag - 创建滞后特征 ✅

```python
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
```

为时间序列预测创建滞后特征:
- `temperature_lag1`: 1 个周期前的值
- `temperature_lag2`: 2 个周期前的值
- `temperature_lag3`: 3 个周期前的值

[了解更多关于滞后特征](/guide/features#lag-features)

### 3. standardize - Z-Score 标准化 ✅

```python
pipeline.standardize()  # 所有特征列
# 或指定列
pipeline.standardize(columns=["temperature", "pressure"])
```

使用 z-score 将数据标准化为均值=0,标准差=1:
```
z = (x - 均值) / 标准差
```

[了解更多关于标准化](/guide/transforms#standardization)

## 操作状态

| 操作 | 状态 | 文档 |
|-----------|--------|---------------|
| fill_null | ✅ 已实现 | [指南](/guide/cleaning#fill-null) |
| lag | ✅ 已实现 | [指南](/guide/features#lag-features) |
| standardize | ✅ 已实现 | [指南](/guide/transforms#standardization) |
| resample | 🚧 等待 Polars 0.51 API | [指南](/guide/time-ops#resample) |
| rolling | 📋 计划中 | 即将推出 |
| outlier detection | 📋 计划中 | 即将推出 |

## 常见模式

### 模式 1: 基础清洗流程

```python
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.standardize()
```

### 模式 2: 机器学习特征工程

```python
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature", "pressure"], periods=[1, 2, 3, 6, 12])
pipeline.standardize()
```

### 模式 3: 同一列的多个操作

```python
pipeline = its.Pipeline()
pipeline.fill_null(method="mean")  # 首先清洗
pipeline.lag(columns=["temperature"], periods=[1])  # 然后滞后
pipeline.standardize(columns=["temperature", "temperature_lag1"])  # 两者都标准化
```

## 性能提示

1. **使用发布构建**: 调试构建慢约 10 倍
   ```bash
   # 生产环境务必使用发布版本
   make build
   ```

2. **批量操作**: 高效处理多个文件
   ```python
   for file in files:
       data = its.TimeSeriesData.from_csv(file)
       result = pipeline.process(data)  # 流程被重用
       result.to_parquet(f"processed_{file}")
   ```

3. **列选择**: 指定列以减少内存使用
   ```python
   # 只对特定列进行滞后,而不是所有特征
   pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
   ```

## 下一步?

现在您已经创建了第一个流程,探索更多内容:

- **[核心概念](/guide/concepts/timeseries)** - 理解 TimeSeriesData 和 Pipeline
- **[数据清洗](/guide/cleaning)** - 掌握缺失值处理
- **[特征工程](/guide/features)** - 创建强大的滞后特征
- **[TOML 配置](/guide/toml/structure)** - 构建声明式流程
- **[API 参考](/api/timeseries)** - 完整的 API 文档
- **[示例](/examples/basic)** - 真实世界的用例

## 故障排除

### 问题: "No time column found"

**解决方案**: 明确指定时间列
```python
data = its.TimeSeriesData.from_csv("data.csv", time_column="my_timestamp")
```

### 问题: "Cannot create lag with empty DataFrame"

**解决方案**: 确保您的数据至少有 `max(periods) + 1` 行
```python
# 对于 periods=[1,2,3], 需要至少 4 行
data = its.TimeSeriesData.from_csv("data.csv")
print(len(data))  # 应该 >= 4
```

### 问题: "Memory error on large dataset"

**解决方案**: 分块处理或使用 Parquet 格式
```python
# 使用 Parquet 以获得更好的压缩
data = its.TimeSeriesData.from_parquet("large_data.parquet")
```

## 获取帮助

- **文档**: [完整用户指南](/guide/loading-data)
- **示例**: [真实世界示例](/examples/basic)
- **问题**: [GitHub Issues](https://github.com/yourusername/industryts/issues)
- **讨论**: [GitHub Discussions](https://github.com/yourusername/industryts/discussions)
