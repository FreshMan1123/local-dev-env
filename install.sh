#!/bin/sh
#
# local-dev: 本地开发环境管理工具安装器
# 用户处需要使用的脚本只有这个，会自动帮用户添加初始化路径以及相关docker
# 这个脚本会检测你的 Shell 环境，并将 'local-dev' 别名
# 添加到你的配置文件中。
#

set -e # 如果出错则立即退出

# --- 配置 ---
# 定义别名和要执行的命令
ALIAS_NAME="local-dev"

# !!重要!!：请在构建并推送镜像后，将此处的镜像名称修改为您的私有仓库地址
DOCKER_IMAGE_NAME="crpi-phrybi23i96jrlni.cn-guangzhou.personal.cr.aliyuncs.com/app12311/local-dev-env-github:v1.0.0"

# 创建一个函数来执行容器运行前的准备工作
# 使用 cat 命令定义函数，避免复杂的转义
LOCAL_DEV_FUNCTION=$(cat <<'EOF'
local-dev-env() {
  # 检查当前目录是否存在init-data和test-data
  if [ ! -d "$(pwd)/init-data" ] || [ ! -d "$(pwd)/test-data" ]; then
    echo "🚀 首次运行，正在初始化数据目录..."
    # 创建临时容器来复制模板文件
    docker run --rm --entrypoint cp -v "$(pwd):/tmp/host" '$DOCKER_IMAGE_NAME' -r /workspace/template/init-data /tmp/host/
    docker run --rm --entrypoint cp -v "$(pwd):/tmp/host" '$DOCKER_IMAGE_NAME' -r /workspace/template/test-data /tmp/host/
    echo "✅ 数据目录初始化完毕！"
    echo "   您可以直接在 'init-data' 和 'test-data' 文件夹中管理 SQL 脚本。"
  fi
  # 设置环境变量并运行主容器
  docker run --rm -it -w /workspace \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$(pwd)/init-data":/workspace/template/init-data \
    -v "$(pwd)/test-data":/workspace/template/test-data \
    -e HOST_PWD="$(pwd)" '$DOCKER_IMAGE_NAME' "$@"
}
EOF
)


# --- 主逻辑 ---
echo "⚙️  正在为您安装 'local-dev' 环境管理工具..."

# 1. 检查 Docker 是否已安装
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ 错误：未检测到 Docker。请先安装 Docker Desktop。"
  exit 1
fi

# 2. 检测用户的 Shell 类型并找到配置文件
# 优先使用环境变量，如果不存在则尝试通过进程名检测
if [ -n "$ZSH_VERSION" ]; then
  CONFIG_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  CONFIG_FILE="$HOME/.bashrc"
elif ps -p $$ | grep -q "zsh"; then
    CONFIG_FILE="$HOME/.zshrc"
elif ps -p $$ | grep -q "bash"; then
    CONFIG_FILE="$HOME/.bashrc"
else
  echo "❌ 错误：无法识别您的 Shell。目前仅支持 Zsh 和 Bash。"
  echo "请手动将以下函数添加到您的 Shell 配置文件中："
  echo ""
  echo "$LOCAL_DEV_FUNCTION"
  echo "alias ${ALIAS_NAME}='local-dev-env'"
  echo ""
  exit 1
fi

# 3. 移除可能存在的旧别名，以确保更新
if [ -f "$CONFIG_FILE" ]; then
    echo "🔍 正在检查并清理旧版本..."
    # 使用 sed 命令安全地删除旧的别名行和注释行
    # -i'.bak' 会在原地修改文件，并创建一个 .bak 后缀的备份文件，确保安全
    sed -i'.bak' "/alias ${ALIAS_NAME}=/d" "$CONFIG_FILE"
    sed -i'.bak' "/# local-dev: 本地开发环境管理工具/d" "$CONFIG_FILE"
    sed -i'.bak' "/local-dev-env()/,/}/d" "$CONFIG_FILE"
    sed -i'.bak' "/local_dev_run()/,/}/d" "$CONFIG_FILE"
fi

# 4. 将新的函数和别名追加到配置文件
echo "✍️  正在将函数和别名写入到 ${CONFIG_FILE}..."
# 确保在文件末尾有一个空行
echo "" >> "$CONFIG_FILE"
echo "# local-dev: 本地开发环境管理工具" >> "$CONFIG_FILE"

# 使用cat命令直接将函数写入配置文件，避免复杂的字符串转义
cat <<EOT >> "$CONFIG_FILE"
local-dev-env() {
  # 检查当前目录是否存在init-data和test-data
  if [ ! -d "\$(pwd)/init-data" ] || [ ! -d "\$(pwd)/test-data" ]; then
    echo "🚀 首次运行，正在初始化数据目录..."
    # 创建临时容器来复制模板文件
    docker run --rm --entrypoint cp -v "\$(pwd):/tmp/host" $DOCKER_IMAGE_NAME -r /workspace/template/init-data /tmp/host/
    docker run --rm --entrypoint cp -v "\$(pwd):/tmp/host" $DOCKER_IMAGE_NAME -r /workspace/template/test-data /tmp/host/
    echo "✅ 数据目录初始化完毕！"
    echo "   您可以直接在 'init-data' 和 'test-data' 文件夹中管理 SQL 脚本。"
  fi
  # 设置环境变量并运行主容器
  docker run --rm -it -w /workspace \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "\$(pwd)/init-data":/workspace/template/init-data \
    -v "\$(pwd)/test-data":/workspace/template/test-data \
    -e HOST_PWD="\$(pwd)" $DOCKER_IMAGE_NAME "\$@"
}
EOT
echo "alias ${ALIAS_NAME}='local-dev-env'" >> "$CONFIG_FILE"
echo "✅ 安装/更新成功！"

echo ""
echo "🎉 请重启您的终端，或执行 'source ${CONFIG_FILE}' 来让命令立即生效。"

# 5. 直接执行测试，确保模板文件能被复制
echo ""
echo "📋 正在执行测试，直接复制模板文件..."

