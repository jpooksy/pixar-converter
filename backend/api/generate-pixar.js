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
    const { description } = req.body;

    if (!description) {
      return res.status(400).json({ error: 'No description provided' });
    }

    console.log('Generating Pixar-style image with DALL-E 3...');

    // Create Pixar-style prompt
    const pixarPrompt = `Create an image in Pixar animation style with the following description:
${description}

Use vibrant colors, expressive characters, and the distinctive Pixar 3D animated aesthetic.`;

    // Call OpenAI DALL-E 3 API
    const response = await openai.images.generate({
      model: 'dall-e-3',
      prompt: pixarPrompt,
      n: 1,
      size: '1024x1024',
      quality: 'standard'
    });

    const imageUrl = response.data[0].url;

    console.log('Pixar-style image generated successfully');

    return res.status(200).json({
      success: true,
      imageUrl
    });

  } catch (error) {
    console.error('Error generating Pixar image:', error);

    // Handle specific OpenAI errors
    if (error.status === 401) {
      return res.status(500).json({ error: 'Server configuration error' });
    }

    if (error.status === 429) {
      return res.status(503).json({ error: 'Service temporarily unavailable. Please try again later.' });
    }

    if (error.status === 400 && error.message?.includes('content_policy_violation')) {
      return res.status(400).json({ error: 'Image content violates OpenAI content policy. Please try a different image.' });
    }

    return res.status(500).json({
      error: 'Failed to generate Pixar image',
      message: error.message || 'An unexpected error occurred'
    });
  }
};
