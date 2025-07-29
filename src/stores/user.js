import { ref, computed, watch } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from './auth'

export const useUserStore = defineStore('user', () => {
  const authStore = useAuthStore()
  
  const walletData = ref(null)
  const loading = ref(false)
  const error = ref(null)

  const points = computed(() => walletData.value?.balance || 0)
  
  const formattedPoints = computed(() => {
    return new Intl.NumberFormat().format(points.value)
  })

  // Fetch wallet data from Supabase
  async function fetchWallet() {
    if (!authStore.user) return
    
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('wallets')
        .select('*')
        .eq('user_id', authStore.user.id)
        .single()
      
      if (fetchError) {
        // If wallet doesn't exist, create it
        if (fetchError.code === 'PGRST116') {
          const { data: newWallet, error: createError } = await supabase
            .from('wallets')
            .insert([{ 
              user_id: authStore.user.id,
              balance: 0,
              currency: 'USD'
            }])
            .select()
            .single()
          
          if (createError) throw createError
          walletData.value = newWallet
        } else {
          throw fetchError
        }
      } else {
        walletData.value = data
      }
    } catch (err) {
      console.error('Error fetching wallet:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Add points to wallet (after successful payment)
  async function addPoints(amount, transactionRef = null) {
    if (!authStore.user) return false
    
    loading.value = true
    error.value = null
    
    try {
      // Use the secure function to add points
      const { data, error: funcError } = await supabase
        .rpc('add_wallet_points', {
          p_amount: amount,
          p_payment_method: 'simulation', // Change this when real payment is implemented
          p_payment_reference: transactionRef
        })
      
      if (funcError) throw funcError
      
      if (data && data.success) {
        // Update local wallet data
        if (walletData.value) {
          walletData.value.balance = data.new_balance
        }
        return true
      } else {
        throw new Error(data?.error || 'Failed to add points')
      }
    } catch (err) {
      console.error('Error adding points:', err)
      error.value = err.message
      return false
    } finally {
      loading.value = false
    }
  }

  // Use points for a service
  async function usePoints(amount, serviceId = null) {
    if (!authStore.user) return false
    
    loading.value = true
    error.value = null
    
    try {
      // Use the secure function to use points
      const { data, error: funcError } = await supabase
        .rpc('use_wallet_points', {
          p_amount: amount,
          p_service_id: serviceId,
          p_metadata: {}
        })
      
      if (funcError) throw funcError
      
      if (data && data.success) {
        // Update local wallet data
        if (walletData.value) {
          walletData.value.balance = data.new_balance
        }
        return true
      } else {
        error.value = data?.error || 'Failed to use points'
        return false
      }
    } catch (err) {
      console.error('Error using points:', err)
      error.value = err.message
      return false
    } finally {
      loading.value = false
    }
  }

  // Get transaction history
  async function getTransactionHistory(limit = 20) {
    if (!authStore.user || !walletData.value) return []
    
    try {
      const { data, error } = await supabase
        .from('wallet_transactions')
        .select('*')
        .eq('wallet_id', walletData.value.id)
        .order('created_at', { ascending: false })
        .limit(limit)
      
      if (error) throw error
      return data
    } catch (err) {
      console.error('Error fetching transactions:', err)
      return []
    }
  }

  function hasEnoughPoints(amount) {
    return points.value >= amount
  }

  // Watch for auth changes
  watch(() => authStore.user, (user) => {
    if (user) {
      fetchWallet()
    } else {
      walletData.value = null
    }
  }, { immediate: true })

  // Subscribe to wallet changes
  if (authStore.user) {
    const walletSubscription = supabase
      .channel('wallet_changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'wallets',
          filter: `user_id=eq.${authStore.user.id}`
        },
        (payload) => {
          if (payload.new) {
            walletData.value = payload.new
          }
        }
      )
      .subscribe()
  }

  return {
    walletData,
    points,
    formattedPoints,
    loading,
    error,
    fetchWallet,
    addPoints,
    usePoints,
    getTransactionHistory,
    hasEnoughPoints
  }
})