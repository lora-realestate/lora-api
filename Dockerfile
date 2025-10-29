#-----------------------------------------------------------
# base
#-----------------------------------------------------------
FROM python:3.12-slim AS base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_CACHE_DIR="/opt/.cache" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYTHONPATH="/app/src" \
    PORT=8000

ENV PATH="$POETRY_HOME/bin:/app/.venv/bin:$PATH"

WORKDIR /app

#-----------------------------------------------------------
# builder 
#-----------------------------------------------------------
FROM base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential curl git \
  && rm -rf /var/lib/apt/lists/*

ARG POETRY_VERSION=2.2.0

RUN curl -sSL https://install.python-poetry.org | python3 - \
 && chmod a+x $POETRY_HOME/bin/poetry

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root --only main --sync \
 && rm -rf $POETRY_CACHE_DIR

#-----------------------------------------------------------
# builder-dev 
#-----------------------------------------------------------
FROM builder AS builder-dev

RUN poetry install --no-root --with dev --sync \
 && rm -rf $POETRY_CACHE_DIR

#-----------------------------------------------------------
# prod image
#-----------------------------------------------------------
FROM base AS prod

RUN apt-get update && apt-get install -y --no-install-recommends \
 curl \
 ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/.venv /app/.venv

COPY src/ ./src/

RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fsS http://localhost:${PORT}/health || exit 1

CMD bash -c "gunicorn -k uvicorn.workers.UvicornWorker lora_api.main:app --bind 0.0.0.0:${PORT:-8000} --workers 3 --timeout 60"


#-----------------------------------------------------------
# dev image
#-----------------------------------------------------------
FROM base AS dev

RUN apt-get update && apt-get install -y --no-install-recommends \
 curl \
 ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder-dev /app/.venv /app/.venv

COPY pyproject.toml ./
COPY src/ ./src/
COPY tests/ ./tests/

RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app

USER appuser

EXPOSE ${PORT}

ENV FASTAPI_ENV=development

CMD bash -c "uvicorn lora_api.main:app --host 0.0.0.0 --port ${PORT:-8000} --reload"
