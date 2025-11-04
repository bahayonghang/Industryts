# GitHub Actions 工作流说明

本目录包含 Industryts 项目的 CI/CD 自动化工作流配置。

## 📋 工作流清单

### 1. CI 工作流 (`ci.yml`)

**触发条件：**
- Push 到 `main` 或 `develop` 分支
- Pull Request 创建或更新
- 手动触发（`workflow_dispatch`）

**检查项目：**

#### Rust 检查
- ✅ **代码格式化检查**：`cargo fmt --check`
- ✅ **静态分析**：`cargo clippy --all-targets --all-features`
- ✅ **单元测试**：`cargo test --workspace --all-features`

#### Python 检查
- ✅ **代码风格检查**：`ruff check .`
- ✅ **格式化检查**：`ruff format --check .`
- ✅ **类型检查**：`mypy` (警告模式，不阻塞 CI)

#### Python 多版本测试
- ✅ **测试矩阵**：Python 3.9, 3.10, 3.11, 3.12, 3.13
- ✅ **集成测试**：使用 `pytest` 运行完整测试套件
- ✅ **性能基准**：支持 `pytest-benchmark`

**缓存策略：**
- Cargo registry、index 和 build 产物
- Python pip 包
- 加速后续构建，节省时间和资源

---

### 2. Release 工作流 (`release.yml`)

**触发条件：**
- 推送符合 `v*.*.*` 格式的 Git tag（例如：`v0.1.0`、`v1.2.3`）
- 手动触发（`workflow_dispatch`）

**构建矩阵：**

| 平台 | 架构 | Runner | 说明 |
|------|------|--------|------|
| **Linux** | x86_64 | `ubuntu-latest` | 标准 Linux x86_64 |
| **Windows** | x64 | `windows-latest` | Windows 64位 |
| **macOS** | arm64 | `macos-14` | Apple Silicon (M1/M2/M3) |

**构建产物：**
- ✅ **Wheel 包**：各平台的 `.whl` 文件（使用 `maturin` 构建）
- ✅ **源码分发**：`.tar.gz` sdist 包
- ✅ **GitHub Release**：自动创建 Release 并上传所有产物
- ✅ **PyPI 发布**：（可选）正式版本自动发布到 PyPI

**发布策略：**
- **预发布版本**：tag 中包含 `alpha`、`beta`、`rc` 时标记为 prerelease
- **正式版本**：自动发布到 PyPI（需配置 Trusted Publisher 或 API Token）
- **Release Notes**：自动从 `CHANGELOG.md` 提取或生成

---

## 🚀 使用指南

### 日常开发流程

1. **创建分支并开发**
   ```bash
   git checkout -b feature/my-new-feature
   # 开发并提交代码
   ```

2. **本地检查**（推荐在提交前运行）
   ```bash
   # Rust 检查
   cargo fmt --check
   cargo clippy -- -D warnings
   cargo test

   # Python 检查
   ruff check .
   ruff format --check .
   mypy py-industryts/industryts
   ```

3. **提交 Pull Request**
   - CI 会自动运行所有检查
   - 确保所有检查通过后再合并

### 发布新版本

1. **更新版本号**
   ```bash
   # 更新 Cargo.toml 和 pyproject.toml 中的版本号
   vim Cargo.toml
   vim pyproject.toml
   ```

2. **更新 CHANGELOG**（可选但推荐）
   ```bash
   vim CHANGELOG.md
   # 添加新版本的更新日志
   ```

3. **创建 Git tag 并推送**
   ```bash
   git add .
   git commit -m "chore: bump version to v0.2.0"
   git tag v0.2.0
   git push origin main --tags
   ```

4. **自动构建与发布**
   - GitHub Actions 自动构建所有平台的 wheel
   - 自动创建 GitHub Release
   - （可选）自动发布到 PyPI

### 手动触发工作流

在 GitHub 网页界面：
1. 进入 **Actions** 标签页
2. 选择要运行的工作流（CI 或 Release）
3. 点击 **Run workflow** 按钮
4. 选择分支并确认

---

## ⚙️ 配置说明

### PyPI 自动发布设置

**方法 1：使用 Trusted Publisher（推荐）**

1. 登录 PyPI → 进入项目设置
2. 添加 Trusted Publisher：
   - **Owner**: 你的 GitHub 用户名/组织名
   - **Repository**: `Industryts`
   - **Workflow**: `release.yml`
   - **Environment**: `pypi`

3. 无需 API Token，更安全！

**方法 2：使用 API Token**

1. 在 PyPI 创建 API Token
2. 在 GitHub Repository 设置中添加 Secret：
   - Name: `PYPI_API_TOKEN`
   - Value: 你的 PyPI API Token

3. 取消注释 `release.yml` 中的 token 配置行

### 环境变量和缓存

**Cargo 缓存：**
- `~/.cargo/registry` - Crates 注册表
- `~/.cargo/git` - Git 依赖
- `target/` - 编译产物

**Python 缓存：**
- `~/.cache/pip` - pip 下载的包

缓存自动管理，无需手动配置。

---

## 🔧 故障排查

### CI 失败常见原因

1. **Rust 格式化失败**
   ```bash
   cargo fmt
   git add .
   git commit -m "style: format code"
   ```

2. **Clippy 警告**
   ```bash
   cargo clippy --fix --allow-dirty
   ```

3. **Python 格式化失败**
   ```bash
   ruff format .
   ruff check --fix .
   ```

4. **测试失败**
   - 检查本地测试是否通过：`cargo test && pytest`
   - 查看 Actions 日志获取详细错误信息

### Release 失败常见原因

1. **Tag 格式不正确**
   - 必须符合 `v*.*.*` 格式（例如 `v0.1.0`）
   - 不要使用 `0.1.0` 或 `release-0.1.0`

2. **权限不足**
   - 检查 `GITHUB_TOKEN` 权限（自动提供，通常无需配置）
   - 检查 PyPI Token 配置（如使用 token 方式）

3. **构建失败**
   - 查看具体平台的构建日志
   - 本地复现：`maturin build --release`

---

## 📊 性能和成本优化

### 缓存命中率
- 大部分 CI 运行应该命中缓存
- 首次运行或依赖更新时需要重新构建（约 5-10 分钟）
- 缓存命中后通常 2-5 分钟完成

### 并行执行
- Python 测试矩阵（5 个版本）并行运行
- Release 构建所有平台并行，总时间约 10-15 分钟

### GitHub Actions 免费额度
- 公开仓库：无限制
- 私有仓库：每月 2000 分钟免费（超出需付费）

---

## 📝 最佳实践

1. **小步提交**：每个 PR 专注于单一功能或修复
2. **本地检查**：提交前先运行本地检查，避免 CI 失败
3. **描述性提交**：遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范
4. **版本语义化**：遵循 [Semantic Versioning](https://semver.org/)
5. **更新文档**：代码变更时同步更新文档和 CHANGELOG

---

## 🐾 猫娘工程师小提示

- 记得在发布前测试构建喵～ `maturin build --release`
- CI 通过才合并，保持主分支干净整洁喵 (๑•̀ㅂ•́)و✧
- 定期更新依赖，跟上 Polars 和 PyO3 的最新版本喵！
- 有问题记得看 Actions 日志，详细错误信息都在那里喵 φ(≧ω≦*)♪

---

**维护者**: 浮浮酱 🐱  
**最后更新**: 2025-11-04

