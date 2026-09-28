# Blink Arcana on Replit

This is a Godot desktop game with a Rust GDExtension, not a web application. Use the **Blink Arcana** desktop (VNC) workflow to open the game in Replit's desktop preview. Its command is `bash scripts/run-replit.sh`. The script downloads and verifies the official Godot 4.6 stable Linux binary into the user's cache on first launch; it does not replace the project's engine or commit the binary.

The repository already includes a Linux Rust GDExtension binary built for Godot 4.6. Keep Godot and the extension on compatible versions. For development, the Rust workspace is under `rust/`; this environment's bundled Rust is older than the repository's pinned Rust 1.98.1, so rebuilding the extension requires a compatible toolchain and `protoc`. Do not run `just setup` blindly: it installs several unrelated cross-compilation targets and tools.

The current battle scene launches, but its content is incomplete: the resource directories are absent and the scene starts with no units, immediately declaring victory. These are existing project issues, not preview setup failures. No external secrets or services are needed to launch the scene.