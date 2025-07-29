import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'

export const usePromotionsStore = defineStore('promotions', () => {
  const loading = ref(false)
  const error = ref(null)
  
  // Data
  const promotions = ref([])
  const promotionUsage = ref([])

  // Computed
  const activePromotions = computed(() => {
    const now = new Date()
    return promotions.value.filter(promotion => 
      promotion.is_active && 
      new Date(promotion.valid_from) <= now &&
      new Date(promotion.valid_until) > now
    )
  })

  const expiredPromotions = computed(() => {
    const now = new Date()
    return promotions.value.filter(promotion => 
      !promotion.is_active || new Date(promotion.valid_until) <= now
    )
  })

  const promotionsWithUsage = computed(() => {
    return promotions.value.map(promotion => {
      const usage = promotionUsage.value.filter(u => u.promotion_id === promotion.id)
      return {
        ...promotion,
        current_usage: usage.length,
        unique_users: new Set(usage.map(u => u.user_id)).size
      }
    })
  })

  // Fetch all promotions
  async function fetchPromotions() {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('promotions')
        .select('*')
        .order('created_at', { ascending: false })
      
      if (fetchError) throw fetchError
      promotions.value = data || []
    } catch (err) {
      console.error('Error fetching promotions:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Fetch promotion usage statistics
  async function fetchPromotionUsage() {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('promotion_usage')
        .select(`
          *,
          promotions!inner(
            id,
            code,
            name
          ),
          profiles!inner(
            id,
            username,
            display_name
          )
        `)
        .order('created_at', { ascending: false })
      
      if (fetchError) throw fetchError
      promotionUsage.value = data || []
    } catch (err) {
      console.error('Error fetching promotion usage:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Get promotion usage for a specific promotion
  async function fetchPromotionUsageById(promotionId) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('promotion_usage')
        .select(`
          *,
          profiles!inner(
            id,
            username,
            display_name
          )
        `)
        .eq('promotion_id', promotionId)
        .order('created_at', { ascending: false })
      
      if (fetchError) throw fetchError
      return data || []
    } catch (err) {
      console.error('Error fetching promotion usage:', err)
      error.value = err.message
      return []
    } finally {
      loading.value = false
    }
  }

  // Create a new promotion
  async function createPromotion(promotionData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: createError } = await supabase
        .from('promotions')
        .insert([{
          code: promotionData.code,
          name: promotionData.name,
          description: promotionData.description,
          discount_type: promotionData.discount_type,
          discount_value: promotionData.discount_value,
          min_purchase_points: promotionData.min_purchase_points,
          max_uses_total: promotionData.max_uses_total,
          max_uses_per_user: promotionData.max_uses_per_user || 1,
          valid_from: promotionData.valid_from,
          valid_until: promotionData.valid_until,
          service_ids: promotionData.service_ids || [],
          country_codes: promotionData.country_codes || [],
          is_active: promotionData.is_active !== false
        }])
        .select()
        .single()
      
      if (createError) throw createError
      
      promotions.value.unshift(data)
      return data
    } catch (err) {
      console.error('Error creating promotion:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Update a promotion
  async function updatePromotion(promotionId, promotionData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: updateError } = await supabase
        .from('promotions')
        .update({
          code: promotionData.code,
          name: promotionData.name,
          description: promotionData.description,
          discount_type: promotionData.discount_type,
          discount_value: promotionData.discount_value,
          min_purchase_points: promotionData.min_purchase_points,
          max_uses_total: promotionData.max_uses_total,
          max_uses_per_user: promotionData.max_uses_per_user,
          valid_from: promotionData.valid_from,
          valid_until: promotionData.valid_until,
          service_ids: promotionData.service_ids,
          country_codes: promotionData.country_codes,
          is_active: promotionData.is_active
        })
        .eq('id', promotionId)
        .select()
        .single()
      
      if (updateError) throw updateError
      
      const index = promotions.value.findIndex(p => p.id === promotionId)
      if (index !== -1) {
        promotions.value[index] = data
      }
      
      return data
    } catch (err) {
      console.error('Error updating promotion:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Delete a promotion
  async function deletePromotion(promotionId) {
    loading.value = true
    error.value = null
    
    try {
      const { error: deleteError } = await supabase
        .from('promotions')
        .delete()
        .eq('id', promotionId)
      
      if (deleteError) throw deleteError
      
      promotions.value = promotions.value.filter(p => p.id !== promotionId)
    } catch (err) {
      console.error('Error deleting promotion:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Activate/Deactivate a promotion
  async function togglePromotionStatus(promotionId, isActive) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: updateError } = await supabase
        .from('promotions')
        .update({ is_active: isActive })
        .eq('id', promotionId)
        .select()
        .single()
      
      if (updateError) throw updateError
      
      const index = promotions.value.findIndex(p => p.id === promotionId)
      if (index !== -1) {
        promotions.value[index] = data
      }
      
      return data
    } catch (err) {
      console.error('Error toggling promotion status:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Validate promotion code
  async function validatePromotionCode(code, userId, serviceId = null, countryCode = null) {
    try {
      const { data: promotion, error: fetchError } = await supabase
        .from('promotions')
        .select('*')
        .eq('code', code)
        .eq('is_active', true)
        .single()
      
      if (fetchError) throw new Error('Code promotion invalide')
      
      const now = new Date()
      if (new Date(promotion.valid_from) > now || new Date(promotion.valid_until) <= now) {
        throw new Error('Code promotion expiré')
      }

      // Check usage limits
      if (promotion.max_uses_total) {
        const { count } = await supabase
          .from('promotion_usage')
          .select('*', { count: 'exact', head: true })
          .eq('promotion_id', promotion.id)
        
        if (count >= promotion.max_uses_total) {
          throw new Error('Limite d\'utilisation atteinte')
        }
      }

      if (promotion.max_uses_per_user) {
        const { count } = await supabase
          .from('promotion_usage')
          .select('*', { count: 'exact', head: true })
          .eq('promotion_id', promotion.id)
          .eq('user_id', userId)
        
        if (count >= promotion.max_uses_per_user) {
          throw new Error('Limite d\'utilisation par utilisateur atteinte')
        }
      }

      // Check service restrictions
      if (promotion.service_ids && promotion.service_ids.length > 0 && serviceId) {
        if (!promotion.service_ids.includes(serviceId)) {
          throw new Error('Promotion non applicable à ce service')
        }
      }

      // Check country restrictions
      if (promotion.country_codes && promotion.country_codes.length > 0 && countryCode) {
        if (!promotion.country_codes.includes(countryCode)) {
          throw new Error('Promotion non disponible dans votre pays')
        }
      }

      return promotion
    } catch (err) {
      console.error('Error validating promotion code:', err)
      throw err
    }
  }

  // Record promotion usage
  async function recordPromotionUsage(promotionId, userId, transactionId = null) {
    try {
      const { data, error: insertError } = await supabase
        .from('promotion_usage')
        .insert([{
          promotion_id: promotionId,
          user_id: userId,
          transaction_id: transactionId
        }])
        .select()
        .single()
      
      if (insertError) throw insertError
      
      promotionUsage.value.push(data)
      return data
    } catch (err) {
      console.error('Error recording promotion usage:', err)
      throw err
    }
  }

  // Calculate discount amount
  function calculateDiscount(promotion, amount) {
    if (promotion.discount_type === 'percentage') {
      return Math.round(amount * (promotion.discount_value / 100))
    } else if (promotion.discount_type === 'fixed_points') {
      return Math.min(promotion.discount_value, amount)
    }
    return 0
  }

  // Fetch all data
  async function fetchAllData() {
    await Promise.all([
      fetchPromotions(),
      fetchPromotionUsage()
    ])
  }

  return {
    // State
    loading,
    error,
    promotions,
    promotionUsage,
    
    // Computed
    activePromotions,
    expiredPromotions,
    promotionsWithUsage,
    
    // Actions
    fetchPromotions,
    fetchPromotionUsage,
    fetchPromotionUsageById,
    fetchAllData,
    createPromotion,
    updatePromotion,
    deletePromotion,
    togglePromotionStatus,
    validatePromotionCode,
    recordPromotionUsage,
    
    // Utilities
    calculateDiscount
  }
})