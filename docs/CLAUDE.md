# Industryts Documentation - AI Context

**Last Updated:** 2025-11-04
**Status:** Active Development

---

## Overview

This directory contains the VitePress-based documentation for Industryts, providing comprehensive bilingual (English/Chinese) documentation for the high-performance time series processing library.

**Purpose:**
- User-facing documentation for Industryts library
- Installation guides, tutorials, and API reference
- Examples and best practices
- Development and contribution guides

**Tech Stack:**
- VitePress 1.6+ (Vue-based static site generator)
- Node.js 16+ (runtime)
- ESM modules (package.json: "type": "module")

---

## Directory Structure

```
docs/
├── .vitepress/
│   ├── config.ts          # VitePress configuration (bilingual setup)
│   ├── dist/              # Build output (gitignored)
│   └── cache/             # VitePress cache (gitignored)
├── .gitignore             # Ignore node_modules, build artifacts
├── justfile               # Command runner for easy development
├── package.json           # Node.js dependencies and scripts
├── README.md              # Documentation development guide
├── en/                    # English documentation
│   ├── index.md          # English homepage
│   ├── guide/            # User guides
│   │   ├── introduction.md
│   │   ├── installation.md
│   │   ├── quick-start.md
│   │   ├── concepts/     # Core concepts
│   │   │   └── timeseries.md
│   │   ├── loading-data.md (planned)
│   │   ├── cleaning.md (planned)
│   │   ├── features.md (planned)
│   │   ├── transforms.md (planned)
│   │   ├── pipelines.md (planned)
│   │   ├── exporting.md (planned)
│   │   └── toml/ (planned)
│   ├── api/ (planned)
│   ├── examples/ (planned)
│   └── development/ (planned)
└── zh/                    # Chinese documentation (mirrors en/ structure)
    ├── index.md          # Chinese homepage
    └── guide/            # (same structure as en/guide/)
```

---

## Development Workflow

### Quick Start

**Using just (Recommended):**
```bash
cd docs
just dev      # Auto-install dependencies and start dev server
```

**Using make:**
```bash
make docs-dev  # From project root
```

**Using npm:**
```bash
cd docs
npm install
npm run docs:dev
```

### Available Commands

| Command | Description |
|---------|-------------|
| `just dev` | Start development server (auto-install if needed) |
| `just build` | Build for production |
| `just preview` | Preview production build |
| `just install` | Install dependencies |
| `just clean` | Clean build artifacts |
| `just clean-all` | Deep clean (includes node_modules) |
| `just reinstall` | Clean + install |
| `just check` | Check for outdated packages |
| `just update` | Update dependencies |

### Development Server

- **URL:** http://localhost:5173
- **Hot Reload:** Enabled (automatic refresh on file changes)
- **Port:** 5173 (default, can be changed with --port)

---

## Configuration

### VitePress Config (.vitepress/config.ts)

**Key Features:**
- **Bilingual Setup:** English (/en/) and Chinese (/zh/) routes
- **Navigation:** Top nav bar with Guide, API, Examples, Development
- **Sidebar:** Hierarchical sidebar for each language
- **Search:** Local search with bilingual support
- **Theme:** GitHub Light/Dark code theme
- **Line Numbers:** Enabled for code blocks

**Important Sections:**
```typescript
// Locales configuration
locales: {
  root: { label: 'English', lang: 'en', link: '/en/' },
  zh: { label: '简体中文', lang: 'zh', link: '/zh/' }
}

// Theme configuration
themeConfig: {
  logo: '/logo.svg',
  socialLinks: [{ icon: 'github', link: '...' }],
  search: { provider: 'local', ... },
  ...enConfig.themeConfig  // English nav/sidebar
}
```

**Dead Link Checking:**
```typescript
ignoreDeadLinks: true  // Allows linking to planned pages
```

### Package.json

**Critical Setting:**
```json
"type": "module"  // REQUIRED: Enables ESM for VitePress
```

**Scripts:**
- `docs:dev` - Start dev server
- `docs:build` - Build for production
- `docs:preview` - Preview production build

**Dependencies:**
- vitepress: ^1.0.0
- vue: ^3.4.0

---

## Content Guidelines

### Bilingual Content

**Rule:** Every English page MUST have a corresponding Chinese page.

**Structure:**
```
en/guide/introduction.md  ↔  zh/guide/introduction.md
en/guide/installation.md  ↔  zh/guide/installation.md
```

**Adding New Pages:**
1. Create English version: `docs/en/path/to/page.md`
2. Create Chinese version: `docs/zh/path/to/page.md`
3. Update `.vitepress/config.ts`:
   - Add to `enConfig.themeConfig.sidebar`
   - Add to `zhConfig.themeConfig.sidebar`

