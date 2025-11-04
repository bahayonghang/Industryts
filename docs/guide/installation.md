# 安装

## 系统要求

### 基本要求

- **Python**: 3.9+ (兼容 3.9, 3.10, 3.11, 3.12, 3.13)
- **操作系统**:
  - Linux (glibc 2.17+, 例如 CentOS 7+, Ubuntu 18.04+)
  - macOS (x86_64 或 arm64/M1/M2)
  - Windows (x86_64)

### 可选依赖

- **对于大数据集** (>42 亿行): 带 64 位行索引的 Polars
  ```bash
  pip install polars[rt64]
  ```

## 从源码安装

用于开发或使用最新功能:

### 先决条件

1. **Rust**: 1.70 或更高版本
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   ```

2. **Python**: 3.9 或更高版本
   ```bash
   python --version  # 应该是 3.9+
   ```

3. **uv** (推荐的包管理器):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

### 开发模式安装

::: code-group

```bash [使用 uv (推荐)]
# 克隆仓库
git clone https://github.com/yourusername/industryts.git
cd industryts

# 安装开发依赖
uv sync --dev

# 以开发模式构建和安装 (快速编译, 包含调试符号)
uv run maturin develop

# 或使用 make 命令
make develop
```

```bash [使用 pip]
# 克隆仓库
git clone https://github.com/yourusername/industryts.git
cd industryts

# 安装构建依赖
pip install maturin

# 以开发模式构建和安装
maturin develop

# 安装 Python 依赖
pip install -e ".[dev]"
```

:::

### 发布版本构建

用于生产环境或性能测试,请使用优化构建:

```bash
# 发布版本构建 (编译较慢, 最高性能)
make build

# 或直接使用 maturin
uv run maturin develop --release
```

::: tip 性能差异
调试构建比发布构建慢约 10 倍。进行性能测试时务必使用发布构建!
:::

### 运行测试

```bash
# 运行所有测试 (Rust + Python)
make test

# 仅运行 Rust 测试
cargo test

# 仅运行 Python 测试
pytest
```

### 类型检查

```bash
# 运行类型检查器
make typecheck

# 或手动运行
mypy py-industryts/industryts
pyright py-industryts/industryts
```

## 平台特定说明

### Linux

**Wheels 使用 manylinux2014 构建**以实现最大兼容性 (glibc 2.17+)。

如果遇到 `ImportError: libgomp.so.1: cannot open shared object file`:

```bash
# 在 Ubuntu/Debian 上
sudo apt-get install libgomp1

# 在 CentOS/RHEL 上
sudo yum install libgomp
```

### macOS

**支持 Intel (x86_64) 和 Apple Silicon (arm64) 架构。**

在 macOS 上,您可能需要安装 Xcode 命令行工具:

```bash
xcode-select --install
```

### Windows

**Windows wheels 支持 x86_64 (64 位)。**

如果在 Windows 上从源码构建:

1. 安装 **Visual Studio 2019 或更高版本**,包含 "C++ 构建工具"
2. 使用 **Rust stable 工具链** (MSVC 变体,而非 GNU)

```powershell
# 安装 Rust (如果尚未安装)
# 从此处下载: https://rustup.rs

# 验证 Rust 工具链
rustup show
# 应该显示: stable-x86_64-pc-windows-msvc

# 构建
maturin develop
```

## 故障排除

### 常见问题

#### 问题: "No module named 'industryts'"

**原因**: 安装未完成或 Python 环境错误。

**解决方案**:
```bash
# 检查已安装的包
pip list | grep industryts

# 重新安装
pip uninstall industryts
pip install industryts
```

#### 问题: "ImportError: cannot import name 'TimeSeriesData'"

**原因**: 构建不完整或安装过时。

**解决方案**:
```bash
# 对于源码安装,重新构建
make clean
make develop

# 对于 PyPI 安装,重新安装
pip install --force-reinstall --no-cache-dir industryts
```

#### 问题: "error: linking with `cc` failed"

**原因**: 缺少 C/C++ 编译器或链接器。

**解决方案**:
```bash
# 在 Ubuntu/Debian 上
sudo apt-get install build-essential

# 在 CentOS/RHEL 上
sudo yum groupinstall "Development Tools"

# 在 macOS 上
xcode-select --install
```

#### 问题: 性能比基准测试慢

**原因**: 使用了调试构建而非发布构建。

**解决方案**:
```bash
# 生产环境/性能测试时务必使用发布构建
make build
# 或
uv run maturin develop --release
```

### 获取帮助

如果遇到此处未涵盖的问题:

1. **查看现有问题**: [GitHub Issues](https://github.com/yourusername/industryts/issues)
2. **搜索讨论**: [GitHub Discussions](https://github.com/yourusername/industryts/discussions)
3. **提交新问题**: 请提供:
   - Python 版本 (`python --version`)
   - Rust 版本 (`rustc --version`)
   - 操作系统和版本
   - 完整的错误消息和堆栈跟踪

## 下一步

- **[快速开始](/guide/quick-start)** - 创建您的第一个流程
- **[核心概念](/guide/concepts/timeseries)** - 理解基础知识
- **[API 参考](/api/timeseries)** - 详细的 API 文档

## 升级

升级到最新版本:

::: code-group

```bash [pip]
pip install --upgrade industryts
```

```bash [uv]
uv add --upgrade industryts
```

:::

升级前请查看 [CHANGELOG](https://github.com/yourusername/industryts/blob/main/CHANGELOG.md) 了解破坏性变更。
