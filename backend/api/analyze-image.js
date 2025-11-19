const OpenAI = require('openai');
const { checkRateLimit } = require('./utils/rateLimiter');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

module.exports = async (req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, X-Device-Id');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  // Only allow POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Check rate limit
  if (!checkRateLimit(req, res)) {
    return;
  }

  try {
    const { image } = req.body;

    if (!image) {
      return res.status(400).json({ error: 'No image provided' });
    }

    // Validate base64 image format
    if (!image.startsWith('data:image/')) {
      return res.status(400).json({ error: 'Invalid image format. Expected base64 data URL' });
    }

    console.log('Analyzing image with GPT-4 Vision...');

    // Call OpenAI GPT-4 Vision API
    const response = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: 'Describe this image in detail. Focus on the main subjects, their appearance, setting, and mood. Be specific and descriptive.'
            },
            {
              type: 'image_url',
              image_url: {
                url: image
              }
            }
          ]
        }
      ],
      max_tokens: 500
    });

    const description = response.choices[0].message.content;

    console.log('Image analysis complete');

    return res.status(200).json({
      success: true,
      description
    });

  } catch (error) {
    console.error('Error analyzing image:', error);

    // Handle specific OpenAI errors
    if (error.status === 401) {
      return res.status(500).json({ error: 'Server configuration error' });
    }

    if (error.status === 429) {
      return res.status(503).json({ error: 'Service temporarily unavailable. Please try again later.' });
    }

    return res.status(500).json({
      error: 'Failed to analyze image',
      message: error.message || 'An unexpected error occurred'
    });
  }
};
