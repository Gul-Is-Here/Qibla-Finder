# App-ads.txt Setup Guide for Qibla Compass

## 🔍 **What is app-ads.txt?**

App-ads.txt is a text file that helps prevent ad fraud by publicly declaring which companies are authorized to sell your app's ad inventory. It's required by Google AdMob for verification.

## 📋 **Your app-ads.txt Content**

Based on your AdMob publisher ID `pub-2744970719381152`, create a file named `app-ads.txt` with the following content:

```
google.com, pub-2744970719381152, DIRECT, f08c47fec0942fa0
```

## 🌐 **Where to Place app-ads.txt**

### Option 1: Developer Website (Recommended)
If you have a developer website (like `yourdomain.com`), place the `app-ads.txt` file at:
```
https://yourdomain.com/app-ads.txt
```

### Option 2: GitHub Pages (Free Alternative)
If you don't have a website, you can use GitHub Pages:

1. Create a new repository on GitHub
2. Create an `app-ads.txt` file with the content above
3. Enable GitHub Pages in repository settings
4. Your file will be available at: `https://yourusername.github.io/repositoryname/app-ads.txt`

### Option 3: Firebase Hosting (Free Alternative)
You can also use Firebase Hosting:

1. Initialize Firebase Hosting in a folder
2. Create `app-ads.txt` in the public folder
3. Deploy with `firebase deploy`

## 🔧 **Step-by-Step Instructions**

### Method 1: Using GitHub Pages (Easiest for beginners)

1. **Create a GitHub Repository**
   - Go to [GitHub](https://github.com)
   - Click "New repository"
   - Name it something like "qibla-compass-ads"
   - Make it public
   - Initialize with README

2. **Create app-ads.txt File**
   - Click "Add file" → "Create new file"
   - Name it `app-ads.txt`
   - Paste this content:
   ```
   google.com, pub-2744970719381152, DIRECT, f08c47fec0942fa0
   ```
   - Commit the file

3. **Enable GitHub Pages**
   - Go to repository Settings
   - Scroll to "Pages" section
   - Source: Deploy from a branch
   - Branch: main
   - Folder: / (root)
   - Click Save

4. **Verify Your File**
   - Wait 5-10 minutes
   - Visit: `https://yourusername.github.io/qibla-compass-ads/app-ads.txt`
   - You should see your app-ads.txt content

5. **Update App Store Listing**
   - Go to Google Play Console
   - Find your app's "Developer website" field
   - Enter: `https://yourusername.github.io/qibla-compass-ads`
   - Save changes

### Method 2: Using Your Own Domain

If you have your own website:

1. **Create the File**
   - Create `app-ads.txt` with the content above
   - Upload to your website's root directory

2. **Verify Access**
   - Visit: `https://yourdomain.com/app-ads.txt`
   - Ensure it's accessible and shows the correct content

3. **Update App Store Listing**
   - Ensure your domain matches exactly what's in Google Play Store

## ✅ **Verification Steps**

1. **Test File Access**
   - Open your app-ads.txt URL in a browser
   - Verify content is correct and accessible

2. **AdMob Verification**
   - Go to AdMob console
   - Navigate to your app
   - Click "Verify" for app-ads.txt
   - Wait for verification (can take 24-48 hours)

3. **Common Issues to Check**
   - File is at root level (not in subfolder)
   - Content is exactly as specified (no extra spaces/characters)
   - Domain in app store matches domain hosting the file
   - File is publicly accessible (not behind login)

## ⚠️ **Important Notes**

1. **Exact Domain Match**: The domain in your app store listing must exactly match where the app-ads.txt is hosted

2. **Case Sensitive**: File name must be exactly `app-ads.txt` (lowercase)

3. **No HTML**: The file should be plain text, not HTML

4. **Verification Time**: AdMob verification can take 24-48 hours

5. **Update App Store**: Make sure to update your developer website URL in Google Play Console

## 🔍 **Your Complete Checklist**

- [ ] Create `app-ads.txt` file with correct content
- [ ] Upload to website root or GitHub Pages
- [ ] Verify file is accessible via browser
- [ ] Update developer website URL in app store
- [ ] Wait for AdMob verification
- [ ] Update Ad Unit IDs in your app code
- [ ] Test ads in your app

## 📞 **If You Need Help**

If you're still having issues:

1. **Check File Format**: Ensure it's plain text, not Word doc or PDF
2. **Check URL**: Make sure the file is accessible publicly
3. **Domain Match**: Verify app store domain matches hosting domain
4. **Wait Time**: AdMob verification isn't instant

Your publisher ID: `pub-2744970719381152`
Required content: `google.com, pub-2744970719381152, DIRECT, f08c47fec0942fa0`