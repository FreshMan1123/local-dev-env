#!/bin/sh
set -e

# 脚本的根目录，即 control.sh 所在的目录
SCRIPT_DIR=$(dirname "$0")

# 获取主机上的当前工作目录（通过环境变量）
HOST_PWD=${HOST_PWD:-$(pwd)}

# 在容器内，template 目录应该在 /workspace/template
TEMPLATE_DIR="/workspace/template"

# 检查 docker-compose.yml 文件是否存在
if [ ! -f "$TEMPLATE_DIR/docker-compose.yml" ]; then
    echo "❌ 错误: 在 $TEMPLATE_DIR 中未找到 docker-compose.yml 文件。"
    echo "当前工作目录: $(pwd)"
    echo "尝试查找文件:"
    find /workspace -name "docker-compose.yml" 2>/dev/null || echo "未找到任何 docker-compose.yml 文件"
    exit 1
fi

# 将工作目录切换到 docker-compose.yml 所在的位置
cd "$TEMPLATE_DIR"

# 替换 docker-compose.yml 中的 /host-pwd 为实际的主机工作目录
sed "s|/host-pwd|$HOST_PWD|g" docker-compose.yml > /tmp/docker-compose.yml

# --- 命令分发 ---
COMMAND=$1
shift || true

case "$COMMAND" in
  up)
    echo "🚀 正在启动本地开发环境..."
    docker-compose -f /tmp/docker-compose.yml up -d
    ;;
  down)
    echo "🛑 正在停止并清理 Docker 容器、网络和数据卷..."
    docker-compose -f /tmp/docker-compose.yml down -v
    echo "✅ Docker 资源已清理。本地数据目录保留。"
    ;;
  ps)
    docker-compose -f /tmp/docker-compose.yml ps
    ;;
  destroy)
    echo "🔥 警告：此操作将彻底销毁所有服务、数据和本地数据目录。"
    echo "   所有在 'init-data' 和 'test-data' 中的修改都将丢失。"
    printf "   您确定要继续吗？(输入 'yes' 继续): "
    read -r confirmation
    if [ "$confirmation" = "yes" ]; then
      echo "🛑 正在停止并清理 Docker 容器、网络和数据卷..."
      docker-compose -f /tmp/docker-compose.yml down -v
      echo "🗑️ 正在删除本地数据目录..."
      rm -rf "$HOST_PWD/init-data"
      rm -rf "$HOST_PWD/test-data"
      echo "✅ 已彻底清理完毕。"
    else
      echo "🚫 操作已取消。"
    fi
    ;;
  *)
    # 显示帮助信息，引导用户
    echo "Usage: local-dev <command>"
    echo ""
    echo "本地开发环境管理工具"
    echo ""
    echo "支持的命令:"
    echo "  up        启动所有服务 (如果首次运行会自动初始化数据目录)"
    echo "  down      停止并移除所有 Docker 资源 (保留本地数据目录)"
    echo "  ps        查看服务状态"
    echo "  destroy   彻底销毁环境，包括本地生成的数据目录"
    echo ""
    echo "如何添加/修改SQL脚本?"
    echo "  直接在当前目录下的 'init-data/mysql' 或 'test-data/mysql' 文件夹中操作即可。"
    ;;
esac
    