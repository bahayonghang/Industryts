# Industryts Documentation

This directory contains the VitePress documentation for Industryts, a high-performance time series processing library.

## 📚 Documentation Structure

```
docs/
├── .vitepress/
│   ├── config.ts          # VitePress configuration (bilingual support)
│   └── dist/              # Built documentation (generated)
├── en/                    # English documentation
│   ├── index.md          # English homepage
│   ├── guide/
│   │   ├── architecture.md    # Architecture guide
│   │   ├── migration.md       # Migration guide v0.1.x → v0.2.0
│   │   ├── examples.md        # Code examples and use cases
│   │   ├── installation.md    # Installation instructions
│   │   ├── introduction.md    # Introduction to IndustryTS
│   │   ├── quick-start.md     # Quick start guide
│   │   └── concepts/
│   ├── api/              # API reference
│   └── development/      # Development documentation
├── zh/                    # Chinese documentation
│   ├── index.md          # Chinese homepage
│   ├── guide/
│   │   ├── architecture.md    # 架构指南
│   │   ├── migration.md       # 迁移指南
│   │   ├── examples.md        # 示例和用例
│   │   ├── installation.md    # 安装说明
│   │   ├── introduction.md    # IndustryTS 简介
│   │   ├── quick-start.md     # 快速开始
│   │   └── concepts/
│   ├── api/              # API 参考
│   └── development/      # 开发文档
├── README.md              # Documentation guide
├── package.json           # Node.js dependencies
└── justfile               # Build commands

```

## 🚀 Quick Start

### Prerequisites

- **Node.js**: 16+ (for VitePress)
- **npm** or **yarn**: Package manager
- **just** (optional but recommended): Modern command runner

### Option 1: Using just (Recommended)

