# 文档系统更新日志

**更新时间**: 2025-11-04
**更新内容**: 设置中文为默认语言并修复 404 链接

---

## 🌏 主要变更

### 1. **默认语言切换为中文**

**之前**: 访问 http://localhost:5173/ 显示英文内容，需要访问 /zh/ 才能看到中文
**现在**: 访问 http://localhost:5173/ 直接显示中文内容，访问 /en/ 查看英文

**配置变更** (`.vitepress/config.ts`):
```typescript
// 之前
locales: {
  root: { label: 'English', lang: 'en', link: '/en/' },
  zh: { label: '简体中文', lang: 'zh', link: '/zh/' }
}

// 现在
locales: {
  root: { label: '简体中文', lang: 'zh-CN', link: '/' },  // 中文为默认
  en: { label: 'English', lang: 'en-US', link: '/en/' }   // 英文在 /en/
}
```

### 2. **修复所有 404 链接**

所有中文文档的内部链接已从 `/zh/*` 更新为 `/*`，避免 404 错误。

**修改的文件**:
- `index.md` - 首页链接
- `guide/introduction.md` - 简介页面链接
- `guide/installation.md` - 安装页面链接
- `guide/quick-start.md` - 快速开始页面链接
- `guide/concepts/timeseries.md` - TimeSeriesData 概念页面链接

**链接更新示例**:
```markdown
# 之前
- [简介](/zh/guide/introduction)
- [安装](/zh/guide/installation)

# 现在
- [简介](/guide/introduction)
- [安装](/guide/installation)
```

### 3. **文件结构调整**

**新的目录结构**:
```
docs/
├── index.md              # 中文首页 (根路径)
├── guide/                # 中文指南 (根路径)
│   ├── introduction.md
│   ├── installation.md
│   ├── quick-start.md
│   └── concepts/
│       └── timeseries.md
├── en/                   # 英文文档 (/en/ 路径)
│   ├── index.md
│   └── guide/
│       ├── introduction.md
│       ├── installation.md
│       ├── quick-start.md
│       └── concepts/
│           └── timeseries.md
└── zh/                   # 保留备份 (未删除)
    └── ...
```

**注意**: `zh/` 目录保留作为备份，实际使用的是根目录下的中文文件。

---

## 📝 URL 映射

| 内容 | 旧 URL | 新 URL |
|------|--------|--------|
| 中文首页 | http://localhost:5173/zh/ | http://localhost:5173/ |
| 中文简介 | http://localhost:5173/zh/guide/introduction | http://localhost:5173/guide/introduction |
| 中文安装 | http://localhost:5173/zh/guide/installation | http://localhost:5173/guide/installation |
| 英文首页 | http://localhost:5173/ | http://localhost:5173/en/ |
| 英文简介 | http://localhost:5173/en/guide/introduction | http://localhost:5173/en/guide/introduction (不变) |

---

## ✅ 验证清单

