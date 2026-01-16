# GitHub Pages Setup for app-ads.txt

This directory hosts the app-ads.txt file for AdMob verification.

## URLs:

- **app-ads.txt**: `https://gul-is-here.github.io/Qibla-Finder/app-ads.txt`
- **Website**: `https://gul-is-here.github.io/Qibla-Finder/`

## Setup Instructions:

### 1. Enable GitHub Pages

1. Go to your repository: https://github.com/Gul-Is-Here/Qibla-Finder
2. Click **Settings** (gear icon)
3. Scroll down to **Pages** in the left sidebar
4. Under **Source**, select:
   - Branch: `main`
   - Folder: `/docs`
5. Click **Save**
6. Wait 2-3 minutes for deployment

### 2. Verify app-ads.txt

Once GitHub Pages is enabled, verify your file is accessible:

```
https://gul-is-here.github.io/Qibla-Finder/app-ads.txt
```

### 3. Add to AdMob Console

1. Go to [AdMob Console](https://apps.admob.com)
2. Navigate to **Apps** → Your App
3. Under **App Settings** → **app-ads.txt**
4. Add this URL:
   ```
   https://gul-is-here.github.io/Qibla-Finder/app-ads.txt
   ```

### 4. Add to Play Store Listing

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to **Store presence** → **Store listing**
4. Under **Website** field, add:
   ```
   https://gul-is-here.github.io/Qibla-Finder
   ```
5. Save changes

## Content of app-ads.txt:

```
google.com, pub-2744970719381152, DIRECT, f08c47fec0942fa0
```

## Why app-ads.txt?

- Protects against ad fraud
- Increases ad revenue by improving advertiser confidence
- Required by Google AdMob for optimal performance
- Helps prevent unauthorized inventory from being sold

## Verification Timeline:

- GitHub Pages deployment: 2-3 minutes
- AdMob verification: 24-48 hours
- Full propagation: Up to 7 days

## Troubleshooting:

If app-ads.txt is not accessible:

1. Check if GitHub Pages is enabled in repository settings
2. Ensure the `/docs` folder is selected as source
3. Wait a few minutes for deployment
4. Try accessing in incognito mode (to avoid cache)
5. Check file content has no extra spaces or formatting

## Notes:

- Do NOT add `www.` to the GitHub Pages URL
- The URL is case-sensitive
- The file MUST be named exactly `app-ads.txt` (lowercase)
- The file MUST be at the root of your domain (achieved via GitHub Pages)
