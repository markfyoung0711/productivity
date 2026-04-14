FROM python:3.11-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Install system dependencies (IBM DB2 driver, SSL, and common utilities)
RUN apt-get update && apt-get install -y \
    libssl-dev \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy dependency files first (for layer caching)
COPY pyproject.toml uv.lock ./

# Install Python dependencies from lockfile (no drift)
RUN uv sync --frozen

# Copy the rest of the project
COPY . .
