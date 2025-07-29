<template>
  <Transition name="modal">
    <div v-if="isOpen" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 dark:bg-gray-900 bg-opacity-75 dark:bg-opacity-75 transition-opacity" @click="close"></div>

        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

        <div class="relative inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
          <div class="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="w-full">
                <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white" id="modal-title">
                  {{ $t('payment.title') }}
                </h3>
                <div class="mt-4">
                  <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
                    {{ $t('payment.subtitle') }}
                  </p>
                  
                  <div class="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg mb-4">
                    <p class="text-sm font-medium text-gray-900 dark:text-white">
                      {{ $t('payment.currentBalance') }}: 
                      <span class="text-2xl text-primary-600 dark:text-primary-400">{{ currentPoints }}</span> {{ $t('payment.points') }}
                    </p>
                  </div>

                  <div class="space-y-4">
                    <div class="bg-gray-50 dark:bg-gray-700/50 p-4 rounded-lg">
                      <h4 class="text-sm font-medium text-gray-900 dark:text-white mb-3">
                        {{ $t('payment.selectPoints') }}
                      </h4>
                      <div class="flex items-center justify-center space-x-4">
                        <button
                          @mousedown="startDecrement"
                          @mouseup="stopIncrement"
                          @mouseleave="stopIncrement"
                          @touchstart="startDecrement"
                          @touchend="stopIncrement"
                          @click="decrementPoints"
                          :disabled="selectedPoints <= 50"
                          :class="[
                            'w-10 h-10 rounded-full flex items-center justify-center transition-all select-none',
                            selectedPoints <= 50
                              ? 'bg-gray-200 dark:bg-gray-600 cursor-not-allowed text-gray-400 dark:text-gray-500'
                              : 'bg-primary-600 hover:bg-primary-700 text-white active:bg-primary-800'
                          ]"
                        >
                          <span class="text-xl font-bold">-</span>
                        </button>
                        <div class="text-center">
                          <p class="text-3xl font-bold text-gray-900 dark:text-white">
                            {{ selectedPoints }}
                          </p>
                          <p class="text-sm text-gray-600 dark:text-gray-300">
                            {{ $t('payment.points') }}
                          </p>
                        </div>
                        <button
                          @mousedown="startIncrement"
                          @mouseup="stopIncrement"
                          @mouseleave="stopIncrement"
                          @touchstart="startIncrement"
                          @touchend="stopIncrement"
                          @click="incrementPoints"
                          :disabled="selectedPoints >= 10000"
                          :class="[
                            'w-10 h-10 rounded-full flex items-center justify-center transition-all select-none',
                            selectedPoints >= 10000
                              ? 'bg-gray-200 dark:bg-gray-600 cursor-not-allowed text-gray-400 dark:text-gray-500'
                              : 'bg-primary-600 hover:bg-primary-700 text-white active:bg-primary-800'
                          ]"
                        >
                          <span class="text-xl font-bold">+</span>
                        </button>
                      </div>
                      <p class="text-xs text-gray-500 dark:text-gray-400 text-center mt-2">
                        {{ $t('payment.incrementNote') }}
                      </p>
                    </div>
                  </div>

                  <div class="mt-6 border-t dark:border-gray-700 pt-4">
                    <div class="flex justify-between text-sm mb-2">
                      <span class="text-gray-600 dark:text-gray-300">{{ $t('payment.pointsSelected') }}</span>
                      <span class="text-gray-900 dark:text-white">{{ selectedPoints }} {{ $t('payment.points') }}</span>
                    </div>
                    <div class="flex justify-between text-sm mb-2">
                      <span class="text-gray-600 dark:text-gray-300">{{ $t('payment.pricePerPoint') }}</span>
                      <span class="text-gray-900 dark:text-white">{{ formatPrice(0.01) }}</span>
                    </div>
                    <div class="flex justify-between text-lg font-medium">
                      <span class="text-gray-900 dark:text-white">{{ $t('payment.total') }}</span>
                      <span class="text-primary-600 dark:text-primary-400">
                        {{ formatPrice(calculatedPrice) }}
                      </span>
                    </div>
                  </div>

                  <div v-if="userStore.error" class="mt-4 p-3 bg-red-100 dark:bg-red-900/20 border border-red-400 dark:border-red-600 rounded-md">
                    <p class="text-sm text-red-700 dark:text-red-300">{{ userStore.error }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-100 dark:bg-gray-700 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button
              type="button"
              @click="purchase"
              :disabled="selectedPoints === 0 || processing"
              :class="[
                'w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 text-base font-medium sm:ml-3 sm:w-auto sm:text-sm',
                selectedPoints === 0 || processing
                  ? 'bg-gray-400 dark:bg-gray-600 cursor-not-allowed'
                  : 'bg-primary-600 hover:bg-primary-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500'
              ]"
            >
              {{ processing ? $t('payment.processing') : $t('payment.purchase') }}
            </button>
            <button
              type="button"
              @click="close"
              class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
            >
              {{ $t('payment.cancel') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, computed, onBeforeUnmount } from 'vue'
import { useI18n } from 'vue-i18n'
import { useUserStore } from '@/stores/user'

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])

