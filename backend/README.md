# Pixar Converter Backend API

Backend API for the Pixar Style Image Converter iOS app.

## Tech Stack
- **Runtime**: Node.js 18+
- **Hosting**: Vercel Serverless Functions
- **API**: OpenAI GPT-4 Vision + DALL-E 3

## Local Development

### Prerequisites
- Node.js 18 or higher
- Vercel CLI: `npm install -g vercel`
- OpenAI API key

### Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env.local` file:
```bash
cp .env.example .env.local
```

3. Add your OpenAI API key to `.env.local`:
```
OPENAI_API_KEY=sk-proj-your-key-here
```

4. Run local development server:
```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## API Endpoints

### POST /api/analyze-image
Analyzes an image using GPT-4 Vision.

**Request:**
```json
{
  "image": "data:image/jpeg;base64,..."
}
```

**Response:**
```json
{
  "success": true,
  "description": "A detailed description of the image..."
}
```

### POST /api/generate-pixar
Generates a Pixar-style image using DALL-E 3.

**Request:**
```json
{
  "description": "A detailed image description..."
}
```

**Response:**
```json
{
  "success": true,
  "imageUrl": "https://..."
}
```

## Rate Limiting
- 10 requests per hour per device/IP
- Tracks by `X-Device-Id` header or IP address

## Deployment to Vercel

### First Time Setup

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Login to Vercel:
```bash
vercel login
```

3. Deploy:
```bash
npm run deploy
```

4. Set environment variable in Vercel dashboard:
   - Go to your project settings
   - Navigate to "Environment Variables"
   - Add `OPENAI_API_KEY` with your OpenAI API key

### Subsequent Deployments
```bash
npm run deploy
```

## Project Structure
```
backend/
├── api/
│   ├── analyze-image.js      # GPT-4 Vision endpoint
│   ├── generate-pixar.js     # DALL-E 3 endpoint
│   └── utils/
│       └── rateLimiter.js    # Rate limiting utility
├── package.json
├── vercel.json               # Vercel configuration
└── README.md
```

## Security Notes
- API key is stored as environment variable (never in code)
- Rate limiting prevents abuse
- CORS enabled for iOS app access
- Consider adding authentication for production use
