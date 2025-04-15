#!/bin/bash

# Exit if no signing identity provided
if [ -z "$1" ]; then
  echo "❌ Usage: $0 \"<Your Code Signing Identity>\""
  echo "ℹ️ Example: $0 \"Apple Development: Your Name (TEAMID)\""
  exit 1
fi

SIGN_IDENTITY="$1"

# Update this to your actual ZoomSDK path
ZOOM_SDK_PATH="./macos/Runner/Zoom/ZoomSDK"

echo "🔐 Signing with identity: $SIGN_IDENTITY"
echo "📁 ZoomSDK path: $ZOOM_SDK_PATH"

# Re-sign .frameworks
find "$ZOOM_SDK_PATH" -name "*.framework" -type d | while read -r fw; do
    echo "Resigning framework: $fw"
    codesign --force --deep --sign "$SIGN_IDENTITY" "$fw"
done

# Re-sign .dylibs
find "$ZOOM_SDK_PATH" -name "*.dylib" -type f | while read -r dylib; do
    echo "Resigning dylib: $dylib"
    codesign --force --sign "$SIGN_IDENTITY" "$dylib"
done

# Re-sign .bundles (if any)
find "$ZOOM_SDK_PATH" -name "*.bundle" -type d | while read -r bundle; do
    echo "Resigning bundle: $bundle"
    codesign --force --deep --sign "$SIGN_IDENTITY" "$bundle"
done

echo "✅ Done re-signing ZoomSDK components."
