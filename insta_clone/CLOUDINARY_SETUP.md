# Cloudinary Setup Guide

## Step 1: Create a Cloudinary Account (FREE!)

1. Go to **https://cloudinary.com/users/register/free**
2. Sign up with your email (free tier is unlimited for hobbyist projects)
3. Verify your email

## Step 2: Get Your Cloudinary Credentials

After signing up, you'll see your **Dashboard**.

### Find Your Cloud Name:
- On the Dashboard, look for **"Cloud name"** 
- It's a unique identifier like `d1a2b3c4d` or similar
- Copy it

### Create an Upload Preset (for unsigned uploads):

1. Go to **Settings** (gear icon) → **Upload**
2. Scroll down to **"Upload presets"** section
3. Click **"Add upload preset"** (if not already there)
4. Set:
   - **Name**: `insta_clone_preset` (or any name)
   - **Signing Mode**: **Unsigned** (important for free tier)
   - **Folder**: `insta_clone` (optional, organizes uploads)
   - Click **Save**
5. Copy the preset name

### Get Your API Key (optional, for connection testing):
1. Go to **Settings** → **Security**
2. Scroll to find **"API Key"**
3. Copy it (you might not need it for basic uploads)

## Step 3: Update Your Flutter App

Open `lib/services/cloudinary_upload_service.dart` and replace these lines:

```dart
static const String CLOUD_NAME = 'YOUR_CLOUDINARY_CLOUD_NAME';
static const String UPLOAD_PRESET = 'YOUR_UPLOAD_PRESET'; 
static const String API_KEY = 'YOUR_CLOUDINARY_API_KEY';
```

With your actual credentials:

```dart
static const String CLOUD_NAME = 'd1a2b3c4d'; // Your actual cloud name
static const String UPLOAD_PRESET = 'insta_clone_preset'; // Your preset name
static const String API_KEY = 'your_api_key_here'; // Your API key
```

## Step 4: Update Dependencies

Run this in your terminal:

```bash
cd d:\sm app2\insta_clone
flutter pub get
```

## Step 5: Test the Connection

1. Run your app on the Android device
2. Go to the upload screen (+ button)
3. Tap **"Test Cloudinary Connection"** button
4. Check the console logs for success/error messages

## Step 6: Upload Your First Image

1. Select an image
2. Add a caption
3. Tap **"Post"**
4. Check the console for upload progress
5. Image should now appear in your Cloudinary dashboard!

## ✅ What You Get with FREE Cloudinary:

- **Unlimited uploads** (up to 25GB storage)
- **Unlimited bandwidth**
- **Image transformation** (resize, crop, optimize)
- **CDN delivery** (fast image loading)
- **10GB storage** (very generous for free)

## 🐛 Troubleshooting

### "Cloudinary credentials not configured"
- Make sure you replaced the placeholder values with your actual credentials

### Upload fails with 401 error
- Double-check your CLOUD_NAME and UPLOAD_PRESET
- Make sure the preset is set to **"Unsigned"** mode

### Upload starts but takes forever
- Check your internet connection
- Large images might take time, resize them first

### Images don't appear in Firestore
- Make sure you're logged in with Firebase Authentication first
- Check that the upload completed (look at console logs)

## 📚 Useful Resources

- **Cloudinary Dashboard**: https://cloudinary.com/console
- **API Documentation**: https://cloudinary.com/documentation/image_upload_api_reference
- **Flutter Cloudinary Package**: https://pub.dev/packages/cloudinary_flutter

## 💡 Pro Tips

- Use Cloudinary's **Transformations** to automatically resize/optimize images
- Set up **Named transformation** in Cloudinary for profile pictures
- Monitor your **"Usage"** page to see storage/bandwidth usage
- Upload presets can have different settings (quality, format, etc.)
