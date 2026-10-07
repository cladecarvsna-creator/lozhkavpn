#!/bin/bash
# Patch android build to include libbox.aar

ANDROID_DIR="android"
LIBS_DIR="$ANDROID_DIR/app/libs"
mkdir -p "$LIBS_DIR"

# Move libbox.aar to libs/
mv /tmp/libbox.aar "$LIBS_DIR/libbox.aar"

# Add flatDir and implementation to app/build.gradle
# Insert flatDir repository
sed -i '/repositories {/a\        flatDir { dirs "libs" }' "$ANDROID_DIR/app/build.gradle"

# Add libbox dependency
sed -i '/dependencies {/a\    implementation(name: "libbox", ext: "aar")' "$ANDROID_DIR/app/build.gradle"

# Set minSdk to 21 (required by libbox)
sed -i 's/minSdk = flutter.minSdkVersion/minSdk = 21/' "$ANDROID_DIR/app/build.gradle"

echo "gradle patched"
