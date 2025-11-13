# 安装指南

本指南介绍如何安装 Industryts Python 包。

## 系统要求

- **Python**: 3.12+
- **操作系统**: Linux, macOS, Windows
- **内存**: 最少 2GB RAM (推荐 4GB+)

## 从 PyPI 安装

最简单的安装方式是使用 pip:

```bash
pip install industryts
```

或使用 uv (推荐):

```bash
uv add industryts
```

## 从源码安装

如果你想从源码构建或开发 Industryts,请按照以下步骤操作:

### 1. 克隆仓库

```bash
git clone https://github.com/yourusername/industryts.git
cd industryts
```

### 2. 安装依赖

#### 安装 Rust (如果尚未安装)

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### 安装 uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 3. 构建和安装

#### 开发模式 (推荐用于开发)

```bash
cd py-industryts
uv run maturin develop
```

#### 发布模式

```bash
cd py-industryts
uv run maturin build --release
pip install target/wheels/*.whl
```

## 验证安装

安装完成后,验证是否成功:

```python
import industryts as its

print(f"Industryts 版本: {its.__version__}")

# 创建简单的时间序列数据
import polars as pl
from datetime import datetime

df = pl.DataFrame({
    "DateTime": pl.datetime_range(
        start=datetime(2024, 1, 1),
        end=datetime(2024, 1, 10),
        interval="1d",
        eager=True
    ),
    "value": [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
})

data = its.TimeSeriesData(df)
print(f"成功创建 TimeSeriesData: {len(data)} 行")
```

## 故障排除

### ImportError: No module named 'industryts'

确保已正确安装包:

```bash
# 检查安装
pip list | grep industryts

# 重新安装
pip install --force-reinstall industryts
```

### 编译错误 (从源码安装时)

确保已安装 Rust 工具链:

```bash
rustc --version
cargo --version
```

如果未安装,请运行:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 版本不兼容

确保 Python 版本为 3.12+:

```bash
python --version
```

## 可选依赖

### 用于 Jupyter 笔记本

```bash
pip install jupyter ipython
```

### 用于数据可视化

```bash
pip install matplotlib seaborn plotly
```

### 用于额外的数据格式支持

```bash
pip install pyarrow openpyxl
```

## 下一步

- [快速开始](/guide/quick-start) - 创建第一个处理流程
- [API 参考](/api/core) - 完整的 API 文档
- [示例](/examples/basic) - 实际使用示例
