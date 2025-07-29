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

                  <div class="space-y-3">
                    <div 
                      v-for="pack in pointPacks" 
                      :key="pack.id"
                      @click="selectedPack = pack"
                      :class="[
                        'relative rounded-lg border-2 p-4 cursor-pointer transition-all',
                        selectedPack?.id === pack.id 
                          ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20' 
                          : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500'
                      ]"
                    >
                      <div class="flex items-center justify-between">
                        <div>
                          <h4 class="text-lg font-medium text-gray-900 dark:text-white">
                            {{ pack.points }} {{ $t('payment.points') }}
                          </h4>
                          <p class="text-sm text-gray-600 dark:text-gray-300">
                            {{ pack.bonus > 0 ? `+${pack.bonus} ${$t('payment.bonusPoints')}` : '' }}
                          </p>
                        </div>
                        <div class="text-right">
                          <p class="text-2xl font-bold text-gray-900 dark:text-white">
                            {{ formatPrice(pack.price) }}
                          </p>
                          <p v-if="pack.savings" class="text-sm text-green-600 dark:text-green-400">
                            {{ $t('payment.save') }} {{ pack.savings }}%
                          </p>
                        </div>
                      </div>
                      <div v-if="pack.popular" class="absolute -top-2 left-1/2 transform -translate-x-1/2">
                        <span class="bg-primary-500 text-white text-xs font-semibold px-3 py-1 rounded-full">
                          {{ $t('payment.popular') }}
                        </span>
                      </div>
                    </div>
                  </div>

                  <div v-if="selectedPack" class="mt-6 border-t dark:border-gray-700 pt-4">
                    <div class="flex justify-between text-sm mb-2">
                      <span class="text-gray-600 dark:text-gray-300">{{ $t('payment.subtotal') }}</span>
                      <span class="text-gray-900 dark:text-white">{{ formatPrice(selectedPack.price) }}</span>
                    </div>
                    <div class="flex justify-between text-lg font-medium">
                      <span class="text-gray-900 dark:text-white">{{ $t('payment.total') }}</span>
                      <span class="text-primary-600 dark:text-white">
                        {{ selectedPack.points + selectedPack.bonus }} {{ $t('payment.points') }}
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
              :disabled="!selectedPack || processing"
              :class="[
                'w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 text-base font-medium sm:ml-3 sm:w-auto sm:text-sm',
                !selectedPack || processing
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
import { ref, computed } from 'vue'
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

const selectedPack = ref(null)
const processing = ref(false)

const currentPoints = computed(() => userStore.points)

const pointPacks = ref([
  {
    id: 1,
    points: 100,
    bonus: 0,
    price: 9.99,
    savings: 0
  },
  {
    id: 2,
    points: 500,
    bonus: 50,
    price: 39.99,
    savings: 20,
    popular: true
  },
  {
    id: 3,
    points: 1000,
    bonus: 200,
    price: 69.99,
    savings: 30
  },
  {
    id: 4,
    points: 2500,
    bonus: 750,
    price: 149.99,
    savings: 40
  }
])

const formatPrice = (price) => {
  const formatter = new Intl.NumberFormat(locale.value, {
    style: 'currency',
    currency: locale.value === 'fr' ? 'EUR' : 'USD'
  })
  return formatter.format(price)
}

const close = () => {
  selectedPack.value = null
  emit('close')
}

const purchase = async () => {
  if (!selectedPack.value || processing.value) return
  
  processing.value = true
  
  try {
    // Simulate payment processing
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Add points to user account via Supabase
    const totalPoints = selectedPack.value.points + selectedPack.value.bonus
    const success = await userStore.addPoints(totalPoints)
    
    if (success) {
      // Show success message (you might want to add a toast notification here)
      alert(`Successfully added ${totalPoints} points to your account!`)
      selectedPack.value = null
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