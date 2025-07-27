<template>
  <div class="space-y-6">
    <!-- Service Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      
      <!-- Video Generation Card -->
      <div class="bg-gray-100 dark:bg-gray-800 rounded-xl p-6 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors cursor-pointer">
        <div class="flex items-center justify-center w-16 h-16 bg-gray-300 dark:bg-gray-600 rounded-lg mb-4 mx-auto">
          <font-awesome-icon icon="video" class="text-2xl text-gray-600 dark:text-gray-300" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2 text-center">{{ $t('services.videoGeneration.title') }}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4 text-center">{{ $t('services.videoGeneration.description') }}</p>
        <div class="text-xs text-gray-500 dark:text-gray-500 space-y-1">
          <div><strong>{{ $t('services.providers') }}:</strong></div>
          <div>{{ $t('services.videoGeneration.providers') }}</div>
        </div>
      </div>

      <!-- ChatBot LLM Card -->
      <div class="bg-gray-100 dark:bg-gray-800 rounded-xl p-6 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors cursor-pointer">
        <div class="flex items-center justify-center space-x-2 mb-4">
          <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
            <div class="w-4 h-4 bg-white rounded-full"></div>
          </div>
          <div class="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center">
            <font-awesome-icon icon="star" class="text-white text-xs" />
          </div>
          <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
            <div class="w-3 h-3 bg-white transform rotate-45"></div>
          </div>
          <div class="w-8 h-8 bg-gray-500 rounded-full flex items-center justify-center">
            <span class="text-white text-xs">•••</span>
          </div>
        </div>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2 text-center">{{ $t('services.chatBot.title') }}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4 text-center">{{ $t('services.chatBot.description') }}</p>
        <div class="text-xs text-gray-500 dark:text-gray-500 space-y-1">
          <div><strong>{{ $t('services.providers') }}:</strong></div>
          <div>{{ $t('services.chatBot.providers') }}</div>
        </div>
      </div>

      <!-- Image Generation Card -->
      <div class="bg-gray-100 dark:bg-gray-800 rounded-xl p-6 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors cursor-pointer">
        <div class="flex items-center justify-center w-16 h-16 bg-gradient-to-br from-purple-400 to-pink-400 rounded-lg mb-4 mx-auto">
          <font-awesome-icon icon="image" class="text-2xl text-white" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2 text-center">{{ $t('services.imageGeneration.title') }}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4 text-center">{{ $t('services.imageGeneration.description') }}</p>
        <div class="text-xs text-gray-500 dark:text-gray-500 space-y-1">
          <div><strong>{{ $t('services.providers') }}:</strong></div>
          <div>{{ $t('services.imageGeneration.providers') }}</div>
        </div>
      </div>

      <!-- Text to Audio Card -->
      <div class="bg-gray-100 dark:bg-gray-800 rounded-xl p-6 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors cursor-pointer">
        <div class="flex items-center justify-center w-16 h-16 bg-blue-500 rounded-lg mb-4 mx-auto">
          <div class="flex items-center space-x-1">
            <div class="w-4 h-4 bg-white rounded"></div>
            <font-awesome-icon icon="arrow-right" class="text-white text-xs" />
            <font-awesome-icon icon="volume-up" class="text-white text-sm" />
          </div>
        </div>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2 text-center">{{ $t('services.textToAudio.title') }}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4 text-center">{{ $t('services.textToAudio.description') }}</p>
        <div class="text-xs text-gray-500 dark:text-gray-500 space-y-1">
          <div><strong>{{ $t('services.providers') }}:</strong></div>
          <div>{{ $t('services.textToAudio.providers') }}</div>
        </div>
      </div>

      <!-- Audio to Text Card -->
      <div class="bg-gray-100 dark:bg-gray-800 rounded-xl p-6 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors cursor-pointer">
        <div class="flex items-center justify-center w-16 h-16 bg-blue-400 rounded-lg mb-4 mx-auto">
          <div class="flex items-center space-x-1">
            <font-awesome-icon icon="microphone" class="text-white text-sm" />
            <font-awesome-icon icon="arrow-right" class="text-white text-xs" />
            <div class="w-4 h-4 bg-white rounded"></div>
          </div>
        </div>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2 text-center">{{ $t('services.audioToText.title') }}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4 text-center">{{ $t('services.audioToText.description') }}</p>
        <div class="text-xs text-gray-500 dark:text-gray-500 space-y-1">
          <div><strong>{{ $t('services.providers') }}:</strong></div>
          <div>{{ $t('services.audioToText.providers') }}</div>
        </div>
      </div>

      <!-- Agent Card -->
      <div class="bg-gray-100 dark:bg-gray-800 rounded-xl p-6 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors cursor-pointer">
        <div class="flex items-center justify-center w-16 h-16 bg-orange-500 rounded-full mb-4 mx-auto">
          <font-awesome-icon icon="user" class="text-2xl text-white" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2 text-center">{{ $t('services.agent.title') }}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4 text-center">{{ $t('services.agent.description') }}</p>
        <div class="text-xs text-gray-500 dark:text-gray-500 space-y-1">
          <div><strong>{{ $t('services.providers') }}:</strong></div>
          <div>{{ $t('services.agent.providers') }}</div>
        </div>
      </div>

    </div>

    <!-- Input Section -->
    <div class="max-w-4xl mx-auto">
      <div class="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 p-6">
        <!-- Add Button -->
        <div class="flex items-center mb-4">
          <button class="w-10 h-10 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-full flex items-center justify-center hover:border-gray-400 dark:hover:border-gray-500 transition-colors">
            <font-awesome-icon icon="plus" class="text-gray-400" />
          </button>
        </div>

        <!-- Main Input -->
        <div class="mb-4">
          <textarea 
            :placeholder="$t('input.placeholder')"
            class="w-full p-4 border-0 resize-none text-lg bg-transparent text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-0"
            rows="3"
          ></textarea>
        </div>

        <!-- Options and Generate Button -->
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-3">
            <span class="text-sm text-gray-600 dark:text-gray-400">{{ $t('input.otherOptions') }}</span>
            
            <!-- Option Buttons -->
            <button class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-full text-sm hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors">
              16:9 ∨
            </button>
            <button class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-full text-sm hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors">
              Gemini ∨
            </button>
            <button class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-full text-sm hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors">
              etc...
            </button>
          </div>

          <!-- Generate Button -->
          <button class="px-8 py-2 bg-green-500 hover:bg-green-600 text-white rounded-full font-medium transition-colors">
            {{ $t('input.generate') }} (200)
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>