const { locale } = useI18n()
const userStore = useUserStore()

const selectedPoints = ref(100)
const processing = ref(false)
const intervalId = ref(null)
const isHolding = ref(false)

const currentPoints = computed(() => userStore.points)

const calculatedPrice = computed(() => {
  return selectedPoints.value * 0.01 // 100 points = 1 dollar
})

const incrementPoints = () => {
  if (selectedPoints.value < 10000) {
    selectedPoints.value += 50
  }
}

const decrementPoints = () => {
  if (selectedPoints.value > 50) {
    selectedPoints.value -= 50
  }
}

const formatPrice = (price) => {
  const formatter = new Intl.NumberFormat(locale.value, {
    style: 'currency',
    currency: locale.value === 'fr' ? 'EUR' : 'USD'
  })
  return formatter.format(price)
}

const startIncrement = (e) => {
  e.preventDefault()
  isHolding.value = true
  
  // Attendre 300ms avant de commencer l'incrémentation continue
  setTimeout(() => {
    if (isHolding.value) {
      intervalId.value = setInterval(() => {
        if (selectedPoints.value < 10000) {
          selectedPoints.value += 50
        } else {
          stopIncrement()
        }
      }, 333) // 3 fois par seconde
    }
  }, 300)
}

const startDecrement = (e) => {
  e.preventDefault()
  isHolding.value = true
  
  // Attendre 300ms avant de commencer la décrémentation continue
  setTimeout(() => {
    if (isHolding.value) {
      intervalId.value = setInterval(() => {
        if (selectedPoints.value > 50) {
          selectedPoints.value -= 50
        } else {
          stopIncrement()
        }
      }, 333) // 3 fois par seconde
    }
  }, 300)
}

const stopIncrement = () => {
  isHolding.value = false
  if (intervalId.value) {
    clearInterval(intervalId.value)
    intervalId.value = null
  }
}

const close = () => {
  stopIncrement()
  selectedPoints.value = 100
  emit('close')
}

onBeforeUnmount(() => {
  stopIncrement()
})

const purchase = async () => {
  if (selectedPoints.value === 0 || processing.value) return
  
  processing.value = true
  
  try {
    // Simulate payment processing
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Add points to user account via Supabase
    const success = await userStore.addPoints(selectedPoints.value)
    
    if (success) {
      // Show success message (you might want to add a toast notification here)
      alert(`Successfully added ${selectedPoints.value} points to your account!`)
      close()
    } else {
      // Show error message
      alert('Failed to add points. Please try again.')
    }
  } catch (error) {
    console.error('Purchase error:', error)
    alert('An error occurred during purchase. Please try again.')
  } finally {
    processing.value = false
  }
}
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .relative,
.modal-leave-active .relative {
  transition: all 0.3s ease;
}

.modal-enter-from .relative,
.modal-leave-to .relative {
  transform: translate(0, 4rem);
  opacity: 0;
}
</style>