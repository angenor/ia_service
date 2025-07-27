<template>
  <Modal v-model="isOpen" :title="$t('profile.title')">
    <div class="space-y-6">
      <!-- Avatar Section -->
      <div class="flex flex-col items-center space-y-4">
        <div class="w-24 h-24 rounded-full overflow-hidden bg-blue-500 flex items-center justify-center">
          <img 
            v-if="avatarUrl" 
            :src="avatarUrl" 
            :alt="form.display_name"
            class="w-full h-full object-cover"
          />
          <span v-else class="text-white text-2xl font-bold">
            {{ getInitials() }}
          </span>
        </div>
        
        <p class="text-sm text-gray-600 dark:text-gray-400">
          {{ $t('profile.avatarInfo') }}
        </p>
      </div>

      <!-- Profile Form -->
      <form @submit.prevent="handleSave" class="space-y-4">
        <!-- Display Name -->
        <div>
          <label for="displayName" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            {{ $t('profile.displayName') }}
          </label>
          <input
            id="displayName"
            v-model="form.display_name"
            type="text"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
            :placeholder="$t('profile.displayNamePlaceholder')"
          />
        </div>

        <!-- Username -->
        <div>
          <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            {{ $t('profile.username') }}
          </label>
          <input
            id="username"
            v-model="form.username"
            type="text"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
            :placeholder="$t('profile.usernamePlaceholder')"
          />
        </div>

        <!-- Email (read-only) -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            {{ $t('profile.email') }}
          </label>
          <input
            id="email"
            :value="user?.email"
            type="email"
            readonly
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm bg-gray-50 dark:bg-gray-800 text-gray-600 dark:text-gray-400 cursor-not-allowed"
          />
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            {{ $t('profile.emailReadOnly') }}
          </p>
        </div>

        <!-- Country -->
        <div>
          <label for="country" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            {{ $t('profile.country') }}
          </label>
          <select
            id="country"
            v-model="form.country_code"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
          >
            <option value="US">{{ $t('countries.US') }}</option>
            <option value="FR">{{ $t('countries.FR') }}</option>
            <option value="DE">{{ $t('countries.DE') }}</option>
            <option value="ES">{{ $t('countries.ES') }}</option>
            <option value="IT">{{ $t('countries.IT') }}</option>
            <option value="GB">{{ $t('countries.GB') }}</option>
            <option value="CA">{{ $t('countries.CA') }}</option>
            <option value="JP">{{ $t('countries.JP') }}</option>
            <option value="CN">{{ $t('countries.CN') }}</option>
          </select>
        </div>

        <!-- Language -->
        <div>
          <label for="language" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            {{ $t('profile.language') }}
          </label>
          <select
            id="language"
            v-model="form.language_code"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
          >
            <option value="fr">Français</option>
            <option value="en">English</option>
            <option value="es">Español</option>
            <option value="de">Deutsch</option>
            <option value="it">Italiano</option>
          </select>
        </div>

        <!-- Account Info -->
        <div class="border-t border-gray-200 dark:border-gray-700 pt-4">
          <h3 class="text-sm font-medium text-gray-900 dark:text-white mb-3">
            {{ $t('profile.accountInfo') }}
          </h3>
          
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span class="text-gray-600 dark:text-gray-400">{{ $t('profile.memberSince') }}:</span>
              <div class="font-medium text-gray-900 dark:text-white">
                {{ formatDate(user?.created_at) }}
              </div>
            </div>
            
            <div>
              <span class="text-gray-600 dark:text-gray-400">{{ $t('profile.lastLogin') }}:</span>
              <div class="font-medium text-gray-900 dark:text-white">
                {{ formatDate(user?.last_sign_in_at) }}
              </div>
            </div>
            
            <div>
              <span class="text-gray-600 dark:text-gray-400">{{ $t('profile.plan') }}:</span>
              <div class="font-medium text-gray-900 dark:text-white">
                {{ userProfile?.subscription_plan || $t('user.plan.free') }}
              </div>
            </div>
            
            <div>
              <span class="text-gray-600 dark:text-gray-400">{{ $t('profile.provider') }}:</span>
              <div class="font-medium text-gray-900 dark:text-white capitalize">
                {{ userProfile?.metadata?.provider || 'email' }}
              </div>
            </div>
          </div>
        </div>

        <!-- Error message -->
        <div v-if="error" class="rounded-md bg-red-50 dark:bg-red-900/20 p-3">
          <p class="text-sm text-red-800 dark:text-red-400">{{ error }}</p>
        </div>

        <!-- Success message -->
        <div v-if="success" class="rounded-md bg-green-50 dark:bg-green-900/20 p-3">
          <p class="text-sm text-green-800 dark:text-green-400">{{ success }}</p>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-between pt-4">
          <button
            type="button"
            @click="handlePasswordChange"
            class="px-4 py-2 text-sm font-medium text-blue-600 hover:text-blue-500 dark:text-blue-400 dark:hover:text-blue-300"
          >
            {{ $t('profile.changePassword') }}
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
              type="submit"
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
      </form>
    </div>
  </Modal>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useI18n } from 'vue-i18n'
import Modal from '@/components/ui/Modal.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const { t } = useI18n()
const authStore = useAuthStore()

const isOpen = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

// État
const loading = ref(false)
const error = ref('')
const success = ref('')

// Form data
const form = ref({
  display_name: '',
  username: '',
  country_code: 'US',
  language_code: 'fr'
})

// Computed
const user = computed(() => authStore.user)
const userProfile = computed(() => authStore.userProfile)
const avatarUrl = computed(() => {
  return userProfile.value?.metadata?.avatar_url || null
})

// Methods
const getInitials = () => {
  if (form.value.display_name) {
    return form.value.display_name.split(' ').map(name => name[0]).join('').toUpperCase()
  }
  if (user.value?.email) {
    return user.value.email.charAt(0).toUpperCase()
  }
  return 'U'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}


const handleSave = async () => {
  error.value = ''
  success.value = ''
  loading.value = true
  
  try {
    const updates = {
      display_name: form.value.display_name,
      username: form.value.username,
      country_code: form.value.country_code,
      language_code: form.value.language_code
    }
    
    const { error: updateError } = await authStore.updateUserProfile(updates)
    
    if (updateError) {
      error.value = updateError.message
    } else {
      success.value = t('profile.updateSuccess')
      setTimeout(() => {
        success.value = ''
      }, 3000)
    }
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const handlePasswordChange = () => {
  // TODO: Implémenter le changement de mot de passe
  alert('Fonctionnalité de changement de mot de passe à implémenter')
}

// Initialiser le formulaire quand le modal s'ouvre
watch(() => props.modelValue, (isOpen) => {
  if (isOpen && userProfile.value) {
    form.value = {
      display_name: userProfile.value.display_name || '',
      username: userProfile.value.username || '',
      country_code: userProfile.value.country_code || 'US',
      language_code: userProfile.value.language_code || 'fr'
    }
    error.value = ''
    success.value = ''
  }
}, { immediate: true })
</script>