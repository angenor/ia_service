import { ref, watch } from 'vue'
import { defineStore } from 'pinia'

export const useLocaleStore = defineStore('locale', () => {
  const currentLocale = ref('en')

  const setLocale = (locale) => {
    currentLocale.value = locale
  }

  const initLocale = () => {
    const saved = localStorage.getItem('locale')
    const browser = navigator.language.split('-')[0]
    currentLocale.value = saved || (['en', 'fr'].includes(browser) ? browser : 'en')
  }

  watch(currentLocale, (newLocale) => {
    localStorage.setItem('locale', newLocale)
  })

  return {
    currentLocale,
    setLocale,
    initLocale
  }
})