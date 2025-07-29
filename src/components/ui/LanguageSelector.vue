<template>
  <div class="relative">
    <button
      @click="isOpen = !isOpen"
      :title="$t('language.select')"
      class="flex items-center gap-2 p-2 rounded-lg bg-gray-300 dark:bg-gray-700 hover:bg-gray-400 dark:hover:bg-gray-600 transition-colors duration-200"
    >
      <font-awesome-icon
        icon="globe"
        class="w-4 h-4 text-gray-800 dark:text-gray-200"
      />
      <span class="text-sm font-medium text-gray-800 dark:text-gray-200">
        {{ currentLocaleLabel }}
      </span>
      <font-awesome-icon
        :icon="isOpen ? 'chevron-up' : 'chevron-down'"
        class="w-3 h-3 text-gray-800 dark:text-gray-200"
      />
    </button>

    <div
      v-if="isOpen"
      class="absolute right-0 mt-2 w-32 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 z-50"
    >
      <button
        v-for="locale in availableLocales"
        :key="locale.code"
        @click="changeLocale(locale.code)"
        class="w-full px-3 py-2 text-left text-sm hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors duration-200 first:rounded-t-lg last:rounded-b-lg"
        :class="{
          'bg-primary-100 dark:bg-primary-900 text-primary-700 dark:text-primary-300': locale.code === localeStore.currentLocale,
          'text-gray-800 dark:text-gray-200': locale.code !== localeStore.currentLocale
        }"
      >
        {{ locale.label }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useLocaleStore } from '@/stores/locale'

const { locale } = useI18n()
const localeStore = useLocaleStore()
const isOpen = ref(false)

const availableLocales = [
  { code: 'en', label: 'English' },
  { code: 'fr', label: 'Français' }
]

const currentLocaleLabel = computed(() => {
  return availableLocales.find(l => l.code === localeStore.currentLocale)?.label || 'EN'
})

const changeLocale = (newLocale) => {
  localeStore.setLocale(newLocale)
  locale.value = newLocale
  isOpen.value = false
}

const closeDropdown = (event) => {
  if (!event.target.closest('.relative')) {
    isOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', closeDropdown)
})

onUnmounted(() => {
  document.removeEventListener('click', closeDropdown)
})
</script>