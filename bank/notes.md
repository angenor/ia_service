Analyze codebase structure

De meme je veux ajouter les modèles DeepSeek V3 0324(https://openrouter.ai/deepseek/deepseek-chat-v3-0324:free); Qwen3 Coder(https://openrouter.ai/qwen/qwen3-coder:free); Chat GPT-4.5 Preview(https://openrouter.ai/openai/gpt-4.5-preview); GPT-4.1(https://openrouter.ai/openai/gpt-4.1); Llama 4 Maverick(https://openrouter.ai/meta-llama/llama-4-maverick). N'oublie pas d'ajouter les abilities correspondantes pour chaque modèle.


Il semble que LLMService n'utilise pas les informations de mes modèles dans la base de données.


N8N


Corps de la requête: {
  "model": "qwen/qwen3-coder:free",
  "messages": [
    {
      "role": "user",
      "content": "salut comment tu t'appel et quel est ton role"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 4096,
  "stream": false
}


problème Grok:
This endpoint's maximum context length is 256000 tokens. However, you requested about 256011 tokens (11 of text input, 256000 in the output). Please reduce the length of either one, or use the "middle-out" transform to compress your prompt automatically

je veux pouvoir téléverser les logos des modèles à partir de la page administration des modèles.