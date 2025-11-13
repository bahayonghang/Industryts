# 文档快速开始

## 快速命令

### 安装和启动

```bash
# 进入文档目录
cd py-industryts/docs

# 安装依赖
npm install

# 启动开发服务器
npm run docs:dev
```

访问 `http://localhost:5173` 查看文档。

### 使用 Just

```bash
# 进入文档目录
cd py-industryts/docs

# 查看所有命令
just

# 安装依赖
just install

# 启动开发服务器
just dev

# 构建文档
just build

# 预览构建结果
just preview

# 清理构建文件
just clean
```

## 文档结构一览

### 中文文档
- `/guide/introduction.md` - 项目简介
- `/guide/installation.md` - 安装指南
- `/guide/quick-start.md` - 快速开始
- `/guide/concepts/timeseries.md` - TimeSeriesData 概念
- `/api/core.md` - 核心 API 参考
- `/examples/basic.md` - 基础示例
- `/index.md` - 首页

### 英文文档
- `/en/guide/introduction.md` - Introduction
- `/en/guide/installation.md` - Installation
- `/en/guide/quick-start.md` - Quick Start
- `/en/guide/concepts/timeseries.md` - TimeSeriesData Concepts
- `/en/api/core.md` - Core API Reference
- `/en/examples/basic.md` - Basic Examples
- `/en/index.md` - Home Page

## 编辑文档

### 编辑现有文档

1. 打开对应的 `.md` 文件
2. 编辑内容
3. 保存文件
4. 浏览器会自动刷新显示更改

### 添加新页面

1. 创建新的 `.md` 文件
2. 在 `.vitepress/config.ts` 中的 `sidebar` 配置中添加链接
3. 在 `nav` 中添加导航菜单项 (如需要)

例如,添加新的指南页面:

```typescript
// 在 config.ts 中
{
  text: 'New Guide',
  items: [
    { text: 'My New Page', link: '/guide/my-new-page' }
  ]
}
```

## 配置文件

### `.vitepress/config.ts`

主配置文件,包含:
- 网站标题和描述
- 多语言配置
- 导航菜单
- 侧边栏配置
- 主题设置
- Markdown 配置

### `package.json`

npm 项目配置:
- 依赖: `vitepress`, `vue`
- 脚本: `docs:dev`, `docs:build`, `docs:preview`

### `justfile`

Just 任务文件,提供便捷命令:
- `install` - 安装依赖
- `dev` - 开发模式
- `build` - 构建
- `preview` - 预览
- `clean` - 清理

## 常见操作

### 本地测试

```bash
# 启动开发服务器
npm run docs:dev

# 在浏览器中打开 http://localhost:5173
# 编辑文件后自动刷新
```

### 构建文档

```bash
# 构建为静态文件
npm run docs:build

# 输出目录: .vitepress/dist/
```

### 预览构建结果

```bash
# 预览构建后的文档
npm run docs:preview
```

### 清理缓存

```bash
# 删除构建文件和缓存
rm -rf .vitepress/dist
rm -rf node_modules
npm install
```

## 部署

### 部署到 Netlify

1. 构建文档: `npm run docs:build`
2. 将 `.vitepress/dist` 目录部署到 Netlify

### 部署到 Vercel

1. 构建文档: `npm run docs:build`
2. 将 `.vitepress/dist` 目录部署到 Vercel

### 部署到 GitHub Pages

在 GitHub Actions 中:

```yaml
- name: Build docs
  run: npm run docs:build

- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: .vitepress/dist
```

## 文档内容指南

### 添加代码示例

使用代码块并指定语言:

````markdown
```python
import industryts as its

data = its.TimeSeriesData.from_csv("data.csv")
```
````

### 添加链接

中文文档:
```markdown
[链接文本](/guide/introduction)
```

英文文档:
```markdown
[Link text](/en/guide/introduction)
```

### 添加表格

```markdown
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 值1 | 值2 | 值3 |
```

### 添加提示框

```markdown
::: tip
这是一个提示
:::

::: warning
这是一个警告
:::

::: danger
这是一个危险提示
:::
```

## 故障排除

### 依赖安装失败

```bash
# 清理缓存
npm cache clean --force

# 重新安装
npm install
```

### 开发服务器无法启动

```bash
# 检查端口是否被占用
lsof -i :5173

# 使用不同的端口
npm run docs:dev -- --port 3000
```

### 构建失败

```bash
# 清理构建缓存
rm -rf .vitepress/cache

# 重新构建
npm run docs:build
```

## 更多信息

- [VitePress 官方文档](https://vitepress.dev/)
- [Markdown 语法](https://vitepress.dev/guide/markdown)
- [文档结构说明](./STRUCTURE.md)
- [项目 README](./README.md)
