FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_NO_DEV=1 \
    UV_PYTHON_DOWNLOADS=0

RUN apt update && apt install -y --no-install-recommends git

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project

COPY . /app

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-dev --no-editable

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

RUN apt update \
  && apt install -y --no-install-recommends \
    procps \
    git \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app /app

ENV PATH="/app/.venv/bin:$PATH"

RUN  chmod +x /app/entrypoint.sh

WORKDIR /workspace

VOLUME /root/.bub

CMD ["/app/entrypoint.sh"]
