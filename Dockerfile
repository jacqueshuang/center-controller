# 1. 使用官方 Python 运行时作为父镜像
FROM python:3.12-slim

# 2. 设置环境变量
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# 3. 设置工作目录
WORKDIR /app

# 4. 安装 uv
# 使用基础镜像中的 pip 来安装 uv。
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir uv

# 5. 复制 pyproject.toml (以及 uv.lock, 如果您使用它)
# 将 pyproject.toml 复制到工作目录。
# 如果您在项目中使用 uv.lock 文件来锁定依赖版本以实现更可复现的构建，
# 请务必也复制它。
COPY . .
# COPY uv.lock .  # 如果您有 uv.lock 文件，请取消此行的注释

# 6. 使用 uv sync 安装项目依赖
# uv sync 会根据 pyproject.toml (以及 uv.lock, 如果存在) 来同步环境中的依赖。
# --system 标志指示 uv 将包安装到 Docker 镜像的基础 Python 环境中。
RUN uv sync
# 如果您使用了 uv.lock 并希望强制使用它:
# RUN uv sync --system --locked

# 7. 复制应用程序的其余代码到工作目录
# 这一步应该在安装依赖之后，以便更好地利用 Docker 的层缓存机制。
# 如果您的 pyproject.toml 或 uv.lock 文件没有改变，Docker 不会重新运行上面的依赖安装步骤。


# 8. 声明容器监听的端口
EXPOSE 15400

# 9. 定义容器启动时执行的命令
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "15400"]