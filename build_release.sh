#!/bin/bash

# Play Store Build Script
# Automates the process of building a release for Google Play Store

echo "🚀 Qibla Compass - Play Store Build Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if keystore exists
if [ ! -f "android/app/upload-keystore.jks" ]; then
    print_error "Keystore not found at android/app/upload-keystore.jks"
    print_warning "Please ensure your keystore is in the correct location"
    exit 1
fi

if [ ! -f "android/key.properties" ]; then
    print_error "key.properties not found at android/key.properties"
    print_warning "Please create key.properties file with your signing credentials"
    exit 1
fi

print_success "Keystore and credentials found"
echo ""

# Get current version
CURRENT_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
echo "Current version: $CURRENT_VERSION"
echo ""

# Ask user to confirm or update version
read -p "Do you want to update the version? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter new version (e.g., 1.0.1+6): " NEW_VERSION
    # Update version in pubspec.yaml
    sed -i.bak "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
    rm pubspec.yaml.bak 2>/dev/null
    print_success "Version updated to $NEW_VERSION"
else
    print_warning "Using existing version: $CURRENT_VERSION"
fi
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
print_success "Clean complete"
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
print_success "Dependencies retrieved"
echo ""

# Run tests (optional)
read -p "Do you want to run tests before building? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧪 Running tests..."
    flutter test
    if [ $? -ne 0 ]; then
        print_error "Tests failed! Fix errors before building."
        exit 1
    fi
    print_success "All tests passed"
    echo ""
fi

# Build AAB (recommended by Google)
echo "🏗️  Building release AAB..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    print_success "AAB build successful!"
    AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
    AAB_SIZE=$(ls -lh "$AAB_PATH" | awk '{print $5}')
    echo "   Location: $AAB_PATH"
    echo "   Size: $AAB_SIZE"
else
    print_error "AAB build failed!"
    exit 1
fi
echo ""

# Ask if user wants to build APKs too
read -p "Do you want to build APKs as well? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🏗️  Building release APKs..."
    flutter build apk --release --split-per-abi
    
    if [ $? -eq 0 ]; then
        print_success "APK build successful!"
        echo "   APK locations:"
        ls -lh build/app/outputs/flutter-apk/app-*-release.apk | while read line; do
            echo "   - $line"
        done
    else
        print_error "APK build failed!"
    fi
    echo ""
fi

# Summary
echo "=========================================="
echo "✅ BUILD COMPLETE!"
echo "=========================================="
echo ""
echo "📦 Output files:"
echo "   AAB: build/app/outputs/bundle/release/app-release.aab"
if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]; then
    echo "   APKs: build/app/outputs/flutter-apk/"
fi
echo ""
echo "🎯 Next steps:"
echo "   1. Go to Google Play Console"
echo "   2. Create new release"
echo "   3. Upload app-release.aab"
echo "   4. Add release notes"
echo "   5. Submit for review"
echo ""
print_success "Ready for Play Store upload! 🚀"
