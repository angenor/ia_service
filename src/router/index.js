import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue'),
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('../views/admin/AdminView.vue'),
      meta: { requiresAuth: true, requiresAdmin: true },
    },
  ],
})

// Guard pour vérifier l'authentification et les permissions admin
router.beforeEach(async (to, _from, next) => {
  const authStore = useAuthStore()
  
  // Pour les routes protégées, s'assurer que l'auth est initialisée
  if (to.meta.requiresAuth) {
    // Attendre l'initialisation de l'authentification si nécessaire
    if (authStore.loading) {
      console.log('Authentification en cours de chargement, attente...')
      // Attendre un peu et réessayer
      await new Promise(resolve => setTimeout(resolve, 100))
    }
    
    // Si toujours pas d'utilisateur après le délai, initialiser explicitement
    if (!authStore.user) {
      console.log('Pas d\'utilisateur trouvé, tentative d\'initialisation...')
      await authStore.initialize()
    }
    
    console.log('État utilisateur après initialisation:', !!authStore.user)
    
    if (!authStore.user) {
      // Rediriger vers la page d'accueil si pas connecté
      console.log('Utilisateur non connecté après initialisation, redirection vers home')
      next({ name: 'home' })
      return
    }
    
    // Vérifier les permissions admin si nécessaires
    if (to.meta.requiresAdmin) {
      // S'assurer que le profil est chargé
      if (!authStore.userProfile) {
        console.log('Chargement du profil utilisateur...')
        await authStore.getUserProfile()
      }
      
      console.log('Profil utilisateur:', authStore.userProfile)
      console.log('Is admin:', authStore.userProfile?.is_admin)
      
      if (!authStore.userProfile?.is_admin) {
        console.log('Utilisateur non admin, redirection vers home')
        next({ name: 'home' })
        return
      }
      
      console.log('Utilisateur admin confirmé, accès autorisé')
    }
  }
  
  next()
})

export default router
