# 架构指南

## 概述

IndustryTS v0.2.0 引入了重新设计的时间序列处理架构，具有改进的模块化、可扩展性和类型安全性。

## 核心模块

### `core/` - 核心抽象

库的基础，提供基本抽象：

#### `data.rs` - TimeSeriesData
- **目的**: 使用时间序列特定功能包装 Polars DataFrames
- **特性**:
  - 自动时间列检测
  - 特征列管理
  - 元数据支持和标签
  - 类型安全的访问模式

```rust
use industryts_core::TimeSeriesData;

let ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();
ts.add_tag("source".to_string(), "sensor_01".to_string());
```

#### `operation.rs` - Operation Trait
- **目的**: 为所有时间序列操作定义接口
- **特性**:
  - 统一的执行接口
  - 操作验证
  - 元数据支持
  - 分类分类

```rust
pub trait Operation: Send + Sync {
    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData>;
    fn name(&self) -> &str;
    fn validate(&self, data: &TimeSeriesData) -> Result<()>;
    fn metadata(&self) -> OperationMetadata;
}
```

#### `context.rs` - ExecutionContext
- **目的**: 追踪管道执行并收集指标
- **特性**:
  - 操作执行历史
  - 性能指标收集
  - 自定义元数据存储
  - 执行总结生成

```rust
let mut context = ExecutionContext::new();
let (result, context) = pipeline.process_with_context(ts, context).unwrap();
let summary = context.summary();
```

### `pipeline/` - 管道引擎

用于链接和管理操作的执行引擎：

#### `executor.rs` - Pipeline
- **目的**: 执行一系列操作
- **特性**:
  - 顺序操作执行
  - TOML 配置支持
  - 执行上下文集成
  - 向后兼容的 API

#### `builder.rs` - PipelineBuilder
- **目的**: 用于管道构造的流式 API
- **特性**:
  - 方法链接
  - 简化的管道构建
  - 可变和不可变变体

```rust
let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(FillNullOperation::new(...)))
    .add_operation(Box::new(LagOperation::new(...)))
    .build();
```

#### `registry.rs` - OperationRegistry
- **目的**: 动态操作注册和发现
- **特性**:
  - 运行时操作注册
  - 基于类别的查询
  - 工厂模式支持
  - 操作信息存储

```rust
let mut registry = OperationRegistry::new();
registry.register(
    "fill_null".to_string(),
    OperationCategory::DataQuality,
    "Fill null values".to_string(),
    || Box::new(FillNullOperation::new(...)),
);
```

### `operations/` - 操作实现

按类别组织的操作：

#### `data_quality/` - 数据质量操作
- `FillNullOperation`: 处理缺失值
- 未来: 验证、异常值检测

#### `temporal/` - 时间操作
- 未来实现的占位符
- 计划: 重采样、移位、聚合

#### `features/` - 特征工程
- `LagOperation`: 创建滞后特征
- 未来: 滚动窗口、差分、统计

#### `transform/` - 数据转换
- `StandardizeOperation`: Z-score 标准化
- `NormalizeOperation`: Min-max 归一化
- 未来: 缩放、编码

## 数据流

```
┌─────────────────────────────────────────────────────────────┐
│                    用户代码                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────────┐
        │   创建 TimeSeriesData (core)       │
        │   - DataFrame                      │
        │   - 时间列名                       │
        │   - 特征列                         │
        │   - 元数据标签                     │
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │   构建 Pipeline (pipeline)         │
        │   - 使用 Builder 或直接 API        │
        │   - 添加操作                       │
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │   执行 Pipeline (executor)         │
        │   - process()                      │
        │   - process_with_context()         │
        └────────────┬───────────────────────┘
                     │
        ┌────────────┴───────────────────────┐
        │                                    │
        ▼                                    ▼
    ┌─────────────┐                  ┌──────────────────┐
    │ 操作 1      │                  │ ExecutionContext │
    │ (Operation) │──────────────────│ - 指标           │
    └──────┬──────┘                  │ - 历史           │
           │                         │ - 元数据         │
           ▼                         └──────────────────┘
    ┌─────────────┐
    │ 操作 2      │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ 操作 N      │
    └──────┬──────┘
           │
           ▼
    ┌──────────────────────────┐
    │ 结果 TimeSeriesData      │
    │ + ExecutionSummary       │
    └──────────────────────────┘
```

## 关键概念

### TimeSeriesData
- 包装 Polars DataFrame
- 管理时间和特征列
- 支持元数据标签
- 类型安全的访问模式

### Operation
- 所有操作的统一接口
- 支持执行前验证
- 提供操作的元数据
- 按组织分类

### Pipeline
- 链接多个操作
- 顺序执行
- 支持通过 TOML 配置
- 可选的执行上下文追踪

### ExecutionContext
- 追踪操作执行
- 收集性能指标
- 存储自定义元数据
- 生成执行总结

## 向后兼容性

所有 v0.1.x API 仍然可用：

```rust
// 旧方式（仍然有效）
use industryts_core::timeseries::TimeSeriesData;

// 新方式（推荐）
use industryts_core::TimeSeriesData;
```

## 扩展点

### 添加新操作

1. 实现 `Operation` trait
2. 添加到适当的类别模块
3. 更新模块导出
4. 添加测试

```rust
pub struct MyOperation {
    // 配置
}

impl Operation for MyOperation {
    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData> {
        // 实现
        Ok(data)
    }

    fn name(&self) -> &str {
        "my_operation"
    }
}
```

### 添加新类别

1. 在 `operations/` 中创建类别目录
2. 在类别中实现操作
3. 更新 `OperationCategory` 枚举
4. 更新 `operations/mod.rs`

## 性能考虑

- 无额外的数据复制开销
- 执行上下文是可选的
- Polars 集成保持高性能
- 未来版本支持延迟评估

## 测试

所有核心模块都有全面的测试覆盖：

```bash
uv run cargo test --lib
# 16/16 测试通过
```

## 相关文档

- [迁移指南](./migration.md) - 从 v0.1.x 升级
- [API 参考](./api-reference.md) - 详细的 API 文档
- [示例](./examples.md) - 代码示例和用例
