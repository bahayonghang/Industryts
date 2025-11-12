# 示例和用例

## 基础用法

### 创建时间序列数据

```rust
use industryts_core::TimeSeriesData;
use polars::prelude::*;

// 创建包含时间序列数据的 DataFrame
let dates = vec![
    1704067200000i64, // 2024-01-01
    1704153600000,    // 2024-01-02
    1704240000000,    // 2024-01-03
];

let time_series = Series::new("DateTime".into(), dates)
    .cast(&DataType::Datetime(TimeUnit::Milliseconds, None))
    .unwrap();

let df = DataFrame::new(vec![
    time_series.into(),
    Series::new("temperature".into(), &[20.5, 21.2, 19.8]).into(),
    Series::new("humidity".into(), &[65.0, 70.0, 68.0]).into(),
]).unwrap();

// 创建 TimeSeriesData
let ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();
println!("时间列: {}", ts.time_column());
println!("特征: {:?}", ts.feature_columns());
```

### 基础管道

```rust
use industryts_core::{Pipeline, TimeSeriesData};
use industryts_core::operations::FillNullOperation;
use industryts_core::config::FillMethod;

let mut pipeline = Pipeline::new();
pipeline.add_operation(Box::new(
    FillNullOperation::new(FillMethod::Forward, None)
));

let result = pipeline.process(ts).unwrap();
println!("处理了 {} 行", result.len());
```

## 高级用法

### 使用 Builder API

```rust
use industryts_core::pipeline::PipelineBuilder;
use industryts_core::operations::{
    FillNullOperation, LagOperation, StandardizeOperation
};
use industryts_core::config::FillMethod;

let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(
        FillNullOperation::new(FillMethod::Forward, None)
    ))
    .add_operation(Box::new(
        LagOperation::new(vec![1, 2, 3], None)
    ))
    .add_operation(Box::new(
        StandardizeOperation::new(None)
    ))
    .build();

let result = pipeline.process(ts).unwrap();
```

### 带指标的执行

```rust
use industryts_core::ExecutionContext;

let mut context = ExecutionContext::new();
context.add_metadata("run_id".to_string(), "20250101_001".to_string());
context.add_metadata("environment".to_string(), "production".to_string());

let (result, context) = pipeline.process_with_context(ts, context).unwrap();

// 获取执行总结
let summary = context.summary();
println!("=== 管道执行总结 ===");
println!("总操作数: {}", summary.total_operations);
println!("总耗时: {:.2}s", summary.total_duration.as_secs_f64());
println!("处理行数: {}", summary.total_rows_processed);
println!("平均吞吐量: {:.0} rows/sec", summary.average_throughput);

// 获取详细指标
println!("\n=== 操作详情 ===");
for metrics in context.metrics() {
    println!("{}: {} -> {} 行 ({:.2}s, {:.0} rows/sec)",
        metrics.operation_name,
        metrics.input_rows,
        metrics.output_rows,
        metrics.duration.as_secs_f64(),
        metrics.throughput());
}
```

### 从 TOML 配置加载

```rust
use industryts_core::Pipeline;

// 从 TOML 文件加载管道
let pipeline = Pipeline::from_toml("config/pipeline.toml").unwrap();

// 执行
let result = pipeline.process(ts).unwrap();

// 保存配置
pipeline.to_toml("config/output.toml").unwrap();
```

示例 TOML 配置：

```toml
[pipeline]
name = "data_processing"
time_column = "DateTime"

[[operations]]
type = "fill_null"
method = "forward"

[[operations]]
type = "lag"
periods = [1, 2, 3]

[[operations]]
type = "standardize"
```

### 使用操作注册表

```rust
use industryts_core::pipeline::OperationRegistry;
use industryts_core::core::OperationCategory;
use industryts_core::operations::FillNullOperation;
use industryts_core::config::FillMethod;

// 创建并填充注册表
let mut registry = OperationRegistry::new();

registry.register(
    "fill_forward".to_string(),
    OperationCategory::DataQuality,
    "使用前向填充填充空值".to_string(),
    || Box::new(FillNullOperation::new(FillMethod::Forward, None)),
);

registry.register(
    "fill_backward".to_string(),
    OperationCategory::DataQuality,
    "使用后向填充填充空值".to_string(),
    || Box::new(FillNullOperation::new(FillMethod::Backward, None)),
);

// 按类别列出操作
println!("数据质量操作:");
for op_info in registry.list_by_category(OperationCategory::DataQuality) {
    println!("  - {}: {}", op_info.name, op_info.description);
}

// 动态创建操作
let operation = registry.create("fill_forward").unwrap();
```

### 使用元数据

