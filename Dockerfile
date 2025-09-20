# Build stage
FROM python:3.12 AS build

# Install uv package manager
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy pyproject.toml
COPY pyproject.toml uv.lock ./

# Install dependencies using uv into virtual environment
RUN uv sync --frozen

# Final stage
FROM python:3.12-slim

# Copy virtual environment from build stage
COPY --from=build /app/.venv /app/.venv

# Set working directory
WORKDIR /app

# Copy application source code
COPY cc_simple_server/ ./cc_simple_server/

# Create non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port 8000
EXPOSE 8000

# Set CMD to run FastAPI server
CMD ["/app/.venv/bin/uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]