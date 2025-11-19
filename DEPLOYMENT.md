# Deployment Guide - Pixar Style Converter

This guide will walk you through deploying the backend API to Vercel and updating your iOS app to use it.

## Prerequisites

- OpenAI API key (with GPT-4 and DALL-E 3 access)
- Vercel account (free tier works)
- Node.js 18+ installed
- Xcode installed

---

## Part 1: Deploy Backend to Vercel

### Step 1: Install Vercel CLI

```bash
npm install -g vercel
```

### Step 2: Navigate to Backend Directory

```bash
cd backend
```

### Step 3: Install Dependencies

```bash
npm install
```

### Step 4: Login to Vercel

```bash
vercel login
```

Follow the prompts to authenticate.

### Step 5: Deploy to Vercel

```bash
vercel --prod
```

You'll be asked:
- **Set up and deploy?** → Yes
- **Which scope?** → Select your account
- **Link to existing project?** → No
- **Project name?** → `pixar-converter-backend` (or your choice)
- **Directory?** → `.` (current directory)
- **Override settings?** → No

Vercel will deploy and give you a URL like: `https://pixar-converter-backend.vercel.app`

**SAVE THIS URL** - you'll need it for the iOS app!

### Step 6: Add OpenAI API Key to Vercel

1. Go to https://vercel.com/dashboard
2. Click on your project (`pixar-converter-backend`)
3. Go to **Settings** → **Environment Variables**
4. Add a new variable:
   - **Key**: `OPENAI_API_KEY`
   - **Value**: Your OpenAI API key (starts with `sk-proj-...`)
   - **Environments**: Check all (Production, Preview, Development)
5. Click **Save**

### Step 7: Redeploy (to apply environment variable)

```bash
vercel --prod
```

### Step 8: Test Your Backend

Test the endpoints are working:

```bash
curl https://your-app.vercel.app/api/analyze-image
```

You should get a 405 error (Method not allowed) - this is expected for a GET request. It means the endpoint is live!

---

## Part 2: Update iOS App

### Step 1: Update Backend URL

Open `reed-test/Services/BackendService.swift` in Xcode.

Find this line (around line 31):
```swift
private let baseURL = "http://localhost:3000"
```

Replace with your Vercel URL:
```swift
private let baseURL = "https://your-app.vercel.app"
```

**Important:** Do NOT include `/api` at the end!

### Step 2: Rebuild the App

1. Open `reed-test.xcodeproj` in Xcode
2. Select your target device/simulator
3. Press ⌘R to build and run

### Step 3: Test the App

1. Tap "Select Image from Library"
2. Choose a test image
3. Tap "Convert to Pixar Style"
4. Wait 20-40 seconds for the conversion
5. You should see your Pixar-style result!

---

## Troubleshooting

### Backend Issues

**"Server configuration error"**
- Your OpenAI API key isn't set in Vercel
- Go to Vercel dashboard → Settings → Environment Variables
- Add `OPENAI_API_KEY`

**"Service temporarily unavailable"**
- OpenAI rate limit reached (too many requests)
- Check your OpenAI usage at https://platform.openai.com/usage
- Make sure you have credits/billing set up

**"Rate limit exceeded"**
- You've made 10+ requests in an hour
- Wait an hour or modify rate limits in `backend/api/utils/rateLimiter.js`

### iOS App Issues

**"Failed to analyze image"**
- Check that `baseURL` is set correctly in `BackendService.swift`
- Make sure you're using HTTPS (not HTTP) for the Vercel URL
- Check Xcode console for detailed error messages

**App crashes when selecting image**
- Make sure photo library permissions are set (they should be)
- Check iOS Settings → Privacy → Photos → reed-test

---

## Rate Limiting Configuration

Default limits (per device/IP):
- **10 requests per hour**

To change limits, edit `backend/api/utils/rateLimiter.js`:

```javascript
const RATE_LIMIT = {
  windowMs: 60 * 60 * 1000,  // 1 hour (change this)
  maxRequests: 10             // 10 requests (change this)
};
```

Then redeploy:
```bash
cd backend
vercel --prod
```

---

## Cost Monitoring

Your app uses OpenAI's paid APIs:
- **GPT-4o**: ~$0.005 per image analysis
- **DALL-E 3**: ~$0.04 per image generation
- **Total**: ~$0.045 per conversion

Monitor costs at: https://platform.openai.com/usage

To prevent unexpected charges:
1. Set usage limits in OpenAI dashboard
2. Implement stricter rate limiting
3. Add user authentication

---

## Next Steps (Optional)

### Add User Authentication
- Implement Firebase Auth or similar
- Protect API endpoints with authentication tokens
- Track usage per user

### Improve Rate Limiting
- Use Redis or Vercel KV for distributed rate limiting
- Implement different tiers (free vs paid users)

### Add Analytics
- Track conversions, errors, popular images
- Monitor API costs per request

### Enhance Security
- Add request signature verification
- Implement CAPTCHA for abuse prevention
- Set up API key rotation

---

## Support

If you encounter issues:
1. Check Xcode console logs (⌘⇧Y)
2. Check Vercel function logs (Dashboard → Functions → Logs)
3. Verify OpenAI API key has proper permissions
4. Ensure billing is set up on OpenAI account
