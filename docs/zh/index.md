---
layout: home

hero:
  name: Industryts
  text: 高性能时间序列处理库
  tagline: 比 pandas 快 10-100 倍,基于 Rust 和 Polars 构建
  image:
    src: /logo.svg
    alt: Industryts
  actions:
    - theme: brand
      text: 快速开始
      link: /zh/guide/introduction
    - theme: alt
      text: GitHub 仓库
      link: https://github.com/yourusername/industryts

features:
  - icon: ⚡
    title: 极致性能
    details: 在典型时间序列操作中比 pandas 快 10-100 倍。Rust 驱动的核心引擎,零拷贝数据传输。

  - icon: 🦀
    title: Rust 驱动
    details: 基于 Rust 构建,提供类型安全、内存高效和卓越性能。利用 Polars 的列式处理能力。

  - icon: 🐍
    title: Python 友好
    details: Pythonic API 设计,完整的类型提示,熟悉的编程模式,与 Python 数据科学生态系统无缝集成。

  - icon: 📊
    title: 全面的操作
    details: 数据清洗、重采样、特征工程、数据变换和聚合 - 所有操作都针对工业时间序列进行了优化。

  - icon: ⚙️
    title: 声明式流程
    details: 在 TOML 配置文件中定义数据处理流程,实现可重现、版本可控的工作流。

  - icon: 🔧
    title: 双重 API 设计
    details: 灵活的编程式 Python API 和可重现的声明式 TOML API,根据需求自由选择。
---

## 快速示例

::: code-group

```python [编程式 API]
import industryts as its

# 加载时间序列数据
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# 创建处理流程
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
pipeline.standardize(columns=["temperature", "pressure"])

# 处理数据
result = pipeline.process(data)
result.to_csv("processed_data.csv")
```

```toml [声明式 API (TOML)]
[pipeline]
name = "sensor_processing"
time_column = "DateTime"

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
columns = ["temperature"]
periods = [1, 2, 3]

[[operations]]
type = "standardize"
columns = ["temperature", "pressure"]
```

```python [从 TOML 加载]
import industryts as its

# 从配置加载流程
pipeline = its.Pipeline.from_toml("pipeline.toml")

# 处理数据
data = its.TimeSeriesData.from_csv("sensor_data.csv")
result = pipeline.process(data)
```

:::

## 性能基准测试

在 100 万行 × 10 个特征的数据集上的测试结果:

| 操作 | pandas | industryts | 加速比 |
|-----------|--------|------------|---------|
| 重采样 (1h → 1min) | 2.3s | 0.05s | **46x** |
| 滚动平均 (窗口=100) | 1.8s | 0.03s | **60x** |
| 滞后特征 (3 个滞后) | 1.2s | 0.02s | **60x** |
| 完整流程 (10 个操作) | 12.5s | 0.15s | **83x** |

## 安装

::: code-group

```bash [pip]
pip install industryts
```

```bash [uv]
uv add industryts
```

```bash [从源码安装]
# 克隆仓库
git clone https://github.com/yourusername/industryts.git
cd industryts

# 安装 uv（如果尚未安装）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 以开发模式安装
uv run maturin develop
```

:::

## 为什么选择 Industryts?

### 对于数据科学家
- **熟悉的 API**: 类似 pandas 的 Pythonic 接口,易于学习
- **类型安全**: 完整的类型提示,提供更好的 IDE 支持,减少运行时错误
- **可重现性**: 声明式流程确保结果一致

### 对于工程师
- **生产就绪**: 高性能设计适合实时处理场景
- **内存高效**: Polars 的列式格式最小化内存使用
- **配置驱动**: 基于 TOML 的流程可与版本控制系统集成

### 对于工业应用
- **针对传感器优化**: 内置操作专为常见工业数据模式设计
- **大规模处理**: 高效处理数百万行数据
- **时间感知**: 原生理解时间序列需求

## 接下来做什么?

<div class="vp-doc" style="margin-top: 2rem;">

- **[简介](/zh/guide/introduction)** - 了解 Industryts 的架构和设计
- **[安装](/zh/guide/installation)** - 详细的安装说明
- **[快速开始](/zh/guide/quick-start)** - 创建您的第一个时间序列处理流程
- **[API 参考](/zh/api/timeseries)** - 完整的 API 文档
- **[示例](/zh/examples/basic)** - 真实世界的使用示例

</div>
