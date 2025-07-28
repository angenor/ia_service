import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useAuth } from '@/composables/useAuth'

export const useAuthStore = defineStore('auth', () => {
  const auth = useAuth()
  const {
    user,
    loading,
    isAuthenticated,
    signIn,
    signInWithGoogle,
    signOut,
    resetPassword,
    updatePassword,
    initAuth
  } = auth

  const userProfile = ref(null)
  const profileLoading = ref(false)

  const getUserProfile = async () => {
    if (!user.value) return null
    
    profileLoading.value = true
    try {
      const { supabase } = await import('@/lib/supabase')
      
      console.log('Chargement du profil pour utilisateur:', user.value.id)
      
      // Tentative avec RPC pour éviter les problèmes RLS
      const { data: rpcData, error: rpcError } = await supabase
        .rpc('get_user_profile', { user_id: user.value.id })
      
      if (!rpcError && rpcData && rpcData.length > 0) {
        userProfile.value = rpcData[0]
        console.log('Profil chargé via RPC:', userProfile.value)
        return userProfile.value
      }
      
      console.log('RPC error ou pas de données, tentative avec requête normale:', rpcError)
      
      // Fallback: essayer la requête normale avec select explicite
      const { data, error } = await supabase
        .from('profiles')
        .select('id, username, display_name, country_code, language_code, created_at, updated_at, is_admin, metadata')
        .eq('id', user.value.id)
        .maybeSingle()
      
      if (error) {
        console.error('Error fetching user profile:', error)
        // Si c'est une erreur RLS, créer un profil basique temporaire
        if (error.code === '42P17') {
          userProfile.value = {
            id: user.value.id,
            username: user.value.email,
            display_name: user.value.user_metadata?.full_name || user.value.email?.split('@')[0],
            country_code: 'US',
            language_code: 'fr',
            is_admin: false, // Par défaut, pas admin
            metadata: {
              email: user.value.email,
              provider: user.value.app_metadata?.provider
            }
          }
          console.log('Profil fallback créé:', userProfile.value)
          return userProfile.value
        }
        throw error
      }
      
      userProfile.value = data
      console.log('Profil chargé via requête normale:', userProfile.value)
      return data
    } catch (error) {
      console.error('Error fetching user profile:', error)
      return null
    } finally {
      profileLoading.value = false
    }
  }

  const updateUserProfile = async (updates) => {
    if (!user.value) return { error: 'User not authenticated' }
    
    profileLoading.value = true
    try {
      const { supabase } = await import('@/lib/supabase')
      
      // Tentative de mise à jour normale
      const { data, error } = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.value.id)
        .select()
        .maybeSingle()
      
      if (error) {
        // Si erreur RLS, essayer avec upsert
        if (error.code === '42P17' || error.message.includes('recursion')) {
          const { data: upsertData, error: upsertError } = await supabase
            .from('profiles')
            .upsert({
              id: user.value.id,
              ...updates
            }, {
              onConflict: 'id'
            })
            .select()
            .maybeSingle()
          
          if (upsertError) throw upsertError
          userProfile.value = upsertData
          return { data: upsertData, error: null }
        }
        throw error
      }
      
      userProfile.value = data
      return { data, error: null }
    } catch (error) {
      console.error('Error updating user profile:', error)
      return { data: null, error }
    } finally {
      profileLoading.value = false
    }
  }

  const initialize = async () => {
    console.log('Initialisation du store auth...')
    await initAuth()
    console.log('Utilisateur après initAuth:', !!user.value)
    if (user.value) {
      await getUserProfile()
      console.log('Profil chargé lors de l\'initialisation:', !!userProfile.value)
    }
  }

  const signUp = async (email, password, metadata = {}) => {
    const result = await auth.signUp(email, password, metadata)
    if (!result.error && user.value) {
      await getUserProfile()
    }
    return result
  }

  return {
    user,
    userProfile: computed(() => userProfile.value),
    profile: computed(() => userProfile.value), // Alias pour compatibilité
    loading,
    profileLoading: computed(() => profileLoading.value),
    isAuthenticated,
    signUp,
    signIn,
    signInWithGoogle,
    signOut,
    resetPassword,
    updatePassword,
    getUserProfile,
    updateUserProfile,
    initialize
  }
})