### Markdown Features

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
Helpful information
:::

::: warning
Important warning
:::

::: danger
Critical information
:::
```

**Status Badges:**
- ✅ Implemented
- 🚧 In Progress / Pending
- 📋 Planned

### Code Examples

**Requirements:**
- Include full imports
- Be runnable (when possible)
- Include comments in appropriate language
- Show expected output

**Example Structure:**
```python
import industryts as its

# English: Load time series data
# Chinese: 加载时间序列数据
data = its.TimeSeriesData.from_csv("sensor_data.csv")

# Expected output
print(data.head())
```

### Page Structure

**Standard Template:**
1. **Title and Overview** - What is this page about?
2. **Prerequisites** - What should readers know first?
3. **Main Content** - Step-by-step with examples
4. **Best Practices** - ✅ Do / ❌ Don't sections
5. **Next Steps** - Links to related pages

### Cross-References

**Use relative links:**
```markdown
See the [Installation Guide](/en/guide/installation) for details.
```

**Chinese:**
```markdown
详见[安装指南](/zh/guide/installation)。
```

---

## Current Status

### Completed Pages

**English:**
- ✅ `en/index.md` - Homepage with features and examples
- ✅ `en/guide/introduction.md` - Project overview, architecture, comparisons
- ✅ `en/guide/installation.md` - Detailed installation instructions
- ✅ `en/guide/quick-start.md` - Tutorial with examples
- ✅ `en/guide/concepts/timeseries.md` - TimeSeriesData documentation

**Chinese:**
- ✅ `zh/index.md` - 主页
- ✅ `zh/guide/introduction.md` - 项目简介
- ✅ `zh/guide/installation.md` - 安装说明
- ✅ `zh/guide/quick-start.md` - 快速开始
- ✅ `zh/guide/concepts/timeseries.md` - TimeSeriesData 文档

### Planned Pages

**Priority 1 (Core Guides):**
- 📋 `guide/concepts/pipeline.md` - Pipeline architecture
- 📋 `guide/concepts/operations.md` - Operations overview
- 📋 `guide/loading-data.md` - Data loading details
- 📋 `guide/cleaning.md` - Data cleaning (fill_null)
- 📋 `guide/features.md` - Feature engineering (lag)
- 📋 `guide/transforms.md` - Transformations (standardize)
- 📋 `guide/pipelines.md` - Building pipelines (programmatic + TOML)

**Priority 2 (API Reference):**
- 📋 `api/timeseries.md` - TimeSeriesData full API
- 📋 `api/pipeline.md` - Pipeline full API
- 📋 `api/operations.md` - All operations reference

**Priority 3 (TOML & Examples):**
- 📋 `guide/toml/structure.md` - TOML configuration structure
- 📋 `guide/toml/reference.md` - Complete TOML reference
- 📋 `guide/toml/examples.md` - TOML examples
- 📋 `examples/basic.md` - Basic examples
- 📋 `examples/industrial.md` - Industrial use cases
- 📋 `examples/workflows.md` - Complete workflows

**Priority 4 (Development):**
- 📋 `development/architecture.md` - Architecture deep dive
- 📋 `development/building.md` - Building from source
- 📋 `development/contributing.md` - Contribution guide

---

## Implementation Notes

### Feature Status Tracking

**In Documentation:**
- Use status badges (✅/🚧/📋) to indicate implementation status
- Clearly mark pending features (e.g., "resample - 🚧 Pending Polars 0.51 API")
- Reference root CLAUDE.md for authoritative status

**Current Implementation Status:**
- ✅ `fill_null` - Fully implemented
- ✅ `lag` - Fully implemented
- ✅ `standardize` - Fully implemented
- 🚧 `resample` - Pending Polars 0.51 API update
- 📋 `rolling` - Planned
- 📋 `outlier_detection` - Planned

### Code Examples Accuracy

**Source of Truth:**
- `py-industryts/industryts/` - Python API implementation
- `crates/industryts-core/src/` - Rust core implementation
- `examples/` - Working example files

**Testing Examples:**
```bash
# Test Python examples
cd examples
python basic_usage.py
```

### Navigation Structure

**Sidebar Organization:**
```
Getting Started
├── Introduction
├── Installation
└── Quick Start

Core Concepts
├── TimeSeriesData
├── Pipeline
└── Operations

User Guide
├── Loading Data
├── Data Cleaning
├── Time Operations
├── Feature Engineering
├── Transformations
├── Building Pipelines
└── Exporting Results

