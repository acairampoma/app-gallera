#!/bin/bash

echo "🔧 Copying PrivacyInfo.xcprivacy to all frameworks..."

# Path to our privacy manifest
SOURCE_PRIVACY="$PWD/Runner/PrivacyInfo.xcprivacy"

# Frameworks that need privacy manifests
FRAMEWORKS=(
    "FBLPromises"
    "FirebaseCore"
    "FirebaseCoreInternal"
    "FirebaseInstallations"
    "FirebaseMessaging"
    "GoogleDataTransport"
    "GoogleUtilities"
    "flutter_local_notifications"
    "image_picker_ios"
    "nanopb"
    "sqflite_darwin"
    "url_launcher_ios"
    "video_player_avfoundation"
)

# Copy to each framework
for framework in "${FRAMEWORKS[@]}"; do
    FRAMEWORK_PATH="$PWD/../build/ios/Release-iphoneos/Runner.app/Frameworks/${framework}.framework"
    if [ -d "$FRAMEWORK_PATH" ]; then
        echo "✅ Copying to ${framework}.framework"
        cp "$SOURCE_PRIVACY" "$FRAMEWORK_PATH/PrivacyInfo.xcprivacy"
    else
        echo "⚠️ Framework not found: ${framework}"
    fi
done

echo "✅ Privacy manifests copied to all frameworks!"