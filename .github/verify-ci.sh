#!/bin/bash
# CI 配置验证脚本
# 本脚本验证 CI 配置是否与本地 justfile 一致

set -e

echo "🔍 验证 CI 配置..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查计数
CHECKS_PASSED=0
CHECKS_FAILED=0

# 检查函数
check_command() {
    local description=$1
    local command=$2
    
    echo -n "检查: $description ... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 通过${NC}"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}❌ 失败${NC}"
        ((CHECKS_FAILED++))
    fi
}

# 检查 Rust 工具链
echo "📦 Rust 工具链检查"
check_command "rustc 已安装" "rustc --version"
check_command "cargo 已安装" "cargo --version"
check_command "rustfmt 已安装" "cargo fmt --version"
check_command "clippy 已安装" "cargo clippy --version"
echo ""

# 检查 Python 工具
echo "🐍 Python 工具检查"
check_command "python 已安装" "python --version"
check_command "pip 已安装" "pip --version"
check_command "ruff 已安装" "ruff --version"
check_command "mypy 已安装" "mypy --version"
check_command "pyright 已安装" "pyright --version"
echo ""

# 检查 Rust 代码质量
echo "🔧 Rust 代码质量检查"
check_command "代码格式化检查" "cargo fmt --all -- --check"
check_command "Clippy 检查" "cargo clippy --manifest-path crates/industryts-core/Cargo.toml -- -D warnings"
check_command "Rust 测试" "cargo test --manifest-path crates/industryts-core/Cargo.toml --lib"
echo ""

# 检查 Python 代码质量
echo "🐍 Python 代码质量检查"
check_command "Ruff 检查" "ruff check ."
check_command "Ruff 格式化检查" "ruff format --check ."
check_command "MyPy 严格模式" "mypy py-industryts/industryts --strict"
check_command "Pyright 检查" "pyright py-industryts/industryts"
echo ""

# 总结
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "验证结果:"
echo -e "  ${GREEN}✅ 通过: $CHECKS_PASSED${NC}"
echo -e "  ${RED}❌ 失败: $CHECKS_FAILED${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ 所有检查通过！CI 配置正确。${NC}"
    exit 0
else
    echo -e "${RED}❌ 有 $CHECKS_FAILED 个检查失败。请检查上述错误。${NC}"
    exit 1
fi
