<template>
  <button
    @click="themeStore.toggleTheme"
    :title="$t('theme.toggle')"
    class="p-2 rounded-lg bg-gray-300 dark:bg-gray-700 hover:bg-gray-400 dark:hover:bg-gray-600 transition-colors duration-200"
  >
    <font-awesome-icon
      :icon="themeStore.isDark ? 'sun' : 'moon'"
      class="w-5 h-5 text-gray-800 dark:text-gray-200"
    />
  </button>
</template>

<script setup>
import { useThemeStore } from '@/stores/theme'

const themeStore = useThemeStore()
</script>