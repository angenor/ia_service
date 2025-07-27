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
      
      // Tentative avec RPC pour éviter les problèmes RLS
      const { data: rpcData, error: rpcError } = await supabase
        .rpc('get_user_profile', { user_id: user.value.id })
      
      if (!rpcError && rpcData) {
        userProfile.value = rpcData[0] || null
        return userProfile.value
      }
      
      // Fallback: essayer la requête normale
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
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
            metadata: {
              email: user.value.email,
              provider: user.value.app_metadata?.provider
            }
          }
          return userProfile.value
        }
        throw error
      }
      
      userProfile.value = data
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
    await initAuth()
    if (user.value) {
      await getUserProfile()
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