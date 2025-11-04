import { defineConfig } from 'vitepress'

// 英文配置
const enConfig = {
  label: 'English',
  lang: 'en',
  themeConfig: {
    nav: [
      { text: 'Guide', link: '/en/guide/introduction' },
      { text: 'API Reference', link: '/en/api/timeseries' },
      { text: 'Examples', link: '/en/examples/basic' },
      { text: 'Development', link: '/en/development/architecture' }
    ],
    sidebar: {
      '/en/guide/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Introduction', link: '/en/guide/introduction' },
            { text: 'Installation', link: '/en/guide/installation' },
            { text: 'Quick Start', link: '/en/guide/quick-start' }
          ]
        },
        {
          text: 'Core Concepts',
          items: [
            { text: 'TimeSeriesData', link: '/en/guide/concepts/timeseries' },
            { text: 'Pipeline', link: '/en/guide/concepts/pipeline' },
            { text: 'Operations', link: '/en/guide/concepts/operations' }
          ]
        },
        {
          text: 'User Guide',
          items: [
            { text: 'Loading Data', link: '/en/guide/loading-data' },
            { text: 'Data Cleaning', link: '/en/guide/cleaning' },
            { text: 'Time Operations', link: '/en/guide/time-ops' },
            { text: 'Feature Engineering', link: '/en/guide/features' },
            { text: 'Transformations', link: '/en/guide/transforms' },
            { text: 'Building Pipelines', link: '/en/guide/pipelines' },
            { text: 'Exporting Results', link: '/en/guide/exporting' }
          ]
        },
        {
          text: 'TOML Configuration',
          items: [
            { text: 'Configuration Structure', link: '/en/guide/toml/structure' },
            { text: 'Configuration Reference', link: '/en/guide/toml/reference' },
            { text: 'Examples', link: '/en/guide/toml/examples' }
          ]
        }
      ],
      '/en/api/': [
        {
          text: 'API Reference',
          items: [
            { text: 'TimeSeriesData', link: '/en/api/timeseries' },
            { text: 'Pipeline', link: '/en/api/pipeline' },
            { text: 'Operations', link: '/en/api/operations' }
          ]
        }
      ],
      '/en/examples/': [
        {
          text: 'Examples',
          items: [
            { text: 'Basic Examples', link: '/en/examples/basic' },
            { text: 'Industrial Use Cases', link: '/en/examples/industrial' },
            { text: 'Complete Workflows', link: '/en/examples/workflows' }
          ]
        }
      ],
      '/en/development/': [
        {
          text: 'Development',
          items: [
            { text: 'Architecture', link: '/en/development/architecture' },
            { text: 'Building from Source', link: '/en/development/building' },
            { text: 'Contributing', link: '/en/development/contributing' }
          ]
        }
      ]
    }
  }
}

// 中文配置
const zhConfig = {
  label: '简体中文',
  lang: 'zh',
  themeConfig: {
    nav: [
      { text: '指南', link: '/guide/introduction' },
      { text: 'API 参考', link: '/api/timeseries' },
      { text: '示例', link: '/examples/basic' },
      { text: '开发', link: '/development/architecture' }
    ],
    sidebar: {
      '/guide/': [
        {
          text: '入门指南',
          items: [
            { text: '简介', link: '/guide/introduction' },
            { text: '安装', link: '/guide/installation' },
            { text: '快速开始', link: '/guide/quick-start' }
          ]
        },
        {
          text: '核心概念',
          items: [
            { text: 'TimeSeriesData', link: '/guide/concepts/timeseries' },
            { text: 'Pipeline', link: '/guide/concepts/pipeline' },
            { text: 'Operations', link: '/guide/concepts/operations' }
          ]
        },
        {
          text: '用户指南',
          items: [
            { text: '加载数据', link: '/guide/loading-data' },
            { text: '数据清洗', link: '/guide/cleaning' },
            { text: '时间操作', link: '/guide/time-ops' },
            { text: '特征工程', link: '/guide/features' },
            { text: '数据变换', link: '/guide/transforms' },
            { text: '构建流程', link: '/guide/pipelines' },
            { text: '导出结果', link: '/guide/exporting' }
          ]
        },
        {
          text: 'TOML 配置',
          items: [
            { text: '配置结构', link: '/guide/toml/structure' },
            { text: '配置参考', link: '/guide/toml/reference' },
            { text: '示例', link: '/guide/toml/examples' }
          ]
        }
      ],
      '/api/': [
        {
          text: 'API 参考',
          items: [
            { text: 'TimeSeriesData', link: '/api/timeseries' },
            { text: 'Pipeline', link: '/api/pipeline' },
            { text: 'Operations', link: '/api/operations' }
          ]
        }
      ],
      '/examples/': [
        {
          text: '示例',
          items: [
            { text: '基础示例', link: '/examples/basic' },
            { text: '工业应用案例', link: '/examples/industrial' },
            { text: '完整工作流', link: '/examples/workflows' }
          ]
        }
      ],
      '/development/': [
        {
          text: '开发',
          items: [
            { text: '架构', link: '/development/architecture' },
            { text: '从源码构建', link: '/development/building' },
            { text: '贡献指南', link: '/development/contributing' }
          ]
        }
      ]
    },
    outlineTitle: '目录',
    lastUpdatedText: '最后更新',
    docFooter: {
      prev: '上一页',
      next: '下一页'
    },
    darkModeSwitchLabel: '外观',
    sidebarMenuLabel: '菜单',
    returnToTopLabel: '返回顶部',
    editLink: {
      pattern: 'https://github.com/yourusername/industryts/edit/main/docs/:path',
      text: '在 GitHub 上编辑此页'
    }
  }
}

export default defineConfig({
  title: 'Industryts',
  description: '工业数据的高性能时间序列处理库',

  // 多语言配置 - 中文为默认语言
  locales: {
    root: {
      label: '简体中文',
      lang: 'zh-CN',
      link: '/',
      themeConfig: {
        ...zhConfig.themeConfig
      }
    },
    en: {
      label: 'English',
      lang: 'en-US',
      link: '/en/',
      themeConfig: {
        ...enConfig.themeConfig
      }
    }
  },

  // 主题配置
  themeConfig: {
    logo: '/logo.svg',

    // 社交链接
    socialLinks: [
      { icon: 'github', link: 'https://github.com/yourusername/industryts' }
    ],

    // 搜索配置
    search: {
      provider: 'local',
      options: {
        locales: {
          en: {
            translations: {
              button: {
                buttonText: 'Search',
                buttonAriaLabel: 'Search'
              },
              modal: {
                noResultsText: 'No results found',
                resetButtonTitle: 'Clear search query',
                footer: {
                  selectText: 'Select',
                  navigateText: 'Navigate'
                }
              }
            }
          }
        }
      }
    }
  },

  // Markdown 配置
  markdown: {
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    },
    lineNumbers: true
  },

  // 构建配置
  srcDir: '.',
  outDir: '.vitepress/dist',

  // 忽略死链接检查（对于尚未创建的页面）
  ignoreDeadLinks: true
})
