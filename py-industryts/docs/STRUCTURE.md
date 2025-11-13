# 文档结构说明

## 目录树

```
py-industryts/docs/
├── .vitepress/
│   ├── config.ts              # VitePress 配置文件
│   └── cache/                 # 构建缓存
├── en/                        # 英文文档
│   ├── index.md              # 英文首页
│   ├── guide/
│   │   ├── introduction.md    # 简介
│   │   ├── installation.md    # 安装指南
│   │   ├── quick-start.md     # 快速开始
│   │   └── concepts/
│   │       └── timeseries.md  # TimeSeriesData 概念
│   ├── api/
│   │   └── core.md            # 核心 API 参考
│   └── examples/
│       └── basic.md           # 基础示例
├── guide/                     # 中文文档
│   ├── introduction.md        # 简介
│   ├── installation.md        # 安装指南
│   ├── quick-start.md         # 快速开始
│   └── concepts/
│       └── timeseries.md      # TimeSeriesData 概念
├── api/                       # 中文 API 参考
│   └── core.md                # 核心 API 参考
├── examples/                  # 中文示例
│   └── basic.md               # 基础示例
├── index.md                   # 中文首页
├── package.json               # npm 配置
├── justfile                   # Just 任务文件
├── .gitignore                 # Git 忽略文件
├── README.md                  # 文档说明
└── STRUCTURE.md               # 本文件
```

## 文件说明

### 配置文件

- **`.vitepress/config.ts`**: VitePress 主配置文件
  - 定义多语言支持 (中文/英文)
  - 配置导航菜单和侧边栏
  - 设置主题和搜索功能

- **`package.json`**: npm 项目配置
  - 定义依赖 (vitepress, vue)
  - 定义构建脚本

- **`justfile`**: Just 任务文件
  - `install`: 安装依赖
  - `dev`: 启动开发服务器
  - `build`: 构建文档
  - `preview`: 预览构建结果
  - `clean`: 清理构建文件

### 中文文档 (根目录)

#### 首页
- **`index.md`**: 中文首页,展示项目特性和快速链接

#### 指南 (`guide/`)
- **`introduction.md`**: 项目简介、架构设计、核心特性
- **`installation.md`**: 安装说明、系统要求、故障排除
- **`quick-start.md`**: 快速开始指南、基础示例、常见操作
- **`concepts/timeseries.md`**: TimeSeriesData 详细说明

#### API 参考 (`api/`)
- **`core.md`**: 核心类 (TimeSeriesData, Pipeline) 的 API 参考

#### 示例 (`examples/`)
- **`basic.md`**: 基础使用示例、传感器数据处理、特征工程等

### 英文文档 (`en/`)

结构与中文文档相同,但内容为英文:

- **`index.md`**: 英文首页
- **`guide/`**: 英文指南
  - `introduction.md`
  - `installation.md`
  - `quick-start.md`
  - `concepts/timeseries.md`
- **`api/`**: 英文 API 参考
  - `core.md`
- **`examples/`**: 英文示例
  - `basic.md`

### 说明文档

- **`README.md`**: 文档项目的说明,包括快速开始、部署方式
- **`STRUCTURE.md`**: 本文件,说明文档结构

## 多语言支持

文档支持中文和英文两种语言:

- **默认语言**: 简体中文 (根目录)
- **英文**: `/en/` 路径

### 语言切换

用户可以通过网站右上角的语言选择器在中英文之间切换。

### 添加新内容

1. **中文内容**: 在对应的中文目录中创建 `.md` 文件
2. **英文内容**: 在对应的 `en/` 子目录中创建 `.md` 文件
3. **更新配置**: 在 `.vitepress/config.ts` 中添加导航和侧边栏链接

## 构建和部署

### 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run docs:dev

# 访问 http://localhost:5173
```

### 构建

```bash
# 构建文档
npm run docs:build

# 输出目录: .vitepress/dist/
```

### 部署

构建后的文件可以部署到:
- Netlify
- Vercel
- GitHub Pages
- 其他静态网站托管服务

## 内容规范

### 文件命名
- 使用小写字母和连字符 (kebab-case)
- 例如: `quick-start.md`, `core-concepts.md`

### 标题结构
- 使用 Markdown 标题 (#, ##, ###)
- 首页使用 `---` 分隔符定义 frontmatter

### 代码示例
- 使用代码块标记语言: ` ```python `, ` ```toml `
- 包含完整的导入语句
- 提供可运行的示例

### 链接
- 中文文档: `/guide/introduction`, `/api/core`
- 英文文档: `/en/guide/introduction`, `/en/api/core`

## 扩展文档

### 添加新页面

1. 创建 `.md` 文件
2. 在 `.vitepress/config.ts` 中的 `sidebar` 配置中添加链接
3. 在 `nav` 中添加导航菜单项 (如需要)

### 添加新章节

例如添加"高级主题"章节:

1. 创建目录: `guide/advanced/`
2. 创建文件: `guide/advanced/custom-operations.md`
3. 在 `config.ts` 中添加:

```typescript
{
  text: 'Advanced Topics',
  items: [
    { text: 'Custom Operations', link: '/en/guide/advanced/custom-operations' }
  ]
}
```

## 常见任务

### 更新首页
编辑 `index.md` (中文) 和 `en/index.md` (英文)

### 添加新示例
1. 在 `examples/` 中创建新文件
2. 在 `en/examples/` 中创建英文版本
3. 在 `config.ts` 中更新侧边栏

### 修复文档错误
1. 找到对应的 `.md` 文件
2. 编辑内容
3. 本地测试: `npm run docs:dev`
4. 提交更改

## 性能优化

- VitePress 自动优化构建输出
- 支持增量构建
- 自动代码分割
- 本地搜索功能

## 许可证

MIT
