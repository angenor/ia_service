<template>
  <Modal v-model="isOpen" :title="$t('settings.title')">
    <div class="space-y-6">
      <!-- Appearance Section -->
      <div>
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('settings.appearance.title') }}
        </h3>
        
        <div class="space-y-4">
          <!-- Theme Selection -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('settings.appearance.theme') }}
            </label>
            <div class="grid grid-cols-3 gap-3">
              <button
                v-for="themeOption in themeOptions"
                :key="themeOption.value"
                @click="updateTheme(themeOption.value)"
                class="relative p-3 border-2 rounded-lg flex flex-col items-center space-y-2 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors text-gray-700 dark:text-gray-300"
                :class="{
                  'border-blue-500 bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': currentTheme === themeOption.value,
                  'border-gray-200 dark:border-gray-600': currentTheme !== themeOption.value
                }"
              >
                <font-awesome-icon :icon="themeOption.icon" class="text-xl" :class="{
                  'text-blue-600 dark:text-blue-400': currentTheme === themeOption.value,
                  'text-gray-600 dark:text-gray-400': currentTheme !== themeOption.value
                }" />
                <span class="text-sm font-medium" :class="{
                  'text-blue-700 dark:text-blue-300': currentTheme === themeOption.value,
                  'text-gray-700 dark:text-gray-300': currentTheme !== themeOption.value
                }">{{ $t(themeOption.label) }}</span>
                <font-awesome-icon 
                  v-if="currentTheme === themeOption.value"
                  icon="check-circle" 
                  class="absolute top-1 right-1 text-blue-500 text-sm" 
                />
              </button>
            </div>
          </div>

          <!-- Language Selection -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('settings.appearance.language') }}
            </label>
            <select
              :value="currentLocale"
              @change="updateLanguage($event.target.value)"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
            >
              <option v-for="lang in languageOptions" :key="lang.value" :value="lang.value">
                {{ lang.label }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <hr class="border-gray-200 dark:border-gray-700">

      <!-- Notifications Section -->
      <div>
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('settings.notifications.title') }}
        </h3>
        
        <div class="space-y-4">
          <!-- Email Notifications -->
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('settings.notifications.email') }}
              </label>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ $t('settings.notifications.emailDescription') }}
              </p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input 
                type="checkbox" 
                v-model="settings.notifications.email"
                class="sr-only peer"
              >
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>

          <!-- Browser Notifications -->
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('settings.notifications.browser') }}
              </label>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ $t('settings.notifications.browserDescription') }}
              </p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input 
                type="checkbox" 
                v-model="settings.notifications.browser"
                @change="handleBrowserNotificationChange"
                class="sr-only peer"
              >
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>

          <!-- Generation Notifications -->
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('settings.notifications.generation') }}
              </label>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ $t('settings.notifications.generationDescription') }}
              </p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input 
                type="checkbox" 
                v-model="settings.notifications.generation"
                class="sr-only peer"
              >
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <hr class="border-gray-200 dark:border-gray-700">

      <!-- Privacy & Security Section -->
      <div>
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('settings.privacy.title') }}
        </h3>
        
        <div class="space-y-4">
          <!-- Data Collection -->
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('settings.privacy.analytics') }}
              </label>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ $t('settings.privacy.analyticsDescription') }}
              </p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input 
                type="checkbox" 
                v-model="settings.privacy.analytics"
                class="sr-only peer"
              >
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>

          <!-- Auto-save -->
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('settings.privacy.autosave') }}
              </label>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ $t('settings.privacy.autosaveDescription') }}
              </p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input 
                type="checkbox" 
                v-model="settings.privacy.autosave"
                class="sr-only peer"
              >
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <hr class="border-gray-200 dark:border-gray-700">

      <!-- Advanced Section -->
      <div>
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('settings.advanced.title') }}
        </h3>
        
        <div class="space-y-4">
          <!-- Clear Cache -->
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('settings.advanced.clearCache') }}
              </label>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ $t('settings.advanced.clearCacheDescription') }}
              </p>
            </div>
            <button
              @click="clearCache"
              class="px-4 py-2 text-sm font-medium text-red-600 hover:text-red-500 dark:text-red-400 dark:hover:text-red-300 border border-red-300 dark:border-red-600 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20"
            >
              {{ $t('settings.advanced.clear') }}
            </button>
          </div>

          <!-- Export Data -->
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('settings.advanced.exportData') }}
              </label>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ $t('settings.advanced.exportDataDescription') }}
              </p>
            </div>
            <button
              @click="exportData"
              class="px-4 py-2 text-sm font-medium text-blue-600 hover:text-blue-500 dark:text-blue-400 dark:hover:text-blue-300 border border-blue-300 dark:border-blue-600 rounded-lg hover:bg-blue-50 dark:hover:bg-blue-900/20"
            >
              {{ $t('settings.advanced.export') }}
            </button>
          </div>
        </div>
      </div>

      <!-- Success/Error Messages -->
      <div v-if="message" class="rounded-md p-3" :class="{
        'bg-green-50 dark:bg-green-900/20': messageType === 'success',
        'bg-red-50 dark:bg-red-900/20': messageType === 'error'
      }">
        <p class="text-sm" :class="{
          'text-green-800 dark:text-green-400': messageType === 'success',
          'text-red-800 dark:text-red-400': messageType === 'error'
        }">{{ message }}</p>
      </div>

      <!-- Action Buttons -->
      <div class="flex justify-between pt-4">
        <button
          @click="resetToDefaults"
          class="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-500 dark:text-gray-400 dark:hover:text-gray-300"
        >
          {{ $t('settings.resetDefaults') }}
        </button>
        
        <div class="flex space-x-3">
          <button
            type="button"
            @click="isOpen = false"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
          >
            {{ $t('common.cancel') }}
          </button>
          <button
            @click="saveSettings"
            :disabled="loading"
            class="px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white rounded-lg text-sm font-medium flex items-center space-x-2"
          >
            <span v-if="!loading">{{ $t('common.save') }}</span>
            <span v-else class="flex items-center">
              <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              {{ $t('common.saving') }}
            </span>
          </button>
        </div>
      </div>
    </div>
  </Modal>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useThemeStore } from '@/stores/theme'
