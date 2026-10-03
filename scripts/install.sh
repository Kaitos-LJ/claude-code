#!/usr/bin/env bash
#
# 在本机安装 cc（本项目还原的 Claude Code CLI）。
#
# 用法:
#   bash scripts/install.sh              # 装依赖 + 构建 + 安装启动器
#   bash scripts/install.sh --no-deps    # 跳过 bun install
#   bash scripts/install.sh --no-build   # 跳过构建，直接安装启动器
#
# 可用环境变量:
#   CC_BIN_NAME     启动器命令名（默认 cc）
#   CC_INSTALL_DIR  启动器安装目录（默认 ~/.local/bin）

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_NAME="${CC_BIN_NAME:-cc}"
INSTALL_DIR="${CC_INSTALL_DIR:-$HOME/.local/bin}"
RUN_DEPS=1
RUN_BUILD=1

for arg in "$@"; do
    case "$arg" in
        --no-deps)  RUN_DEPS=0 ;;
        --no-build) RUN_BUILD=0 ;;
        -h|--help)  sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "未知参数: $arg" >&2; exit 1 ;;
    esac
done

if ! command -v bun >/dev/null 2>&1; then
    echo "错误: 未找到 bun。请先安装: curl -fsSL https://bun.sh/install | bash" >&2
    exit 1
fi

echo "==> bun $(bun --version)  |  仓库: $ROOT"

if [ "$RUN_DEPS" -eq 1 ]; then
    echo "==> 安装依赖 (bun install)"
    (cd "$ROOT" && bun install)
fi

if [ "$RUN_BUILD" -eq 1 ]; then
    echo "==> 构建 (bun run build)"
    (cd "$ROOT" && bun run build)
fi

if [ ! -f "$ROOT/dist/cli.js" ]; then
    echo "错误: 未找到构建产物 $ROOT/dist/cli.js" >&2
    exit 1
fi

mkdir -p "$INSTALL_DIR"
LAUNCHER="$INSTALL_DIR/$BIN_NAME"

cat > "$LAUNCHER" <<LAUNCHER_EOF
#!/usr/bin/env bash
# 由 $ROOT/scripts/install.sh 生成
exec bun "$ROOT/dist/cli.js" "\$@"
LAUNCHER_EOF
chmod +x "$LAUNCHER"

echo "==> 已安装启动器: $LAUNCHER -> bun $ROOT/dist/cli.js"
echo "==> 版本检查: $("$LAUNCHER" --version)"

case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        echo
        echo "提示: $INSTALL_DIR 不在 PATH 中，请加入 shell 配置:"
        echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
        ;;
esac

echo
echo "完成。直接运行: $BIN_NAME"
