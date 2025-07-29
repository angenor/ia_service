import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import i18n from './plugins/i18n'
import FontAwesomeIcon from './plugins/fontawesome'
import { useAuthStore } from './stores/auth'



// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCdzWBA7fswRfhXxfR8xAE-Y9TJ6aO_lHs",
  authDomain: "nelo-ai-e785d.firebaseapp.com",
  projectId: "nelo-ai-e785d",
  storageBucket: "nelo-ai-e785d.firebasestorage.app",
  messagingSenderId: "275335896913",
  appId: "1:275335896913:web:032fc1ec8c0f3f6bfb3d70",
  measurementId: "G-P6QXQ8TGLN"
};

// Initialize Firebase
const firebaseApp = initializeApp(firebaseConfig);
const analytics = getAnalytics(firebaseApp);




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
