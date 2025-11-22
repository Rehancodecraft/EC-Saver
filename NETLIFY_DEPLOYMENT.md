# 🚀 Deploy Landing Page to Netlify

## ✅ What You Need

You only need these files (NOT the full repository):
- `index.html` - The landing page
- `assets/image/` folder - Contains logo and background images

## 📁 Files Required

```
landing-page/
├── index.html
└── assets/
    └── image/
        ├── logo.png
        └── landpagebackground.jpg
```

## 🎯 Option 1: Deploy via Netlify UI (Easiest)

### Step 1: Create Deployment Folder

```bash
cd /home/rehan/EC-Saver

# Create a folder for Netlify deployment
mkdir -p netlify-deploy
cp index.html netlify-deploy/
cp -r assets netlify-deploy/

# Verify structure
ls -la netlify-deploy/
ls -la netlify-deploy/assets/image/
```

### Step 2: Deploy to Netlify

1. **Go to Netlify**: https://app.netlify.com
2. **Click "Add new site"** → **"Deploy manually"**
3. **Drag and drop** the `netlify-deploy` folder
4. **Wait for deployment** (takes ~30 seconds)
5. **Done!** Your site is live

### Step 3: Customize Domain (Optional)

1. Click on your site
2. Go to **"Domain settings"**
3. Click **"Add custom domain"**
4. Enter your domain (e.g., `ec-saver.com`)
5. Follow DNS setup instructions

---

## 🎯 Option 2: Deploy via Git (Recommended for Updates)

### Step 1: Create a Separate Branch or Repository

**Option A: Create a `gh-pages` branch (GitHub Pages style)**
```bash
cd /home/rehan/EC-Saver
git checkout -b gh-pages
git add index.html assets/
git commit -m "Add landing page for Netlify"
git push origin gh-pages
```

**Option B: Create a separate repository (Cleaner)**
```bash
# Create new repo for landing page only
mkdir ec-saver-landing
cd ec-saver-landing
git init
cp ../EC-Saver/index.html .
cp -r ../EC-Saver/assets .
git add .
git commit -m "Initial landing page"
git remote add origin https://github.com/Rehancodecraft/ec-saver-landing.git
git push -u origin main
```

### Step 2: Connect to Netlify

1. **Go to Netlify**: https://app.netlify.com
2. **Click "Add new site"** → **"Import an existing project"**
3. **Choose Git provider** (GitHub/GitLab/Bitbucket)
4. **Select repository**: `EC-Saver` (or `ec-saver-landing`)
5. **Build settings**:
   - **Branch**: `gh-pages` (or `main`)
   - **Publish directory**: `/` (root)
   - **Build command**: (leave empty - no build needed)
6. **Click "Deploy site"**

### Step 3: Auto-Deploy on Updates

- Every time you push to the branch, Netlify will auto-deploy
- Updates are instant!

---

## 🎯 Option 3: Deploy via Netlify CLI

### Step 1: Install Netlify CLI

```bash
npm install -g netlify-cli
```

### Step 2: Login

```bash
netlify login
```

### Step 3: Deploy

```bash
cd /home/rehan/EC-Saver

# Create deployment folder
mkdir -p netlify-deploy
cp index.html netlify-deploy/
cp -r assets netlify-deploy/

# Deploy
cd netlify-deploy
netlify deploy --prod
```

---

## 📋 Quick Setup Script

I'll create a script to prepare files for Netlify:

```bash
# Run this script to prepare files
./prepare_netlify.sh
```

---

## ✅ What Gets Deployed

- ✅ `index.html` - Landing page
- ✅ `assets/image/logo.png` - App logo
- ✅ `assets/image/landpagebackground.jpg` - Background image

## ❌ What Doesn't Get Deployed

- ❌ Flutter code (`lib/` folder)
- ❌ Android code (`android/` folder)
- ❌ iOS code (`ios/` folder)
- ❌ Build files
- ❌ Any other project files

---

## 🔧 Netlify Configuration (Optional)

Create `netlify.toml` in your deployment folder:

```toml
[build]
  publish = "."

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[build.environment]
  NODE_VERSION = "18"
```

---

## 🚀 After Deployment

1. **Test the site**: Open the Netlify URL
2. **Check version**: Should show latest version (v1.1.2)
3. **Test download**: Click download button
4. **Verify mobile**: Test on mobile device

---

## 📱 Custom Domain Setup

1. In Netlify dashboard → **Domain settings**
2. Click **"Add custom domain"**
3. Enter domain (e.g., `ec-saver.com`)
4. Update DNS records:
   - **A Record**: Point to Netlify IP
   - **CNAME**: Point to your Netlify site
5. Wait for DNS propagation (5-30 minutes)

---

## 🔄 Updating Landing Page

### If using Manual Deploy:
1. Update `index.html` locally
2. Drag and drop folder again to Netlify

### If using Git:
1. Update `index.html` in repository
2. Push to branch
3. Netlify auto-deploys

---

## ✅ Benefits of Netlify

- ✅ **Free hosting** (generous free tier)
- ✅ **HTTPS** (automatic SSL)
- ✅ **CDN** (fast global delivery)
- ✅ **Auto-deploy** (from Git)
- ✅ **Custom domains** (free)
- ✅ **Easy updates** (just push to Git)

---

**Ready to deploy?** Use Option 1 for quickest setup, or Option 2 for automatic updates!

