<template>
  <Modal v-model="isOpen" :title="$t('auth.signUpTitle')">
    <form @submit.prevent="handleRegister" class="space-y-4">
      <!-- Full Name -->
      <div>
        <label for="fullName" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          {{ $t('auth.fullName') }}
        </label>
        <input
          id="fullName"
          v-model="form.fullName"
          type="text"
          required
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
          :placeholder="$t('auth.fullNamePlaceholder')"
        />
      </div>

      <!-- Email -->
      <div>
        <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          {{ $t('auth.email') }}
        </label>
        <input
          id="email"
          v-model="form.email"
          type="email"
          required
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
          :placeholder="$t('auth.emailPlaceholder')"
        />
      </div>

      <!-- Password -->
      <div>
        <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          {{ $t('auth.password') }}
        </label>
        <input
          id="password"
          v-model="form.password"
          type="password"
          required
          minlength="6"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
          :placeholder="$t('auth.passwordPlaceholder')"
        />
        <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">{{ $t('auth.passwordHint') }}</p>
      </div>

      <!-- Confirm Password -->
      <div>
        <label for="confirmPassword" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          {{ $t('auth.confirmPassword') }}
        </label>
        <input
          id="confirmPassword"
          v-model="form.confirmPassword"
          type="password"
          required
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
          :placeholder="$t('auth.confirmPasswordPlaceholder')"
        />
      </div>

      <!-- Terms and conditions -->
      <div class="flex items-start">
        <input
          id="terms"
          v-model="form.acceptTerms"
          type="checkbox"
          required
          class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded mt-0.5"
        />
        <label for="terms" class="ml-2 block text-sm text-gray-700 dark:text-gray-300">
          {{ $t('auth.agreeToTerms') }}
          <a href="#" class="text-blue-600 hover:text-blue-500 dark:text-blue-400">
            {{ $t('auth.termsAndConditions') }}
          </a>
        </label>
      </div>

      <!-- Error message -->
      <div v-if="error" class="rounded-md bg-red-50 dark:bg-red-900/20 p-3">
        <p class="text-sm text-red-800 dark:text-red-400">{{ error }}</p>
      </div>

      <!-- Submit button -->
      <button
        type="submit"
        :disabled="loading || !form.acceptTerms"
        class="w-full flex justify-center py-2 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span v-if="!loading">{{ $t('auth.createAccount') }}</span>
        <span v-else class="flex items-center">
          <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          {{ $t('auth.creatingAccount') }}
        </span>
      </button>

      <!-- Divider -->
      <div class="relative">
        <div class="absolute inset-0 flex items-center">
          <div class="w-full border-t border-gray-300 dark:border-gray-600"></div>
        </div>
        <div class="relative flex justify-center text-sm">
          <span class="px-2 bg-white dark:bg-gray-800 text-gray-500">{{ $t('auth.orContinueWith') }}</span>
        </div>
      </div>

      <!-- Social login -->
      <div>
        <button
          type="button"
          @click="handleGoogleSignUp"
          :disabled="loading"
          class="w-full flex justify-center items-center px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <svg class="w-5 h-5 mr-2" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          {{ $t('auth.signUpWithGoogle') }}
        </button>
      </div>

      <!-- Sign in link -->
      <p class="text-center text-sm text-gray-600 dark:text-gray-400">
        {{ $t('auth.alreadyHaveAccount') }}
        <button
          type="button"
          @click="$emit('show-login')"
          class="font-medium text-blue-600 hover:text-blue-500 dark:text-blue-400"
        >
          {{ $t('auth.signInLink') }}
        </button>
      </p>
    </form>
  </Modal>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'
import Modal from '@/components/ui/Modal.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['update:modelValue', 'show-login'])

const authStore = useAuthStore()
const router = useRouter()

const isOpen = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const form = ref({
  fullName: '',
  email: '',
  password: '',
  confirmPassword: '',
  acceptTerms: false
})

const loading = ref(false)
const error = ref('')

const handleRegister = async () => {
  error.value = ''
  
  // Validate passwords match
  if (form.value.password !== form.value.confirmPassword) {
    error.value = 'Passwords do not match'
    return
  }
  
  loading.value = true
  
  try {
    // Préparer les métadonnées pour l'inscription
    const metadata = {
      full_name: form.value.fullName,
      country_code: navigator.language.split('-')[1] || 'US',
      language_code: navigator.language.split('-')[0] || 'fr'
    }
    
    const { error: signUpError } = await authStore.signUp(
      form.value.email, 
      form.value.password,
      metadata
    )
    
    if (signUpError) {
      error.value = signUpError.message
    } else {
      isOpen.value = false
      form.value = { fullName: '', email: '', password: '', confirmPassword: '', acceptTerms: false }
    }
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const handleGoogleSignUp = async () => {
  error.value = ''
  loading.value = true
  
  try {
    const { error: signInError } = await authStore.signInWithGoogle()
    
    if (signInError) {
      error.value = signInError.message
    } else {
      isOpen.value = false
    }
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}
</script>