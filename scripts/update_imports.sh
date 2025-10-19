#!/bin/bash

# Script to update import paths after folder restructuring
# This script updates imports from old folder names to new ones

echo "Updating import paths..."

# Update controller -> controllers
find lib -type f -name "*.dart" -exec sed -i '' 's/import.*controller\//import '\''package:qibla_compass_offline\/controllers\//g' {} +
find lib -type f -name "*.dart" -exec sed -i '' 's/from.*controller\//from '\''package:qibla_compass_offline\/controllers\//g' {} +

# Update view -> views
find lib -type f -name "*.dart" -exec sed -i '' 's/import.*view\//import '\''package:qibla_compass_offline\/views\//g' {} +
find lib -type f -name "*.dart" -exec sed -i '' 's/from.*view\//from '\''package:qibla_compass_offline\/views\//g' {} +

# Update widget -> widgets
find lib -type f -name "*.dart" -exec sed -i '' 's/import.*widget\//import '\''package:qibla_compass_offline\/widgets\//g' {} +
find lib -type f -name "*.dart" -exec sed -i '' 's/from.*widget\//from '\''package:qibla_compass_offline\/widgets\//g' {} +

# Update model -> models
find lib -type f -name "*.dart" -exec sed -i '' 's/import.*model\//import '\''package:qibla_compass_offline\/models\//g' {} +
find lib -type f -name "*.dart" -exec sed -i '' 's/from.*model\//from '\''package:qibla_compass_offline\/models\//g' {} +

echo "Import paths updated!"
echo "Running flutter pub get..."
flutter pub get

echo "Running flutter analyze..."
flutter analyze

echo "Done! Please review any remaining issues."
