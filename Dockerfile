# 使用包含 docker-compose 的官方镜像，版本稳定
FROM docker/compose:1.29.2

# 设置工作目录
WORKDIR /workspace

# 拷贝模板目录和控制脚本到镜像中
COPY template/ /workspace/template/
COPY control.sh /usr/local/bin/control.sh

# 赋予控制脚本执行权限
RUN chmod +x /usr/local/bin/control.sh

# 将控制脚本设置为入口点，确保 'up', 'down' 等作为参数传递
ENTRYPOINT ["/usr/local/bin/control.sh"]

