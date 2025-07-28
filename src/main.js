import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import i18n from './plugins/i18n'
import FontAwesomeIcon from './plugins/fontawesome'
import { useAuthStore } from './stores/auth'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(i18n)
app.component('font-awesome-icon', FontAwesomeIcon)

// Initialiser l'authentification avant de monter l'app
async function initApp() {
  const authStore = useAuthStore()
  await authStore.initialize()
  app.mount('#app')
}

initApp()
