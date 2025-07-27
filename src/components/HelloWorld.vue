<script setup>
defineProps({
  msg: {
    type: String,
    required: true,
  },
})
</script>

<template>
  <div class="p-4 bg-gray-100 dark:bg-gray-800 rounded-lg shadow transition-colors duration-200">
    <h1 class="text-3xl font-bold text-green-500 dark:text-green-400 mb-4">{{ $t('welcome.title') }}</h1>
    <h3 class="text-lg text-gray-700 dark:text-gray-300">
      {{ $t('welcome.message') }}
    </h3>
  </div>
</template>

<style scoped>
@media (min-width: 1024px) {
  .p-4 h1,
  .p-4 h3 {
    text-align: left;
  }
}
</style>
