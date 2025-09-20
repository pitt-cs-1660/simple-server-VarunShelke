# Build stage
FROM python:3.12 AS build

RUN pip install uv
WORKDIR /app
COPY pyproject.toml uv.lock README.md ./
COPY cc_simple_server/ ./cc_simple_server/
COPY tests/ ./tests/
RUN uv sync

# Final stage
FROM python:3.12-slim
COPY --from=build /app/.venv /app/.venv
WORKDIR /app
COPY cc_simple_server/ ./cc_simple_server/
COPY tests/ ./tests/
ENV PATH="/app/.venv/bin:$PATH"
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 8000
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
