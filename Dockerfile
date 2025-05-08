# 1. 使用官方 Python 运行时作为父镜像
FROM python:3.12-slim

# 2. 设置环境变量

# 3. 设置工作目录
WORKDIR /app
COPY . .
# 4. 安装 uv
RUN pip install --no-cache-dir --upgrade pip && \
    pip install -r requirements.txt

# 5. 优化层缓存：首先复制 pyproject.toml (和可选的 uv.lock)
# 确保 pyproject.toml 位于您项目的根目录，并且会被复制到 /app/pyproject.toml

# 如果您确实在维护一个 uv.lock 文件，并希望在条件成熟时使用它，
# 请取消下面一行的注释，并确保 uv.lock 文件已提交到您的仓库。
# COPY uv.lock .

# 6. 使用 uv sync 安装项目依赖
# 注意：这里暂时移除了 --locked 标志，以避免因 uv.lock 文件问题导致的构建失败。
# uv sync 会尝试根据 pyproject.toml 解析并安装依赖。
# 【重要】请确保您的 pyproject.toml 文件中正确声明了 uvicorn (例如 uvicorn[standard]) 作为依赖！


# 如果您确认您的 uv.lock 文件是最新的且与 pyproject.toml 一致，
# 并且希望强制使用锁文件以保证构建的精确可复现性（这是推荐的最佳实践），
# 请注释掉上面的 'RUN uv sync --system'，并使用下面这行：
# RUN echo "Attempting to install dependencies using 'uv sync --system --locked'..." && \
#     uv sync --system --locked && \
#     echo "Dependency installation with 'uv sync --system --locked' completed."

# 7. 添加诊断命令，检查 uvicorn 安装情况
# 将所有诊断命令合并到一个 RUN 指令中，减少层数并确保它们一起执行或失败


# 8. 复制应用程序的其余代码
# 现在依赖已经安装完毕，再复制应用代码。
COPY . .

# 9. 声明容器监听的端口
EXPOSE 15400

# 10. 定义容器启动时执行的命令
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "15400"]