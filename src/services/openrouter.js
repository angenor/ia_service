import OpenAI from 'openai'
import { config } from '@/lib/config'

class OpenRouterService {
  constructor() {
    this.client = new OpenAI({
      baseURL: config.openrouter.baseUrl,
      apiKey: config.openrouter.apiKey,
      dangerouslyAllowBrowser: true
    })
  }

  async generateCompletion({
    model = 'meta-llama/llama-3.1-8b-instruct:free',
    messages,
    temperature = 0.7,
    maxTokens = 1000,
    stream = false
  }) {
    try {
      const response = await this.client.chat.completions.create({
        model,
        messages,
        temperature,
        max_tokens: maxTokens,
        stream
      })

      return response
    } catch (error) {
      console.error('Erreur OpenRouter:', error)
      throw new Error(`Erreur lors de la génération: ${error.message}`)
    }
  }

  async streamCompletion({
    model = 'meta-llama/llama-3.1-8b-instruct:free',
    messages,
    temperature = 0.7,
    maxTokens = 1000,
    onChunk
  }) {
    try {
      const stream = await this.client.chat.completions.create({
        model,
        messages,
        temperature,
        max_tokens: maxTokens,
        stream: true
      })

      for await (const chunk of stream) {
        const content = chunk.choices[0]?.delta?.content
        if (content && onChunk) {
          onChunk(content)
        }
      }
    } catch (error) {
      console.error('Erreur streaming OpenRouter:', error)
      throw new Error(`Erreur lors du streaming: ${error.message}`)
    }
  }

  getAvailableModels() {
    return [
      {
        id: 'meta-llama/llama-3.1-8b-instruct:free',
        name: 'Llama 3.1 8B Instruct (Free)',
        provider: 'Meta',
        contextLength: 131072
      },
      {
        id: 'openai/gpt-3.5-turbo',
        name: 'GPT-3.5 Turbo',
        provider: 'OpenAI',
        contextLength: 16385
      },
      {
        id: 'openai/gpt-4',
        name: 'GPT-4',
        provider: 'OpenAI',
        contextLength: 8192
      },
      {
        id: 'anthropic/claude-3-haiku',
        name: 'Claude 3 Haiku',
        provider: 'Anthropic',
        contextLength: 200000
      },
      {
        id: 'anthropic/claude-3-sonnet',
        name: 'Claude 3 Sonnet',
        provider: 'Anthropic',
        contextLength: 200000
      },
      {
        id: 'google/gemini-pro',
        name: 'Gemini Pro',
        provider: 'Google',
        contextLength: 32768
      }
    ]
  }
}

export const openRouterService = new OpenRouterService()
export default openRouterService