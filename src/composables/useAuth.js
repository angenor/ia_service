import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'

const user = ref(null)
const loading = ref(false)

export function useAuth() {
  const isAuthenticated = computed(() => !!user.value)

  const signUp = async (email, password) => {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
      })
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error }
    } finally {
      loading.value = false
    }
  }

  const signIn = async (email, password) => {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })
      if (error) throw error
      user.value = data.user
      return { data, error: null }
    } catch (error) {
      return { data: null, error }
    } finally {
      loading.value = false
    }
  }

  const signInWithGoogle = async () => {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: window.location.origin
        }
      })
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error }
    } finally {
      loading.value = false
    }
  }

  const signOut = async () => {
    loading.value = true
    try {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
      user.value = null
      return { error: null }
    } catch (error) {
      return { error }
    } finally {
      loading.value = false
    }
  }

  const resetPassword = async (email) => {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`
      })
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error }
    } finally {
      loading.value = false
    }
  }

  const updatePassword = async (newPassword) => {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.updateUser({
        password: newPassword
      })
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error }
    } finally {
      loading.value = false
    }
  }

  const initAuth = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession()
      user.value = session?.user || null

      supabase.auth.onAuthStateChange((event, session) => {
        user.value = session?.user || null
      })
    } catch (error) {
      console.error('Error initializing auth:', error)
    }
  }

  return {
    user: computed(() => user.value),
    loading: computed(() => loading.value),
    isAuthenticated,
    signUp,
    signIn,
    signInWithGoogle,
    signOut,
    resetPassword,
    updatePassword,
    initAuth
  }
}