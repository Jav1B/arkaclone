#!/bin/bash

# Create dist directory if it doesn't exist
mkdir -p dist

# Download Godot if not available (for CI/CD environments)
if ! command -v godot &> /dev/null; then
    echo "Downloading Godot 4.4.1..."
    wget -q https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip
    unzip -q Godot_v4.4.1-stable_linux.x86_64.zip
    chmod +x Godot_v4.4.1-stable_linux.x86_64
    export PATH=$PWD:$PATH
    ln -sf Godot_v4.4.1-stable_linux.x86_64 godot
    
    # Download export templates
    echo "Downloading export templates..."
    wget -q https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_export_templates.tpz
    mkdir -p ~/.local/share/godot/export_templates/4.4.1.stable
    unzip -q Godot_v4.4.1-stable_export_templates.tpz -d ~/.local/share/godot/export_templates/4.4.1.stable
    mv ~/.local/share/godot/export_templates/4.4.1.stable/templates/* ~/.local/share/godot/export_templates/4.4.1.stable/
    rmdir ~/.local/share/godot/export_templates/4.4.1.stable/templates
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