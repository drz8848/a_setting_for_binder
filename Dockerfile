# 基础镜像：Ubuntu 22.04（LTS版本，兼容性好）
FROM ubuntu:22.04

# 避免交互弹窗（如时区配置）
ENV DEBIAN_FRONTEND=noninteractive
# 设置默认时区（可选）
ENV TZ=Asia/Shanghai

# 1. 更新系统并安装基础依赖
RUN apt update && apt upgrade -y && \
    apt install -y \
    # GNOME 桌面核心套件
    gnome-session gnome-shell ubuntu-gnome-desktop \
    # VNC 服务（用于桌面投屏）
    tigervnc-standalone-server tigervnc-common \
    # NoVNC（将VNC转为Web服务，适配Binder浏览器访问）
    novnc websockify \
    # 辅助工具（终端、浏览器等）
    gnome-terminal firefox \
    # 清理缓存（减小镜像体积）
    && apt clean && rm -rf /var/lib/apt/lists/*

# 2. 创建非root用户（Binder不推荐root运行）
RUN useradd -m binder-user && echo "binder-user:binder-user" | chpasswd
USER binder-user
WORKDIR /home/binder-user

# 3. 配置VNC（设置密码、分辨率）
RUN mkdir -p ~/.vnc && \
    # VNC密码设为"binder"（可自定义，注意echo后的密码是加密前的）
    echo "binder" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd && \
    # 设置VNC分辨率（适配浏览器）
    echo "geometry=1280x720" > ~/.vnc/config

# 4. 复制启动脚本并赋予执行权限
COPY --chown=binder-user:binder-user start /home/binder-user/start
RUN chmod +x /home/binder-user/start

# 暴露NoVNC端口（固定为6080，NoVNC默认端口）
EXPOSE 6080

# 启动脚本作为容器入口
CMD ["/home/binder-user/start"]
