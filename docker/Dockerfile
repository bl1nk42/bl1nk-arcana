# Multi-stage Docker build for Blink Arcana
# Stage 1: Builder - Build Rust workspace
FROM rust:1.98.1-bookworm AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y pkg-config libssl-dev protobuf-compiler && rm -rf /var/lib/apt/lists/*
COPY rust/Cargo.toml rust/Cargo.lock ./rust/
COPY rust/crates ./rust/crates
COPY proto ./proto
WORKDIR /app/rust
RUN cargo build --release --workspace

# Stage 2: Protoc - Generate Protocol Buffers
FROM rust:1.98.1-bookworm AS protoc
WORKDIR /app
RUN apt-get update && apt-get install -y protobuf-compiler && rm -rf /var/lib/apt/lists/*
COPY proto ./proto
RUN protoc --proto_path=proto --rust_out=. proto/blink_v1.proto

# Stage 3: Godot Export - Export game with Godot 4.7
FROM barichello/godot-ci:4.3 AS godot-export
WORKDIR /app
COPY godot ./godot
COPY --from=builder /app/rust/target/release/libblink_gdext.so ./godot/addons/blink_core/bin/
COPY --from=builder /app/rust/target/release/libblink_gdext.dylib ./godot/addons/blink_core/bin/ 2>/dev/null || true

# Stage 4: Runtime - Minimal runtime image
FROM debian:bookworm-slim AS runtime
WORKDIR /app
RUN apt-get update && apt-get install -y libssl3 ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=godot-export /app/godot ./godot

# Stage 5: Dev - Development environment with Godot 4.7
FROM runtime AS dev
RUN apt-get update && apt-get install -y godot4 && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["godot", "--main-pack", "godot/project.godot"]