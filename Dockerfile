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

# Set entrypoint to manage configs, run dummy server, and start the application
ENTRYPOINT ["/bin/sh", "-c", "\
    cd /app && \
    if [ -n \"$CONFIG_JSON\" ]; then \
        echo \"Downloading config.json from $CONFIG_JSON\"; \
        curl -L -o /app/config.json \"$CONFIG_JSON\" || { echo \"Failed to download config.json\"; exit 1; }; \
    else \
        echo \"CONFIG_JSON environment variable not set\"; \
        exit 1; \
    fi && \
    if [ -n \"$CONFIG_TOML\" ]; then \
        echo \"Downloading config.toml from $CONFIG_TOML\"; \
        curl -L -o /app/config.toml \"$CONFIG_TOML\" || { echo \"Failed to download config.toml\"; exit 1; }; \
    else \
        echo \"CONFIG_TOML environment variable not set\"; \
        exit 1; \
    fi && \
    echo \"Starting dummy HTTP server on port 8787 in background...\"; \
    node /app/dummy-server.js & \
    echo \"Starting main application in $(pwd)...\"; \
    exec node /app/index.js"]