import { useLocaleStore } from '@/stores/locale'
import Modal from '@/components/ui/Modal.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const { t } = useI18n()
const themeStore = useThemeStore()
const localeStore = useLocaleStore()

const isOpen = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

// État
const loading = ref(false)
const message = ref('')
const messageType = ref('success')

// Options de thème
const themeOptions = [
  { value: 'light', label: 'theme.light', icon: 'sun' },
  { value: 'dark', label: 'theme.dark', icon: 'moon' },
  { value: 'system', label: 'settings.appearance.system', icon: 'laptop' }
]

// Options de langue
const languageOptions = [
  { value: 'fr', label: 'Français' },
  { value: 'en', label: 'English' },
  { value: 'es', label: 'Español' },
  { value: 'de', label: 'Deutsch' },
  { value: 'it', label: 'Italiano' }
]

// Paramètres par défaut
const defaultSettings = {
  notifications: {
    email: true,
    browser: false,
    generation: true
  },
  privacy: {
    analytics: true,
    autosave: true
  }
}

// État des paramètres
const settings = ref({ ...defaultSettings })

// Computed
const currentTheme = computed(() => themeStore.theme)
const currentLocale = computed(() => localeStore.locale)

// Methods
const updateTheme = (theme) => {
  themeStore.setTheme(theme)
  showMessage(t('settings.themeUpdated'), 'success')
}

const updateLanguage = (lang) => {
  localeStore.setLocale(lang)
  // Forcer la réactivité en attendant que la langue change
  setTimeout(() => {
    showMessage(t('settings.languageUpdated'), 'success')
  }, 100)
}

const handleBrowserNotificationChange = async () => {
  if (settings.value.notifications.browser) {
    try {
      const permission = await Notification.requestPermission()
      if (permission !== 'granted') {
        settings.value.notifications.browser = false
        showMessage(t('settings.notifications.permissionDenied'), 'error')
      } else {
        showMessage(t('settings.notifications.permissionGranted'), 'success')
      }
    } catch (error) {
      settings.value.notifications.browser = false
      showMessage(t('settings.notifications.notSupported'), 'error')
    }
  }
}

const clearCache = () => {
  // Vider le localStorage (sauf les paramètres importants)
  const keysToKeep = ['theme', 'locale', 'auth-token']
  const allKeys = Object.keys(localStorage)
  
  allKeys.forEach(key => {
    if (!keysToKeep.some(keepKey => key.includes(keepKey))) {
      localStorage.removeItem(key)
    }
  })
  
  showMessage(t('settings.advanced.cacheCleared'), 'success')
}

const exportData = () => {
  const userData = {
    settings: settings.value,
    theme: currentTheme.value,
    language: currentLocale.value,
    exportDate: new Date().toISOString()
  }
  
  const dataStr = JSON.stringify(userData, null, 2)
  const dataBlob = new Blob([dataStr], { type: 'application/json' })
  
  const link = document.createElement('a')
  link.href = URL.createObjectURL(dataBlob)
  link.download = `epavillon-settings-${new Date().toISOString().split('T')[0]}.json`
  link.click()
  
  showMessage(t('settings.advanced.dataExported'), 'success')
}

const resetToDefaults = () => {
  settings.value = { ...defaultSettings }
  themeStore.setTheme('system')
  localeStore.setLocale('fr')
  showMessage(t('settings.resetSuccess'), 'success')
}

const saveSettings = () => {
  loading.value = true
  
  // Sauvegarder dans localStorage
  localStorage.setItem('app-settings', JSON.stringify(settings.value))
  
  setTimeout(() => {
    loading.value = false
    showMessage(t('settings.saveSuccess'), 'success')
  }, 500)
}

const showMessage = (text, type = 'success') => {
  message.value = text
  messageType.value = type
  setTimeout(() => {
    message.value = ''
  }, 3000)
}

// Charger les paramètres au montage
onMounted(() => {
  const savedSettings = localStorage.getItem('app-settings')
  if (savedSettings) {
    try {
      settings.value = { ...defaultSettings, ...JSON.parse(savedSettings) }
    } catch (error) {
      console.error('Error loading settings:', error)
    }
  }
})

// Réinitialiser les messages quand le modal s'ouvre
watch(() => props.modelValue, (isOpen) => {
  if (isOpen) {
    message.value = ''
  }
})
</script>