[just](https://github.com/casey/just) is a modern command runner that makes development easier.

```bash
# Install just (if not already installed)
# macOS
brew install just

# Linux
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin

# Windows
cargo install just
# Or: scoop install just

# One-command start (auto-installs dependencies if needed)
cd docs
just dev

# Other commands
just build     # Build for production
just preview   # Preview production build
just clean     # Clean build artifacts
just install   # Install dependencies
just --list    # Show all available commands
```

The documentation will be available at `http://localhost:5173`.

### Option 2: Using make

```bash
# From project root
make docs-install    # Install dependencies
make docs-dev        # Start dev server
make docs-build      # Build for production
make docs-preview    # Preview production build
```

### Option 3: Using npm directly

```bash
cd docs

# Install dependencies
npm install

# Start dev server
npm run docs:dev

# Build for production
npm run docs:build

# Preview production build
npm run docs:preview
```

Built files will be in `.vitepress/dist/`.

## 📖 Documentation Languages

The documentation is fully bilingual:

- **English** (`/en/guide/`): Default language
- **中文** (`/zh/guide/`): Chinese translation

Both languages have mirrored structure and content. When adding new pages, ensure both versions are created.

## 🆕 v0.2.0 Documentation

IndustryTS v0.2.0 introduces a redesigned architecture with improved modularity and new features.

### Key Guides
- **[Architecture Guide](./en/guide/architecture.md)** - Core modules and concepts (English)
- **[架构指南](./zh/guide/architecture.md)** - 核心模块和概念 (Chinese)
- **[Migration Guide](./en/guide/migration.md)** - Upgrading from v0.1.x (English)
- **[迁移指南](./zh/guide/migration.md)** - 从 v0.1.x 升级 (Chinese)
- **[Examples](./en/guide/examples.md)** - Code examples and use cases (English)
- **[示例](./zh/guide/examples.md)** - 代码示例和用例 (Chinese)

### Key Features in v0.2.0
- ✅ **Core Abstractions**: Enhanced `TimeSeriesData`, `Operation` trait, `ExecutionContext`
- ✅ **Pipeline Engine**: `Pipeline`, `PipelineBuilder`, `OperationRegistry`
- ✅ **Execution Tracking**: Performance metrics and execution context
- ✅ **Backward Compatibility**: All v0.1.x APIs remain functional
- ✅ **100% Test Coverage**: 16/16 tests passing

## ✍️ Writing Documentation

### Creating a New Page

1. **Create English version**: `docs/en/guide/my-page.md`
2. **Create Chinese version**: `docs/zh/guide/my-page.md`
3. **Update navigation**: Edit `.vitepress/config.ts` to add the page to both `enConfig` and `zhConfig` sidebars

### Markdown Features

VitePress supports many enhanced Markdown features:

**Code Groups:**
```markdown
::: code-group

```python [Python]
import industryts as its
```

```toml [TOML]
[pipeline]
name = "example"
```

:::
```

**Admonitions:**
```markdown
::: tip
This is a tip!
:::

::: warning
This is a warning!
:::

::: danger
This is a danger message!
:::
```

**Status Badges:**
- ✅ Implemented
- 🚧 In Progress / Pending
- 📋 Planned

### Code Examples

All code examples should:
- Include full imports
- Be runnable (when possible)
- Include comments in the appropriate language
- Show expected output

**Example:**

**English version:**
```python
import industryts as its

# Load time series data
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Expected output
print(data.head())
```

**Chinese version:**
```python
import industryts as its

# 加载时间序列数据
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# 预期输出
print(data.head())
```

## 🏗️ Documentation Structure Guidelines

### Page Organization

Each guide should follow this structure:

1. **Title and overview** - What is this page about?
2. **Prerequisites** - What should readers know first?
3. **Main content** - Step-by-step explanation with examples
4. **Best practices** - ✅ Do / ❌ Don't sections
5. **Next steps** - Links to related pages

### Cross-References

Use relative links to reference other documentation pages:

```markdown
See the [Installation Guide](/en/guide/installation) for details.
```

In Chinese:
```markdown
详见[安装指南](/zh/guide/installation)。
```

## 🎨 VitePress Configuration

The main configuration is in `.vitepress/config.ts`.

### Key Configuration Sections

- **`locales`**: Language routing and labels
- **`themeConfig`**: Navigation, sidebar, search
- **`markdown`**: Markdown processing options

### Updating Navigation

To add a new page to the sidebar:

1. Open `.vitepress/config.ts`
2. Find `enConfig.themeConfig.sidebar` (for English)
3. Add your page to the appropriate section
4. Repeat for `zhConfig.themeConfig.sidebar` (for Chinese)

## 📝 Content Checklist

When adding new documentation:

- [ ] English version created
- [ ] Chinese version created (with translated content)
- [ ] Added to navigation in `.vitepress/config.ts`
- [ ] Code examples tested and working
- [ ] Cross-references to related pages added
- [ ] Status badges added (✅/🚧/📋) if applicable
- [ ] Proper heading hierarchy (# → ## → ###)
- [ ] Internal links tested

## 🔍 Search

VitePress provides built-in local search. Search indexing is automatic and includes both English and Chinese content.

## 🚢 Deployment

### GitHub Pages

To deploy to GitHub Pages:

1. Build the documentation:
   ```bash
   make docs-build
   ```

2. Push the `.vitepress/dist` directory to the `gh-pages` branch:
   ```bash
   cd .vitepress/dist
   git init
   git add -A
   git commit -m "Deploy documentation"
   git push -f git@github.com:yourusername/industryts.git main:gh-pages
   ```

3. Enable GitHub Pages in repository settings, pointing to the `gh-pages` branch.

### Other Hosting

The built documentation (`.vitepress/dist/`) is static HTML/CSS/JS and can be hosted on:
- Netlify
- Vercel
- AWS S3 + CloudFront
- Any static hosting service

## 🐛 Troubleshooting

### "Module not found" errors

**Solution**: Install dependencies
```bash
cd docs
npm install
```

### Port 5173 already in use

**Solution**: Kill the process or use a different port
```bash
# Use different port
cd docs
npx vitepress dev --port 5174
```

### Changes not reflecting in dev server

**Solution**: Restart the dev server
```bash
# Stop with Ctrl+C, then restart
make docs-dev
```

### Build errors

**Solution**: Check for:
- Broken internal links
- Invalid Markdown syntax
- Missing images or assets

## 📚 Resources

- **VitePress Documentation**: https://vitepress.dev/
- **Markdown Guide**: https://www.markdownguide.org/
- **Vue.js** (for custom components): https://vuejs.org/

## 🤝 Contributing

When contributing documentation:

1. Follow the existing structure and style
2. Test your changes locally with `make docs-dev`
3. Ensure both English and Chinese versions are updated
4. Build successfully with `make docs-build`
5. Submit a pull request

---

**Note**: This documentation system was created to provide a modern, bilingual documentation experience for Industryts users. If you have suggestions for improvements, please open an issue or pull request!
