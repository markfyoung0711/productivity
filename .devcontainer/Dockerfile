FROM python:3.12-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Install system dependencies
#   - libxml2/libxslt: needed by Snowflake connector
#   - libpam0g: needed by IBM DB2 clidriver
#   - build-essential: needed to compile ibm-db native extension
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    libpam0g \
    build-essential \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# ── IBM DB2 CLI Driver ────────────────────────────────────────────────────────
# The ibm-db Python package needs the clidriver at build time and runtime.
ENV IBM_DB_HOME=/opt/ibm/clidriver
ENV LD_LIBRARY_PATH=${IBM_DB_HOME}/lib
ENV PATH=${IBM_DB_HOME}/bin:${PATH}

RUN curl -fsSL \
      "https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/linuxx64_odbc_cli.tar.gz" \
      -o /tmp/clidriver.tar.gz \
    && mkdir -p /opt/ibm \
    && tar xzf /tmp/clidriver.tar.gz -C /opt/ibm \
    && rm /tmp/clidriver.tar.gz

# Set working directory
WORKDIR /workspace

# Copy dependency files first (for layer caching)
COPY pyproject.toml uv.lock ./

# Install all Python dependencies including Snowflake, DB2, and dev extras.
# Place the venv outside /workspace so it survives volume mounts at runtime.
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
RUN uv sync --frozen --all-extras

# Put the venv on PATH so pytest, ruff, etc. are available directly
ENV PATH="/opt/venv/bin:${PATH}"

# Copy the rest of the project
COPY . .
