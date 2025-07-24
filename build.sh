#!/bin/bash

# Create dist directory if it doesn't exist
mkdir -p dist

# Download Godot if not available (for CI/CD environments)
if ! command -v godot &> /dev/null; then
    echo "Downloading Godot..."
    wget -q https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip -O godot.zip
    unzip -q godot.zip
    chmod +x Godot_v4.4.1-stable_linux.x86_64
    export PATH=$PWD:$PATH
    ln -sf Godot_v4.4.1-stable_linux.x86_64 godot
fi

# Export the game for web
echo "Exporting Godot project for web..."
godot --headless --export-release "Web" dist/index.html --path .

# Verify export was successful
if [ ! -f "dist/index.html" ]; then
    echo "Export failed - index.html not found"
    exit 1
fi

echo "Export completed successfully!"
ls -la dist/