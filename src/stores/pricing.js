import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'

export const usePricingStore = defineStore('pricing', () => {
  const loading = ref(false)
  const error = ref(null)
  
  // Data
  const servicePricing = ref([])
  const serviceAvailability = ref([])
  const priceHistory = ref([])
  const supportedCountries = ref([
    { code: 'US', name: 'États-Unis', flag: '🇺🇸' },
    { code: 'CI', name: 'Côte d\'Ivoire', flag: '🇨🇮' },
    { code: 'FR', name: 'France', flag: '🇫🇷' },
    { code: 'CA', name: 'Canada', flag: '🇨🇦' },
    { code: 'GB', name: 'Royaume-Uni', flag: '🇬🇧' },
    { code: 'DE', name: 'Allemagne', flag: '🇩🇪' },
    { code: 'JP', name: 'Japon', flag: '🇯🇵' },
    { code: 'BR', name: 'Brésil', flag: '🇧🇷' },
    { code: 'IN', name: 'Inde', flag: '🇮🇳' }
  ])

  // Computed
  const pricingWithDetails = computed(() => {
    return servicePricing.value.map(pricing => {
      const country = supportedCountries.value.find(c => c.code === pricing.country_code)
      return {
        ...pricing,
        country_name: country?.name || pricing.country_code,
        country_flag: country?.flag || '🏳️'
      }
    })
  })

  // Fetch service pricing by country
  async function fetchServicePricing(serviceId = null) {
    loading.value = true
    error.value = null
    
    try {
      let query = supabase
        .from('service_pricing_by_country')
        .select(`
          *,
          ai_services!inner(
            id,
            name,
            slug,
            provider,
            default_cost_points,
            api_cost_usd
          )
        `)
        .order('created_at', { ascending: false })
      
      if (serviceId) {
        query = query.eq('service_id', serviceId)
      }
      
      const { data, error: fetchError } = await query
      
      if (fetchError) throw fetchError
      servicePricing.value = data || []
    } catch (err) {
      console.error('Error fetching service pricing:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Fetch effective pricing (includes default prices)
  async function fetchEffectivePricing(serviceId = null) {
    loading.value = true
    error.value = null
    
    try {
      let query = supabase
        .from('service_effective_pricing')
        .select('*')
        .order('service_name', { ascending: true })
      
      if (serviceId) {
        query = query.eq('service_id', serviceId)
      }
      
      const { data, error: fetchError } = await query
      
      if (fetchError) throw fetchError
      
      // Transform data to match component expectations
      const transformedData = data.map(item => ({
        id: `${item.service_id}-${item.country_code}`,
        service_id: item.service_id,
        country_code: item.country_code,
        cost_points: item.effective_cost_points,
        ai_services: {
          name: item.service_name,
          slug: item.service_slug,
          api_cost_usd: item.api_cost_usd
        },
        pricing_type: item.pricing_type,
        updated_at: new Date().toISOString()
      }))
      
      servicePricing.value = transformedData
    } catch (err) {
      console.error('Error fetching effective pricing:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Fetch service availability
  async function fetchServiceAvailability() {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('service_availability')
        .select(`
          *,
          ai_services!inner(
            id,
            name,
            slug
          )
        `)
        .order('created_at', { ascending: false })
      
      if (fetchError) throw fetchError
      serviceAvailability.value = data || []
    } catch (err) {
      console.error('Error fetching service availability:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Fetch price history
  async function fetchPriceHistory(serviceId = null, limit = 50) {
    loading.value = true
    error.value = null
    
    try {
      let query = supabase
        .from('price_history')
        .select(`
          *,
          ai_services!inner(
            id,
            name,
            slug
          ),
          profiles(
            display_name,
            username
          )
        `)
        .order('created_at', { ascending: false })
        .limit(limit)
      
      if (serviceId) {
        query = query.eq('service_id', serviceId)
      }
      
      const { data, error: fetchError } = await query
      
      if (fetchError) throw fetchError
      priceHistory.value = data || []
    } catch (err) {
      console.error('Error fetching price history:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Create or update service pricing
  async function upsertServicePricing(serviceId, countryCode, costPoints) {
    loading.value = true
    error.value = null
    
    try {
      // First check if pricing already exists
      const { data: existing } = await supabase
        .from('service_pricing_by_country')
        .select('*')
        .eq('service_id', serviceId)
        .eq('country_code', countryCode)
        .single()
      
      let result
      if (existing) {
        // Update existing pricing
        const { data, error: updateError } = await supabase
          .from('service_pricing_by_country')
          .update({
            cost_points: costPoints,
            updated_at: new Date().toISOString()
          })
          .eq('service_id', serviceId)
          .eq('country_code', countryCode)
          .select(`
            *,
            ai_services!inner(
              id,
              name,
              slug,
              provider,
              default_cost_points,
              api_cost_usd
            )
          `)
          .single()
        
        if (updateError) throw updateError
        result = data
        
        // Record in price history
        await supabase
          .from('price_history')
          .insert({
            service_id: serviceId,
            country_code: countryCode,
            old_price_points: existing.cost_points,
            new_price_points: costPoints,
            old_api_cost: existing.api_cost_usd,
            new_api_cost: data.ai_services.api_cost_usd,
            reason: 'Admin update'
          })
      } else {
        // Create new pricing
        const { data, error: insertError } = await supabase
          .from('service_pricing_by_country')
          .insert({
            service_id: serviceId,
            country_code: countryCode,
            cost_points: costPoints
          })
          .select(`
            *,
            ai_services!inner(
              id,
              name,
              slug,
              provider,
              default_cost_points,
              api_cost_usd
            )
          `)
          .single()
        
        if (insertError) throw insertError
        result = data
        
        // Record in price history
        await supabase
          .from('price_history')
          .insert({
            service_id: serviceId,
            country_code: countryCode,
            old_price_points: null,
            new_price_points: costPoints,
            old_api_cost: null,
            new_api_cost: data.ai_services.api_cost_usd,
            reason: 'New pricing created'
          })
      }
      
      // Update local data
      const index = servicePricing.value.findIndex(
        p => p.service_id === serviceId && p.country_code === countryCode
      )
      
      if (index !== -1) {
        servicePricing.value[index] = result
      } else {
        servicePricing.value.push(result)
      }
      
      return result
    } catch (err) {
      console.error('Error upserting service pricing:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Delete service pricing (revert to default)
  async function deleteServicePricing(serviceId, countryCode) {
    loading.value = true
    error.value = null
    
    try {
      // Get current pricing for history
      const { data: current } = await supabase
        .from('service_pricing_by_country')
        .select('*')
        .eq('service_id', serviceId)
        .eq('country_code', countryCode)
        .single()
      
      // Delete custom pricing
      const { error: deleteError } = await supabase
        .from('service_pricing_by_country')
        .delete()
        .eq('service_id', serviceId)
        .eq('country_code', countryCode)
      
      if (deleteError) throw deleteError
      
      // Record in history
      if (current) {
        await supabase
          .from('price_history')
          .insert({
            service_id: serviceId,
            country_code: countryCode,
            old_price_points: current.cost_points,
            new_price_points: null,
            reason: 'Reverted to default pricing'
          })
      }
      
      // Remove from local data
      servicePricing.value = servicePricing.value.filter(
        p => !(p.service_id === serviceId && p.country_code === countryCode)
      )
      
    } catch (err) {
      console.error('Error deleting service pricing:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Update service availability
  async function updateServiceAvailability(serviceId, countryCode, isAvailable) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: upsertError } = await supabase
        .from('service_availability')
        .upsert({
          service_id: serviceId,
          country_code: countryCode,
          is_available: isAvailable
        })
        .select(`
          *,
          ai_services!inner(
            id,
            name,
            slug
          )
        `)
        .single()
      
      if (upsertError) throw upsertError
      
      // Update local data
      const index = serviceAvailability.value.findIndex(
        a => a.service_id === serviceId && a.country_code === countryCode
      )
      
      if (index !== -1) {
        serviceAvailability.value[index] = data
      } else {
        serviceAvailability.value.push(data)
      }
      
      return data
    } catch (err) {
      console.error('Error updating service availability:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Utility functions
  function getCountryName(countryCode) {
    const country = supportedCountries.value.find(c => c.code === countryCode)
    return country?.name || countryCode
  }

  function getCountryFlag(countryCode) {
    const country = supportedCountries.value.find(c => c.code === countryCode)
    return country?.flag || '🏳️'
  }

  function calculateProfitMargin(pricing) {
    if (!pricing.ai_services?.api_cost_usd || pricing.ai_services.api_cost_usd === 0) {
      return 0
    }
    
    const pointsValue = pricing.cost_points * 0.01 // 1 point = 0.01 EUR
    const apiCost = pricing.ai_services.api_cost_usd
    const profit = pointsValue - apiCost
    return ((profit / pointsValue) * 100).toFixed(1)
  }

  // Fetch all data
  async function fetchAllData() {
    await Promise.all([
      fetchEffectivePricing(),
      fetchServiceAvailability(),
      fetchPriceHistory()
    ])
  }

  return {
    // State
    loading,
    error,
    servicePricing,
    serviceAvailability,
    priceHistory,
    supportedCountries,
    
    // Computed
    pricingWithDetails,
    
    // Actions
    fetchServicePricing,
    fetchEffectivePricing,
    fetchServiceAvailability,
    fetchPriceHistory,
    fetchAllData,
    upsertServicePricing,
    deleteServicePricing,
    updateServiceAvailability,
    
    // Utilities
    getCountryName,
    getCountryFlag,
    calculateProfitMargin
  }
})