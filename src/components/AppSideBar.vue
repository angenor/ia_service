<template>
  <aside class="fixed left-0 top-0 h-screen w-64 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-700 flex flex-col">
    <!-- Header -->
    <div class="p-4 border-b border-gray-200 dark:border-gray-700">
      <div class="flex items-center space-x-2">
        <div class="w-8 h-8 bg-black dark:bg-white rounded-full flex items-center justify-center">
          <span class="text-white dark:text-black font-bold text-sm">IA</span>
        </div>
        <span class="font-semibold text-gray-900 dark:text-white">{{ $t('app.name') }}</span>
      </div>
    </div>

    <!-- Quick Action -->
    <div class="p-4">
      <button class="w-full bg-gray-800 dark:bg-gray-700 text-white rounded-lg px-4 py-2 text-sm font-medium hover:bg-gray-700 dark:hover:bg-gray-600 transition-colors flex items-center justify-between">
        <span>{{ $t('sidebar.quickAction') }}</span>
        <span class="text-xs opacity-70">⌘K</span>
      </button>
    </div>

    <!-- Search -->
    <div class="px-4 pb-4">
      <div class="relative">
        <input 
          type="text" 
          :placeholder="$t('sidebar.search')"
          class="w-full bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-600 rounded-lg px-3 py-2 text-sm text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
        <font-awesome-icon icon="search" class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm" />
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 overflow-y-auto px-2">
      <!-- AI Playground -->
      <div class="px-2 py-1 mb-4">
        <button class="w-full text-left px-2 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
          <font-awesome-icon icon="play" class="text-sm" />
          <span>{{ $t('sidebar.aiPlayground') }}</span>
          <span class="ml-auto text-xs opacity-70">⌘3</span>
        </button>
      </div>

      <!-- Services par catégorie -->
      <div class="space-y-1">
        <!-- Vidéo -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('video')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-red-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="file-video" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.video') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.video ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.video" class="ml-6 space-y-1 mt-1">
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <div class="w-3 h-3 bg-red-400 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="magic" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.video.textToVideo') }}</span>
            </button>
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <div class="w-3 h-3 bg-red-300 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="arrow-right" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.video.imageToVideo') }}</span>
            </button>
          </div>
        </div>

        <!-- Images -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('image')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-purple-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="palette" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.image') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.image ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.image" class="ml-6 space-y-1 mt-1">
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <div class="w-3 h-3 bg-purple-400 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="magic" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.image.textToImage') }}</span>
            </button>
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <div class="w-3 h-3 bg-purple-300 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="arrow-right" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.image.imageToImage') }}</span>
            </button>
          </div>
        </div>

        <!-- Musique -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('music')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-green-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="music" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.music') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.music ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.music" class="ml-6 space-y-1 mt-1">
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <div class="w-3 h-3 bg-green-400 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="magic" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.music.textToMusic') }}</span>
            </button>
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <div class="w-3 h-3 bg-green-300 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="volume-up" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.music.generation') }}</span>
            </button>
          </div>
        </div>

        <!-- LLMs -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('llm')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-blue-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="comments" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.llm') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.llm ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.llm" class="ml-6 space-y-1 mt-1">
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <span class="w-3 h-3 bg-blue-500 rounded-sm"></span>
              <span>{{ $t('services.llm.chatgpt') }}</span>
            </button>
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <span class="w-3 h-3 bg-orange-500 rounded-sm"></span>
              <span>{{ $t('services.llm.claude') }}</span>
            </button>
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <span class="w-3 h-3 bg-purple-500 rounded-sm"></span>
              <span>{{ $t('services.llm.gemini') }}</span>
            </button>
          </div>
        </div>

        <!-- Outils -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('tools')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-orange-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="wand-magic-sparkles" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.tools') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.tools ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.tools" class="ml-6 space-y-1 mt-1">
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <div class="w-3 h-3 bg-orange-400 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="language" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.tools.translation') }}</span>
            </button>
            <button class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2">
              <div class="w-3 h-3 bg-orange-300 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="eye" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.tools.vision') }}</span>
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Bottom Section -->
    <div class="border-t border-gray-200 dark:border-gray-700 p-4 space-y-2">
      <!-- User Profile -->
      <div class="flex items-center space-x-3 p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md cursor-pointer">
        <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
          <span class="text-white text-sm font-medium">U</span>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900 dark:text-white truncate">{{ $t('user.profile') }}</p>
          <p class="text-xs text-gray-500 dark:text-gray-400">{{ $t('user.plan.free') }}</p>
        </div>
      </div>

      <!-- Menu Items -->
      <div class="space-y-1">
        <button class="w-full text-left px-2 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md">
          {{ $t('sidebar.profile') }}
        </button>
        <button class="w-full text-left px-2 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md">
          {{ $t('sidebar.about') }}
        </button>
        <button class="w-full text-left px-2 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md">
          {{ $t('sidebar.contact') }}
        </button>
      </div>
    </div>
  </aside>
</template>

<script setup>
import { ref } from 'vue'

// État des catégories expandues
const expandedCategories = ref({
  video: false,
  image: false,
  music: false,
  llm: false,
  tools: false
})

// Fonction pour toggle une catégorie
const toggleCategory = (category) => {
  expandedCategories.value[category] = !expandedCategories.value[category]
}
</script>

<style scoped>
/* Styles personnalisés si nécessaire */
</style>