<template>
  <div class="about bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-200">
    <div class="max-w-4xl mx-auto p-6">
      <h1 class="text-4xl font-bold mb-6 text-center">{{ $t('nav.about') }}</h1>
      <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-6 shadow-sm">
        <p class="text-lg leading-relaxed">
          Cette application Vue.js 3 utilise Tailwind CSS pour le style, Pinia pour la gestion d'état, 
          et Vue i18n pour l'internationalisation. Elle dispose d'un mode sombre/clair et supporte 
          le français et l'anglais.
        </p>
      </div>
    </div>
  </div>
</template>
