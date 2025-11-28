# ~/.GH/Qompass/angle/scripts/angle.sh
# ------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

#!/usr/bin/env bash

set -euo pipefail

DEPOT_TOOLS="$HOME/.local/opt/depot_tools"
if [[ ! -d "$DEPOT_TOOLS" ]]; then
    echo "📦 Cloning depot_tools..."
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "$DEPOT_TOOLS"
fi

export PATH="$DEPOT_TOOLS:$PATH"

# --- STEP 2: Fetch ANGLE source ---
ANGLE_DIR="$HOME/.GH/angle"
if [[ ! -d "$ANGLE_DIR" ]]; then
    echo "📥 Fetching ANGLE source..."
    fetch angle
fi

cd "$ANGLE_DIR"

echo "🔁 Syncing ANGLE dependencies..."
gclient sync

BUILD_DIR="out/WaylandVulkan"
mkdir -p "$BUILD_DIR"
echo "📄 Writing args.gn..."
cat > "$BUILD_DIR/args.gn" <<'EOF'
target_os = "linux"
is_debug = false
angle_enable_vulkan = true
angle_use_wayland = true
angle_enable_null = true
angle_enable_gl = true
angle_enable_d3d9 = false
angle_enable_d3d11 = false
angle_enable_metal = false
angle_build_all = true
EOF

echo "🛠 Running gn gen..."
gn gen "$BUILD_DIR"

echo "🔨 Building ANGLE..."
autoninja -C "$BUILD_DIR"

INSTALL_SCRIPT="$ANGLE_DIR/scripts/angle.sh"
chmod +x "$INSTALL_SCRIPT"
"$INSTALL_SCRIPT"
