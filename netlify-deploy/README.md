# EC Saver Landing Page - Netlify Deployment

This folder contains all files needed to deploy the EC Saver landing page to Netlify.

## 📁 Files Included

- `index.html` - Main landing page
- `assets/image/logo.png` - App logo
- `assets/image/landpagebackground.jpg` - Background image
- `netlify.toml` - Netlify configuration
- `_headers` - HTTP headers for security and caching

## 🚀 Deployment Methods

### Method 1: Netlify Dashboard (Easiest)

1. Go to [https://app.netlify.com](https://app.netlify.com)
2. Sign in or create an account
3. Click **"Add new site"** → **"Deploy manually"**
4. Drag and drop this entire `netlify-deploy` folder
5. Wait for deployment (~30 seconds)
6. Your site is live! 🎉

### Method 2: Netlify CLI

```bash
# Install Netlify CLI (if not installed)
npm install -g netlify-cli

# Navigate to deployment folder
cd netlify-deploy

# Login to Netlify
netlify login

# Deploy to production
netlify deploy --prod
```

### Method 3: Git Integration

1. Push this folder to a Git repository
2. Go to Netlify Dashboard
3. Click **"Add new site"** → **"Import an existing project"**
4. Connect your Git repository
5. Set build settings:
   - **Base directory:** `netlify-deploy`
   - **Publish directory:** `netlify-deploy`
   - **Build command:** (leave empty - static site)
6. Click **"Deploy site"**

## ⚙️ Configuration

### Custom Domain

After deployment:
1. Go to **Site settings** → **Domain management**
2. Click **"Add custom domain"**
3. Follow the instructions to configure DNS

### Environment Variables

If needed, add environment variables in:
- **Site settings** → **Environment variables**

## 🔧 Features

- ✅ Automatic HTTPS
- ✅ CDN distribution
- ✅ Custom headers for security
- ✅ Cache optimization
- ✅ SPA redirects (all routes → index.html)

## 📝 Notes

- The landing page fetches the latest APK from GitHub releases
- No build process required - pure static HTML/CSS/JS
- All assets are included in this folder
- The site will automatically update when you push new releases to GitHub

## 🔗 Useful Links

- [Netlify Documentation](https://docs.netlify.com/)
- [Netlify Status](https://www.netlifystatus.com/)
- [EC Saver GitHub](https://github.com/Rehancodecraft/EC-Saver)