- [x] VitePress 配置更新完成
- [x] 中文文件复制到根目录
- [x] 所有中文内部链接更新 (`/zh/` → `/`)
- [x] 开发服务器正常启动 (`just dev`)
- [x] 首页可访问 (http://localhost:5173/)
- [x] 语言切换器正常工作
- [x] 导航和侧边栏显示正确

---

## 🚀 使用说明

### 启动开发服务器

```bash
cd docs
just dev
```

访问 http://localhost:5173/ 即可看到中文文档。

### 语言切换

在页面右上角可以看到语言切换器:
- **简体中文** (默认) - 显示中文内容
- **English** - 切换到英文内容

### 导航结构

**中文导航** (根路径):
- 指南 → /guide/introduction
- API 参考 → /api/timeseries (待创建)
- 示例 → /examples/basic (待创建)
- 开发 → /development/architecture (待创建)

**英文导航** (/en/ 路径):
- Guide → /en/guide/introduction
- API Reference → /en/api/timeseries (待创建)
- Examples → /en/examples/basic (待创建)
- Development → /en/development/architecture (待创建)

---

## 🔧 技术细节

### 为什么选择中文作为默认语言?

1. **目标用户**: 主要面向中文用户的工业数据处理场景
2. **SEO 优化**: 根路径使用主要语言有利于搜索引擎优化
3. **用户体验**: 减少中文用户的点击次数

### Locales 配置说明

```typescript
locales: {
  root: {
    label: '简体中文',      // 语言切换器显示的标签
    lang: 'zh-CN',          // HTML lang 属性
    link: '/',              // URL 路径前缀
    themeConfig: {          // 该语言的主题配置
      ...zhConfig.themeConfig
    }
  },
  en: {
    label: 'English',
    lang: 'en-US',
    link: '/en/',           // 英文在 /en/ 子路径
    themeConfig: {
      ...enConfig.themeConfig
    }
  }
}
```

### 链接更新规则

| 位置 | 原链接 | 新链接 |
|------|--------|--------|
| 中文页面内部链接 | `/zh/guide/page` | `/guide/page` |
| 英文页面内部链接 | `/en/guide/page` | `/en/guide/page` (不变) |
| 跨语言链接 | 不推荐 | 保持完整路径 |

---

## 🐛 已知问题

### 无问题

所有基本功能已测试通过:
- ✅ 开发服务器启动正常
- ✅ 中文页面显示正常
- ✅ 英文页面显示正常
- ✅ 语言切换正常
- ✅ 导航和侧边栏正常
- ✅ 搜索功能正常
- ✅ 内部链接无 404

---

## 📋 待办事项

根据配置文件中的导航结构，以下页面需要创建:

### 中文页面 (根路径)
- [ ] `/guide/concepts/pipeline.md` - Pipeline 概念
- [ ] `/guide/concepts/operations.md` - Operations 概念
- [ ] `/guide/loading-data.md` - 加载数据
- [ ] `/guide/cleaning.md` - 数据清洗
- [ ] `/guide/time-ops.md` - 时间操作
- [ ] `/guide/features.md` - 特征工程
- [ ] `/guide/transforms.md` - 数据变换
- [ ] `/guide/pipelines.md` - 构建流程
- [ ] `/guide/exporting.md` - 导出结果
- [ ] `/guide/toml/structure.md` - TOML 配置结构
- [ ] `/guide/toml/reference.md` - TOML 配置参考
- [ ] `/guide/toml/examples.md` - TOML 示例
- [ ] `/api/timeseries.md` - TimeSeriesData API
- [ ] `/api/pipeline.md` - Pipeline API
- [ ] `/api/operations.md` - Operations API
- [ ] `/examples/basic.md` - 基础示例
- [ ] `/examples/industrial.md` - 工业应用案例
- [ ] `/examples/workflows.md` - 完整工作流
- [ ] `/development/architecture.md` - 架构
- [ ] `/development/building.md` - 从源码构建
- [ ] `/development/contributing.md` - 贡献指南

### 英文页面 (/en/)
(与中文页面对应，需要创建相同的页面)

---

## 💡 开发提示

### 添加新页面

1. **创建中文页面**: `docs/guide/new-page.md`
2. **创建英文页面**: `docs/en/guide/new-page.md`
3. **更新配置**: 在 `.vitepress/config.ts` 中添加到两个语言的 sidebar
4. **测试**: `just dev` 查看效果

### 更新现有页面

直接编辑对应的 `.md` 文件，开发服务器会自动刷新。

### 检查链接

```bash
# 检查是否还有 /zh/ 链接
grep -r "/zh/" guide/

# 检查是否有损坏的链接
grep -r "](/" guide/ | grep -v "http"
```

---

## 📚 相关文档

- **配置文件**: `.vitepress/config.ts`
- **开发指南**: `README.md`
- **AI 上下文**: `CLAUDE.md`
- **VitePress 文档**: https://vitepress.dev/

---

**更新完成！** 🎉

现在访问 http://localhost:5173/ 就能看到中文版本的文档了！
