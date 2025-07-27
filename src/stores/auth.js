import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useAuth } from '@/composables/useAuth'

export const useAuthStore = defineStore('auth', () => {
  const {
    user,
    loading,
    isAuthenticated,
    signUp,
    signIn,
    signInWithGoogle,
    signOut,
    resetPassword,
    updatePassword,
    initAuth
  } = useAuth()

  const userProfile = ref(null)
  const profileLoading = ref(false)

  const getUserProfile = async () => {
    if (!user.value) return null
    
    profileLoading.value = true
    try {
      const { supabase } = await import('@/lib/supabase')
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.value.id)
        .single()
      
      if (error) throw error
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
      const { data, error } = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.value.id)
        .select()
        .single()
      
      if (error) throw error
      userProfile.value = data
      return { data, error: null }
    } catch (error) {
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