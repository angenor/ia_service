import * as fal from '@fal-ai/client'
import { config } from '@/lib/config'

class FalService {
  constructor() {
    this.initializeClient()
  }

  initializeClient() {
    fal.config({
      credentials: config.fal.apiKey
    })
  }

  async generateImage({
    model = 'fal-ai/flux/schnell',
    prompt,
    imageSize = '1024x1024',
    numImages = 1,
    enableSafetyChecker = true
  }) {
    try {
      const result = await fal.subscribe(model, {
        input: {
          prompt,
          image_size: imageSize,
          num_images: numImages,
          enable_safety_checker: enableSafetyChecker
        },
        logs: true,
        onQueueUpdate: (update) => {
          if (update.status === 'IN_PROGRESS') {
            console.log('Génération en cours...', update)
          }
        }
      })

      return result
    } catch (error) {
      console.error('Erreur Fal AI:', error)
      throw new Error(`Erreur lors de la génération d'image: ${error.message}`)
    }
  }

  async upscaleImage({
    model = 'fal-ai/esrgan',
    imageUrl,
    scale = 4
  }) {
    try {
      const result = await fal.subscribe(model, {
        input: {
          image_url: imageUrl,
          scale
        }
      })

      return result
    } catch (error) {
      console.error('Erreur upscaling Fal AI:', error)
      throw new Error(`Erreur lors de l'upscaling: ${error.message}`)
    }
  }

  async generateVideo({
    model = 'fal-ai/runway-gen3/turbo/image-to-video',
    imageUrl,
    prompt,
    duration = 5
  }) {
    try {
      const result = await fal.subscribe(model, {
        input: {
          image_url: imageUrl,
          prompt,
          duration
        },
        logs: true,
        onQueueUpdate: (update) => {
          if (update.status === 'IN_PROGRESS') {
            console.log('Génération vidéo en cours...', update)
          }
        }
      })

      return result
    } catch (error) {
      console.error('Erreur génération vidéo Fal AI:', error)
      throw new Error(`Erreur lors de la génération vidéo: ${error.message}`)
    }
  }

  async removeBackground({
    model = 'fal-ai/birefnet',
    imageUrl
  }) {
    try {
      const result = await fal.subscribe(model, {
        input: {
          image_url: imageUrl
        }
      })

      return result
    } catch (error) {
      console.error('Erreur suppression arrière-plan Fal AI:', error)
      throw new Error(`Erreur lors de la suppression de l'arrière-plan: ${error.message}`)
    }
  }

  async transcribeAudio({
    model = 'fal-ai/whisper',
    audioUrl,
    language = 'fr'
  }) {
    try {
      const result = await fal.subscribe(model, {
        input: {
          audio_url: audioUrl,
          language,
          translate: false
        }
      })

      return result
    } catch (error) {
      console.error('Erreur transcription Fal AI:', error)
      throw new Error(`Erreur lors de la transcription: ${error.message}`)
    }
  }

  getAvailableModels() {
    return {
      imageGeneration: [
        {
          id: 'fal-ai/flux/schnell',
          name: 'FLUX Schnell',
          description: 'Génération rapide d\'images',
          category: 'text-to-image'
        },
        {
          id: 'fal-ai/flux/dev',
          name: 'FLUX Dev',
          description: 'Génération d\'images haute qualité',
          category: 'text-to-image'
        },
        {
          id: 'fal-ai/stable-diffusion-v35-large',
          name: 'Stable Diffusion 3.5 Large',
          description: 'Génération d\'images avec Stable Diffusion',
          category: 'text-to-image'
        }
      ],
      imageProcessing: [
        {
          id: 'fal-ai/esrgan',
          name: 'ESRGAN',
          description: 'Upscaling d\'images',
          category: 'image-upscaling'
        },
        {
          id: 'fal-ai/birefnet',
          name: 'BiRefNet',
          description: 'Suppression d\'arrière-plan',
          category: 'background-removal'
        }
      ],
      videoGeneration: [
        {
          id: 'fal-ai/runway-gen3/turbo/image-to-video',
          name: 'Runway Gen-3 Turbo',
          description: 'Génération de vidéos à partir d\'images',
          category: 'image-to-video'
        }
      ],
      audioProcessing: [
        {
          id: 'fal-ai/whisper',
          name: 'Whisper',
          description: 'Transcription audio',
          category: 'speech-to-text'
        }
      ]
    }
  }
}

export const falService = new FalService()
export default falService