#!/bin/bash

# Azan Audio File Compression Script
# This script compresses the azan.mp3 file to an optimal size for Android notifications

set -e

AUDIO_DIR="android/app/src/main/res/raw"
ORIGINAL_FILE="$AUDIO_DIR/azan.mp3"
BACKUP_FILE="$AUDIO_DIR/azan_original_backup.mp3"
COMPRESSED_FILE="$AUDIO_DIR/azan_compressed.mp3"

echo "🎵 Azan Audio File Compression Script"
echo "======================================"
echo ""

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ Error: ffmpeg is not installed"
    echo ""
    echo "Please install ffmpeg:"
    echo "  macOS:   brew install ffmpeg"
    echo "  Ubuntu:  sudo apt install ffmpeg"
    echo "  Windows: Download from https://ffmpeg.org/download.html"
    echo ""
    exit 1
fi

# Check if original file exists
if [ ! -f "$ORIGINAL_FILE" ]; then
    echo "❌ Error: azan.mp3 not found at $ORIGINAL_FILE"
    exit 1
fi

# Get original file size
ORIGINAL_SIZE=$(du -h "$ORIGINAL_FILE" | cut -f1)
echo "📊 Original file size: $ORIGINAL_SIZE"
echo ""

# Create backup if it doesn't exist
if [ ! -f "$BACKUP_FILE" ]; then
    echo "💾 Creating backup: azan_original_backup.mp3"
    cp "$ORIGINAL_FILE" "$BACKUP_FILE"
else
    echo "✅ Backup already exists: azan_original_backup.mp3"
fi
echo ""

# Compress the audio file
echo "🔧 Compressing audio file..."
echo "   Settings:"
echo "   - Bitrate: 96 kbps (good quality for voice)"
echo "   - Sample Rate: 44100 Hz"
echo "   - Channels: Mono (reduces size by 50%)"
echo ""

ffmpeg -i "$ORIGINAL_FILE" \
    -b:a 96k \
    -ar 44100 \
    -ac 1 \
    -y \
    "$COMPRESSED_FILE" \
    2>&1 | grep -v "^frame="

echo ""
echo "✅ Compression complete!"
echo ""

# Get compressed file size
COMPRESSED_SIZE=$(du -h "$COMPRESSED_FILE" | cut -f1)
echo "📊 Compressed file size: $COMPRESSED_SIZE"
echo ""

# Show size comparison
echo "📈 Size Comparison:"
ORIGINAL_BYTES=$(stat -f%z "$ORIGINAL_FILE" 2>/dev/null || stat -c%s "$ORIGINAL_FILE" 2>/dev/null)
COMPRESSED_BYTES=$(stat -f%z "$COMPRESSED_FILE" 2>/dev/null || stat -c%s "$COMPRESSED_FILE" 2>/dev/null)
REDUCTION=$((100 - (COMPRESSED_BYTES * 100 / ORIGINAL_BYTES)))
echo "   Original:   $ORIGINAL_SIZE"
echo "   Compressed: $COMPRESSED_SIZE"
echo "   Reduction:  ${REDUCTION}%"
echo ""

# Check if compressed file is under 1MB
if [ "$COMPRESSED_BYTES" -lt 1048576 ]; then
    echo "✅ Compressed file is under 1MB - Perfect for notifications!"
    echo ""
    
    # Ask to replace original
    echo "Would you like to replace the original file with the compressed version?"
    echo "The original will be kept as azan_original_backup.mp3"
    read -p "(y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv "$COMPRESSED_FILE" "$ORIGINAL_FILE"
        echo "✅ Original file replaced with compressed version"
        echo "💾 Original backup saved as: azan_original_backup.mp3"
    else
        echo "ℹ️  Compressed file saved as: azan_compressed.mp3"
        echo "   You can manually replace it later if needed"
    fi
else
    echo "⚠️  Warning: Compressed file is still over 1MB"
    echo "   Consider using a shorter version of the azan"
    echo "   Compressed file saved as: azan_compressed.mp3"
fi

echo ""
echo "🎧 Next Steps:"
echo "   1. Test the compressed audio to ensure quality is acceptable"
echo "   2. Rebuild the app: flutter clean && flutter build apk"
echo "   3. Test notification sound in the app"
echo ""
echo "📝 To restore original file:"
echo "   cp $BACKUP_FILE $ORIGINAL_FILE"
echo ""
echo "✨ Done!"
