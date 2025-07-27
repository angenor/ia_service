import { ref, watch } from 'vue'
import { defineStore } from 'pinia'
import { useI18n } from 'vue-i18n'

export const useLocaleStore = defineStore('locale', () => {
  const savedLocale = localStorage.getItem('locale')
  const browserLocale = navigator.language.split('-')[0]
  const defaultLocale = savedLocale || (['en', 'fr'].includes(browserLocale) ? browserLocale : 'fr')
  
  const currentLocale = ref(defaultLocale)

  const setLocale = (locale) => {
    currentLocale.value = locale
    // Mettre à jour i18n si disponible
    try {
      const { locale: i18nLocale } = useI18n()
      i18nLocale.value = locale
    } catch (error) {
      // i18n n'est pas encore disponible, ce n'est pas grave
    }
  }

  const initLocale = () => {
    const saved = localStorage.getItem('locale')
    const browser = navigator.language.split('-')[0]
    const locale = saved || (['en', 'fr'].includes(browser) ? browser : 'fr')
    setLocale(locale)
  }

  watch(currentLocale, (newLocale) => {
    localStorage.setItem('locale', newLocale)
  })

  return {
    locale: currentLocale,
    currentLocale,
    setLocale,
    initLocale
  }
})