TOML Configuration
├── Configuration Structure
├── Configuration Reference
└── Examples
```

---

## Deployment

### Build Process

```bash
# Build production documentation
just build
# Output: .vitepress/dist/
```

### Deployment Options

**GitHub Pages:**
1. Build: `just build`
2. Deploy `.vitepress/dist/` to `gh-pages` branch
3. Configure GitHub Pages to use `gh-pages` branch

**Netlify/Vercel:**
- Build command: `npm run docs:build`
- Publish directory: `.vitepress/dist`
- Node version: 16+

**Read the Docs:**
- Configure to use VitePress (custom build process)

---

## Troubleshooting

### Common Issues

**Issue: "vitepress" resolved to an ESM file**
**Solution:** Ensure `package.json` has `"type": "module"`

**Issue: Port 5173 already in use**
**Solution:** Kill existing process or use different port:
```bash
npx vitepress dev --port 5174
```

**Issue: Changes not reflecting in dev server**
**Solution:** Restart dev server (Ctrl+C, then `just dev`)

**Issue: Build errors about dead links**
**Solution:** Check `ignoreDeadLinks: true` in config or create missing pages

**Issue: node_modules missing**
**Solution:** Run `just install` or `npm install`

---

## AI Usage Guidelines

### When Making Changes

1. **Check Bilingual Requirement** - Every change needs English AND Chinese versions
2. **Update Navigation** - Add new pages to both sidebars in config.ts
3. **Verify Examples** - Ensure code examples are accurate and runnable
4. **Cross-Reference** - Update related pages with links to new content
5. **Status Badges** - Use ✅/🚧/📋 appropriately

### Adding New Documentation Pages

**Workflow:**
1. Create English page: `docs/en/section/page.md`
2. Create Chinese page: `docs/zh/section/page.md`
3. Update `.vitepress/config.ts`:
   ```typescript
   // In enConfig.themeConfig.sidebar
   { text: 'Page Title', link: '/en/section/page' }

   // In zhConfig.themeConfig.sidebar
   { text: '页面标题', link: '/zh/section/page' }
   ```
4. Test locally: `just dev`
5. Verify both languages display correctly

### Code Example Standards

**Template:**
```markdown
# Operation Name

## Overview
Brief description

## Syntax

```python
import industryts as its

# Example with full imports
data = its.TimeSeriesData.from_csv("data.csv")
pipeline = its.Pipeline()
pipeline.operation_name(param1=value1)
result = pipeline.process(data)
```

## Parameters
- `param1` (type): Description
- `param2` (type, optional): Description

## Examples

### Example 1: Basic Usage
```python
# Full runnable example
```

## Best Practices

✅ **Do:**
- Best practice 1
- Best practice 2

❌ **Don't:**
- Anti-pattern 1
- Anti-pattern 2

## Next Steps
- [Related Topic 1](/en/guide/topic1)
- [Related Topic 2](/en/guide/topic2)
```

---

## Key Files Reference

### Configuration
- `.vitepress/config.ts` - Main VitePress configuration
- `package.json` - Dependencies and scripts
- `justfile` - Development commands

### Documentation
- `README.md` - Documentation development guide (this directory)
- `CLAUDE.md` - AI context (this file)
- `../CLAUDE.md` - Root AI context (project overview)

### Content
- `en/index.md` - English homepage
- `zh/index.md` - Chinese homepage
- `en/guide/**/*.md` - English guides
- `zh/guide/**/*.md` - Chinese guides

---

## Related Documentation

- **Root CLAUDE.md** - Project-level AI context
- **crates/industryts-core/CLAUDE.md** - Rust core documentation
- **py-industryts/CLAUDE.md** - Python bindings documentation
- **README.md** (this dir) - Documentation development guide
- **Root README.md** - User-facing project README

---

## Maintenance Notes

### Keeping Documentation Updated

**When Code Changes:**
1. Update affected documentation pages (both languages)
2. Update status badges if feature status changes
3. Update code examples to reflect new APIs
4. Run `just build` to verify no broken links

**When Adding Features:**
1. Add documentation to relevant guide sections
2. Update API reference
3. Add examples to examples section
4. Update homepage feature list if significant

**Version Updates:**
1. Update version in homepage
2. Update installation instructions if needed
3. Update compatibility information
4. Document breaking changes prominently

### Review Checklist

Before finalizing documentation changes:
- [ ] Both English and Chinese versions created/updated
- [ ] Navigation updated in config.ts (both languages)
- [ ] Code examples tested and working
- [ ] Status badges accurate (✅/🚧/📋)
- [ ] Cross-references added to related pages
- [ ] No dead links (or intentionally ignored)
- [ ] Images/diagrams added to .vitepress/public/
- [ ] Build succeeds: `just build`
- [ ] Displays correctly in dev server: `just dev`

---

**Note:** This documentation system is the primary user-facing documentation for Industryts. Keep it accurate, clear, and up-to-date!