```rust
use industryts_core::TimeSeriesData;

let mut ts = TimeSeriesData::new(df, Some("DateTime")).unwrap();

// 添加标签
ts.add_tag("source".to_string(), "sensor_01".to_string());
ts.add_tag("location".to_string(), "warehouse_a".to_string());
ts.add_tag("unit".to_string(), "celsius".to_string());

// 读取标签
if let Some(source) = ts.get_tag("source") {
    println!("数据源: {}", source);
}

// 访问元数据
let metadata = ts.metadata();
println!("时间列: {}", metadata.time_column);
println!("特征列: {:?}", metadata.feature_columns);
println!("标签: {:?}", metadata.tags);
```

## 真实场景

### 场景 1: 传感器数据处理

```rust
// 加载传感器数据
let ts = TimeSeriesData::new(sensor_df, Some("timestamp")).unwrap();

// 构建处理管道
let pipeline = PipelineBuilder::new()
    // 填充来自传感器故障的缺失值
    .add_operation(Box::new(
        FillNullOperation::new(FillMethod::Forward, None)
    ))
    // 为异常检测创建滞后特征
    .add_operation(Box::new(
        LagOperation::new(vec![1, 2, 3], None)
    ))
    // 为机器学习进行标准化
    .add_operation(Box::new(
        StandardizeOperation::new(None)
    ))
    .build();

// 执行并收集指标
let mut context = ExecutionContext::new();
context.add_metadata("sensor_id".to_string(), "TEMP_001".to_string());

let (result, context) = pipeline.process_with_context(ts, context).unwrap();

// 记录结果
let summary = context.summary();
println!("在 {:.2}s 内处理了 {} 行", 
    summary.total_duration.as_secs_f64(),
    summary.total_rows_processed);
```

### 场景 2: 金融时间序列

```rust
// 加载股票价格数据
let ts = TimeSeriesData::new(stock_df, Some("date")).unwrap();

// 添加元数据
let mut ts = ts;
ts.add_tag("symbol".to_string(), "AAPL".to_string());
ts.add_tag("exchange".to_string(), "NASDAQ".to_string());

// 构建分析管道
let pipeline = PipelineBuilder::new()
    // 处理缺失数据
    .add_operation(Box::new(
        FillNullOperation::new(FillMethod::Mean, None)
    ))
    // 创建技术指标（滞后特征）
    .add_operation(Box::new(
        LagOperation::new(vec![1, 5, 20], None)
    ))
    // 标准化以便比较
    .add_operation(Box::new(
        StandardizeOperation::new(None)
    ))
    .build();

let result = pipeline.process(ts).unwrap();
```

### 场景 3: 带验证的时间序列

```rust
use industryts_core::core::Operation;

// 创建带验证的自定义操作
struct CustomAnalysis {
    threshold: f64,
}

impl Operation for CustomAnalysis {
    fn validate(&self, data: &TimeSeriesData) -> Result<()> {
        if data.len() < 10 {
            return Err(IndustrytsError::InvalidOperation(
                "需要至少 10 个数据点".to_string()
            ));
        }
        Ok(())
    }

    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData> {
        self.validate(&data)?;
        // 处理数据
        Ok(data)
    }

    fn name(&self) -> &str {
        "custom_analysis"
    }
}

// 在管道中使用
let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(CustomAnalysis { threshold: 0.5 }))
    .build();

let result = pipeline.process(ts).unwrap();
```

## 性能提示

### 1. 重用管道

```rust
// 好的做法：创建一次，使用多次
let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(FillNullOperation::new(...)))
    .build();

for ts in time_series_list {
    let result = pipeline.process(ts).unwrap();
}
```

### 2. 选择性列操作

```rust
// 指定列以减少处理
let pipeline = PipelineBuilder::new()
    .add_operation(Box::new(
        FillNullOperation::new(
            FillMethod::Forward,
            Some(vec!["temperature".to_string(), "humidity".to_string()])
        )
    ))
    .build();
```

### 3. 可选的指标收集

```rust
// 仅在需要时收集指标
if debug_mode {
    let mut context = ExecutionContext::new();
    let (result, context) = pipeline.process_with_context(ts, context).unwrap();
    // 分析指标
} else {
    let result = pipeline.process(ts).unwrap();
}
```

## 错误处理

```rust
use industryts_core::error::IndustrytsError;

match pipeline.process(ts) {
    Ok(result) => {
        println!("成功: 处理了 {} 行", result.len());
    }
    Err(IndustrytsError::TimeColumnNotFound(col)) => {
        eprintln!("未找到时间列: {}", col);
    }
    Err(IndustrytsError::ColumnNotFound(col)) => {
        eprintln!("未找到列: {}", col);
    }
    Err(IndustrytsError::InvalidOperation(msg)) => {
        eprintln!("无效操作: {}", msg);
    }
    Err(e) => {
        eprintln!("错误: {}", e);
    }
}
```

## 后续步骤

- 查看[架构指南](./architecture.md)了解详细设计
- 查看[迁移指南](./migration.md)了解从 v0.1.x 升级
- 查看源代码文档了解 API 详情
