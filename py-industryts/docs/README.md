# Industryts Python API 文档

这是 Industryts Python API 的 VitePress 文档站点。

## 快速开始

### 安装依赖

```bash
npm install
# 或使用 pnpm
pnpm install
```

### 本地开发

```bash
npm run docs:dev
# 或
pnpm docs:dev
```

文档将在 `http://localhost:5173` 启动。

### 构建文档

```bash
npm run docs:build
# 或
pnpm docs:build
```

构建后的文档将在 `.vitepress/dist` 目录中。

### 预览构建结果

```bash
npm run docs:preview
# 或
pnpm docs:preview
```

## 文档结构

```
docs/
├── index.md                 # 中文首页
├── en/
│   ├── index.md            # 英文首页
│   ├── guide/              # 英文指南
│   ├── api/                # 英文 API 参考
│   └── examples/           # 英文示例
├── guide/                  # 中文指南
├── api/                    # 中文 API 参考
├── examples/               # 中文示例
├── .vitepress/
│   └── config.ts           # VitePress 配置
└── package.json            # 项目配置
```

## 支持的语言

- 简体中文 (默认)
- English

## 文档内容

### 指南 (Guide)
- 简介 (Introduction)
- 安装 (Installation)
- 快速开始 (Quick Start)
- 核心概念 (Core Concepts)
- 用户指南 (User Guide)
- TOML 配置 (TOML Configuration)

### API 参考 (API Reference)
- 核心类 (Core Classes)
- TimeSeriesData
- Pipeline
- 操作 (Operations)
- 工具函数 (Utilities)

### 示例 (Examples)
- 基础示例 (Basic Examples)
- 工业应用案例 (Industrial Use Cases)
- 完整工作流 (Complete Workflows)
- 高级模式 (Advanced Patterns)

### 开发 (Development)
- 架构 (Architecture)
- 从源码构建 (Building from Source)
- 测试 (Testing)
- 贡献指南 (Contributing)

## 配置

VitePress 配置文件位于 `.vitepress/config.ts`。

主要配置项:
- `title`: 文档站点标题
- `description`: 文档描述
- `locales`: 多语言配置
- `themeConfig`: 主题配置
- `markdown`: Markdown 配置

## 部署

文档可以部署到以下平台:

### Netlify

```bash
npm run docs:build
# 将 .vitepress/dist 目录部署到 Netlify
```

### Vercel

```bash
npm run docs:build
# 将 .vitepress/dist 目录部署到 Vercel
```

### GitHub Pages

在 GitHub Actions 中运行:

```yaml
- name: Build docs
  run: npm run docs:build

- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: .vitepress/dist
```

## 贡献

欢迎贡献文档!

### 编辑指南

1. 编辑相应的 `.md` 文件
2. 对于中文内容,编辑 `/guide`, `/api`, `/examples` 目录下的文件
3. 对于英文内容,编辑 `/en/guide`, `/en/api`, `/en/examples` 目录下的文件
4. 本地测试: `npm run docs:dev`
5. 提交 PR

### 文档风格

- 使用清晰、简洁的语言
- 包含代码示例
- 添加适当的标题和子标题
- 使用 Markdown 格式

## 许可证

MIT
