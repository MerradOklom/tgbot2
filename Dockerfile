FROM szemeng76/chatgpt-telegram-workers:latest

WORKDIR /app
EXPOSE 8787

# Set timezone environment variable
ENV TZ=America/Argentina/Buenos_Aires

# Install curl, python3, pip, and tzdata; configure system timezone
RUN apk add --no-cache curl python3 py3-pip tzdata && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    python3 -m venv /app/venv && \
    . /app/venv/bin/activate && \
    pip install --no-cache-dir uv

# Set PATH to include virtual environment binaries
ENV PATH="/app/venv/bin:$PATH"

# Copy dummy HTTP server script
COPY dummy-server.js /app/dummy-server.js

# Set entrypoint to copy secrets, run dummy server, and start the application
ENTRYPOINT ["/bin/sh", "-c", "\
    cd /app && \
    echo \"Copying secrets from /etc/secrets/ to /app/...\" && \
    cp /etc/secrets/* /app/ && \
    echo \"Starting dummy HTTP server on port 8787 in background...\" && \
    node /app/dummy-server.js & \
    echo \"Starting main application in $(pwd)...\" && \
    exec node /app/index.js"]
