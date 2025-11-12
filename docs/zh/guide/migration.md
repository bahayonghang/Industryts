# 迁移指南 v0.1.x → v0.2.0

## 概述

IndustryTS v0.2.0 引入了改进模块化和新功能的重新设计架构。**所有现有代码保持兼容** - 您可以升级而不会破坏更改。

## 向后兼容性

### ✅ 仍然有效的内容

所有 v0.1.x 公共 API 完全可用：

```rust
use industryts_core::{TimeSeriesData, Pipeline};
use industryts_core::operations::{FillNullOperation, LagOperation};

let ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();
let mut pipeline = Pipeline::new();
pipeline.add_operation(Box::new(FillNullOperation::new(...)));
let result = pipeline.process(ts).unwrap();
```

### ⚠️ 已弃用的导入

这些导入标记为 `#[deprecated]` 但仍然有效：

```rust
// 旧方式（已弃用）
use industryts_core::timeseries::TimeSeriesData;

// 新方式（推荐）
use industryts_core::TimeSeriesData;
```

## 逐步迁移

### 步骤 1: 更新导入

#### 之前
```rust
use industryts_core::timeseries::TimeSeriesData;
use industryts_core::pipeline::Operation;
```

#### 之后
```rust
use industryts_core::{TimeSeriesData, Operation};
// 或更明确地：
use industryts_core::core::{TimeSeriesData, Operation};
```

### 步骤 2: 使用 Builder API（可选）

新的 Builder API 简化了管道构造：

#### 之前
```rust
let mut pipeline = Pipeline::new();
pipeline.add_operation(Box::new(FillNullOperation::new(...)));
pipeline.add_operation(Box::new(LagOperation::new(...)));
```

#### 之后
```rust
use industryts_core::pipeline::PipelineBuilder;

let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(FillNullOperation::new(...)))
    .add_operation(Box::new(LagOperation::new(...)))
    .build();
```

### 步骤 3: 添加执行上下文（可选）

追踪执行指标和性能：

```rust
use industryts_core::ExecutionContext;

let mut context = ExecutionContext::new();
let (result, context) = pipeline.process_with_context(ts, context).unwrap();

let summary = context.summary();
println!("操作数: {}", summary.total_operations);
println!("耗时: {:?}", summary.total_duration);
println!("吞吐量: {:.2} rows/sec", summary.average_throughput);
```

### 步骤 4: 使用操作注册表（可选）

动态注册和发现操作：

```rust
use industryts_core::pipeline::OperationRegistry;
use industryts_core::core::OperationCategory;

let mut registry = OperationRegistry::new();
registry.register(
    "fill_null".to_string(),
    OperationCategory::DataQuality,
    "填充空值".to_string(),
    || Box::new(FillNullOperation::new(...)),
);

// 查询操作
for op in registry.list_by_category(OperationCategory::DataQuality) {
    println!("操作: {}", op.name);
}

// 动态创建操作
let op = registry.create("fill_null").unwrap();
```

## 新功能

### 1. 增强的 TimeSeriesData

#### 元数据支持
```rust
let mut ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();

// 添加标签
ts.add_tag("source".to_string(), "sensor_01".to_string());
ts.add_tag("location".to_string(), "warehouse".to_string());

// 读取标签
if let Some(source) = ts.get_tag("source") {
    println!("数据源: {}", source);
}

// 访问元数据
let metadata = ts.metadata();
println!("时间列: {}", metadata.time_column);
println!("特征: {:?}", metadata.feature_columns);
```

### 2. 操作验证

```rust
impl Operation for MyOperation {
    fn validate(&self, data: &TimeSeriesData) -> Result<()> {
        if data.feature_columns().is_empty() {
            return Err(IndustrytsError::InvalidOperation(
                "未找到特征列".to_string()
            ));
        }
        Ok(())
    }

    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData> {
        self.validate(&data)?;
        // ... 实现
        Ok(data)
    }

    fn name(&self) -> &str {
        "my_operation"
    }
}
```

### 3. 操作元数据

```rust
impl Operation for MyOperation {
    fn metadata(&self) -> OperationMetadata {
        OperationMetadata {
            name: "my_operation".to_string(),
            description: "我的自定义操作".to_string(),
            version: "1.0.0".to_string(),
            category: OperationCategory::Transform,
        }
    }

    // ... 其他方法
}

let op = MyOperation::new();
let metadata = op.metadata();
println!("操作: {} v{}", metadata.name, metadata.version);
```

### 4. 执行指标

```rust
let (result, context) = pipeline.process_with_context(ts, context).unwrap();

for metrics in context.metrics() {
    println!("{}: {} -> {} 行 ({:.2}s, {:.0} rows/sec)",
        metrics.operation_name,
        metrics.input_rows,
        metrics.output_rows,
        metrics.duration.as_secs_f64(),
        metrics.throughput());
}
```

## 迁移检查清单

- [ ] 更新导入语句（可选但推荐）
- [ ] 如果使用 Builder API，更新管道构造（可选）
- [ ] 如果需要指标，添加 ExecutionContext（可选）
- [ ] 运行测试确保一切正常
- [ ] 更新文档和注释

## 常见问题

### Q: 我需要立即迁移吗？

**A**: 不需要。所有现有代码继续有效。按自己的节奏迁移。

### Q: 新代码会破坏我的现有代码吗？

**A**: 不会。v0.2.0 与 v0.1.x 完全向后兼容。

### Q: 如何处理已弃用的导入？

**A**: 编译器会发出警告。您可以：
1. 忽略它们（代码仍然有效）
2. 按上面所示更新导入

### Q: 有性能影响吗？

**A**: 没有。新架构保持相同的性能特性。

### Q: 如何创建自定义操作？

**A**: 查看[架构指南](./architecture.md)了解详细说明。

## 故障排除

### 编译警告

如果看到弃用警告：

```
warning: use of deprecated item: 'timeseries::TimeSeriesData'
```

更新导入：

```rust
// 从以下更改：
use industryts_core::timeseries::TimeSeriesData;

// 至：
use industryts_core::TimeSeriesData;
```

### 导入错误

如果更新后出现导入错误：

```rust
// 确保从正确的地方导入：
use industryts_core::{TimeSeriesData, Operation, Pipeline};
use industryts_core::core::{ExecutionContext, OperationCategory};
use industryts_core::pipeline::{PipelineBuilder, OperationRegistry};
```

## 版本信息

- **当前版本**: v0.2.0
- **最小支持**: v0.1.x（完全兼容）
- **Rust 版本**: 1.70+
- **Polars 版本**: 0.51+

## 获取帮助

- 📖 [架构指南](./architecture.md)
- 💡 [示例](./examples.md)
- 🔍 源代码文档
- 💬 GitHub Issues

## 总结

v0.2.0 带来了显著的改进，同时保持完全的向后兼容性。您可以：

1. **保持现有代码不变** - 一切仍然有效
2. **逐步采用新功能** - 使用 Builder API、ExecutionContext 等
3. **更新导入** - 推荐但不是必需的
4. **享受新功能** - 指标、验证、注册表等

祝升级愉快！🚀
