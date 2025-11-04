# 简介

## 什么是 Industryts?

Industryts 是一个专为工业数据设计的高性能时间序列处理库。基于 **Rust** 构建并由 **Polars** 驱动,它在保持 Python 友好 API 的同时,提供了比 pandas **快 10-100 倍**的性能。

## 为什么选择 Industryts?

### 面临的挑战

工业时间序列数据带来了独特的挑战:

- **规模**: 来自传感器和设备的数百万行数据
- **频率**: 高频数据需要高效的降采样
- **缺失数据**: 传感器故障和通信问题
- **特征工程**: 复杂的滞后特征和变换
- **生产要求**: 快速、内存高效、可重现的流程

传统工具如 pandas 在处理这些需求时力不从心,尤其是在大规模场景下。

### 解决方案

Industryts 通过以下方式解决这些挑战:

1. **Rust 驱动的核心**: 类型安全、内存高效的处理引擎
2. **Polars 集成**: 列式数据格式以获得最佳性能
3. **零拷贝架构**: Python 和 Rust 之间的高效数据传输
4. **双重 API 设计**: 编程灵活性和声明式可重现性

## 核心特性

### ⚡ 卓越性能

```python
# 在毫秒级而非秒级处理 100 万行数据
data = its.TimeSeriesData.from_csv("sensors.csv")  # 100 万行 × 10 个特征
pipeline.process(data)  # ~150ms vs pandas 的 ~12.5s (快 83 倍)
```

性能提升来源于:
- **列式处理**: Polars 基于 Arrow 的格式支持 SIMD 操作
- **Rust 零成本抽象**: 安全保证不会带来运行时开销
- **延迟求值**: 在执行前优化整个流程 (计划中)

### 🦀 类型安全

Rust 的类型系统在编译时捕获错误:

```rust
// Rust 核心 - 类型错误在开发时被捕获
pub struct LagOperation {
    pub columns: Option<Vec<String>>,
    pub periods: Vec<i64>,  // 必须是 Vec<i64>, 不能是 Vec<f64>
}
```

Python API 包含完整的类型提示:

```python
def lag(
    self,
    columns: Optional[List[str]] = None,
    periods: List[int] = [1]
) -> None:
    """创建带有类型检查参数的滞后特征。"""
```

### 🐍 Python 友好的 API

对 pandas 用户来说熟悉的模式:

```python
# 加载数据 (类似于 pandas)
data = its.TimeSeriesData.from_csv("data.csv")

# 检查数据
print(data.head())
print(data.describe())

# 构建流程 (方法链)
pipeline = its.Pipeline()
pipeline.fill_null(method="forward")
pipeline.lag(columns=["temperature"], periods=[1, 2, 3])
```

### ⚙️ 声明式流程

在 TOML 中定义流程以实现可重现性:

```toml
[pipeline]
name = "production_pipeline"
time_column = "DateTime"

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
columns = ["temperature"]
periods = [1, 2, 3]
```

优势:
- **版本控制**: 在 git 中跟踪流程变更
- **代码审查**: 单独审查数据处理逻辑
- **可重现性**: 跨环境获得相同结果
- **文档化**: 自我文档化的流程结构

## 架构概览

Industryts 遵循受 Polars 启发的三层架构:

```
┌─────────────────────────────────────────────────────────┐
│  Python API 层 (py-industryts/industryts/)             │
│  - TimeSeriesData, Pipeline 类                         │
│  - I/O 辅助函数 (CSV, Parquet)                         │
│  - 类型提示和文档                                       │
└────────────────────┬────────────────────────────────────┘
                     │  pyo3-polars (零拷贝)
┌────────────────────▼────────────────────────────────────┐
│  PyO3 绑定层 (py-industryts/src/)                      │
│  - 通过 PyO3 实现 Python-Rust 桥接                     │
│  - DataFrame 转换                                      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│  Rust 核心 (crates/industryts-core/)                   │
│  - TimeSeriesData 结构体                               │
│  - Operation trait 和实现                              │
│  - Pipeline 编排                                       │
│  - Polars DataFrame 操作                               │
└─────────────────────────────────────────────────────────┘
```

### 核心设计原则

1. **关注点分离**
   - 纯 Rust 核心库处理业务逻辑
   - 独立的 Python 绑定层提供 API 易用性
   - 层与层之间有清晰的边界

2. **零拷贝数据传输**
   - `pyo3-polars` 实现高效的 DataFrame 共享
   - Python 和 Rust 之间无序列化开销
   - 尽可能直接访问内存

3. **基于 Trait 的操作**
   - `Operation` trait 实现可组合的流程
   - 类型安全的操作链
   - 易于扩展自定义操作

4. **配置驱动**
   - 基于 TOML 的声明式流程
   - 可重现的工作流
   - 版本控制的数据处理

## 何时使用 Industryts

### ✅ 理想用例

- **工业物联网**: 制造业、能源、公用事业的传感器数据
- **大规模时间序列**: 需要快速处理的数百万行数据
- **特征工程**: 为机器学习流程构建复杂的滞后特征
- **生产流程**: 高性能、可重现的工作流
- **实时处理**: 低延迟数据转换

### ⚠️ 考虑替代方案

- **小数据集**: 对于 <10 万行的数据,pandas 就足够了
- **复杂统计模型**: 使用 statsmodels、scikit-learn
- **时间序列预测**: 使用 Prophet、statsforecast 或专门的库
- **即席分析**: pandas 的灵活性可能更方便

## 与其他工具的对比

### vs. pandas

| 特性 | pandas | Industryts |
|---------|--------|------------|
| 性能 | 基准 | 快 10-100 倍 |
| 内存使用 | 较高 | 较低 (列式) |
| 类型安全 | 运行时 | 编译时 (核心) |
| API 学习曲线 | 熟悉 | 相似 |
| 延迟求值 | 否 | 计划中 |
| 声明式流程 | 否 | 是 (TOML) |

### vs. Polars

| 特性 | Polars | Industryts |
|---------|--------|------------|
| 通用目的 | 是 | 时间序列专注 |
| 内置时间操作 | 基础 | 全面 |
| 工业专注 | 否 | 是 |
| 声明式流程 | 否 | 是 (TOML) |
| API | Polars 风格 | 类 pandas |

### vs. Dask

| 特性 | Dask | Industryts |
|---------|------|------------|
| 分布式 | 是 | 否 (单节点) |
| 性能 (单节点) | 较慢 | 较快 |
| 设置复杂度 | 较高 | 较低 |
| 时间序列操作 | 有限 | 全面 |

## 下一步?

- **[安装](/guide/installation)** - 安装 Industryts
- **[快速开始](/guide/quick-start)** - 创建您的第一个流程
- **[核心概念](/guide/concepts/timeseries)** - 理解架构
- **[API 参考](/api/timeseries)** - 详细的 API 文档
