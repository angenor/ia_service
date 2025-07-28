import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'

export const useAdminStore = defineStore('admin', () => {
  // État général
  const isLoading = ref(false)
  const error = ref(null)

  // États des données
  const profitabilityData = ref([])
  const serviceCategories = ref([])
  const serviceSubcategories = ref([])
  const aiServices = ref([])
  const servicePricing = ref([])
  const serviceAvailability = ref([])
  const promotions = ref([])
  const promotionUsage = ref([])
  const users = ref([])
  const wallets = ref([])
  const walletTransactions = ref([])
  const serviceUsage = ref([])
  const systemConfig = ref({})
  const priceHistory = ref([])

  // Getters
  const totalUsers = computed(() => users.value.length)
  const activeServices = computed(() => aiServices.value.filter(s => s.is_active))
  const totalRevenue = computed(() => {
    return walletTransactions.value
      .filter(t => t.type === 'purchase')
      .reduce((sum, t) => sum + t.amount, 0)
  })

  // Actions génériques
  function setLoading(status) {
    isLoading.value = status
  }

  function setError(errorMessage) {
    error.value = errorMessage
  }

  function clearError() {
    error.value = null
  }

  // Dashboard de Rentabilité
  async function fetchProfitabilityData() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_profitability')
        .select('*')
        .order('usage_date', { ascending: false })
      
      if (dbError) throw dbError
      profitabilityData.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function fetchFinancialReports(dateRange = '30 days') {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .rpc('get_financial_report', { date_range: dateRange })
      
      if (dbError) throw dbError
      return data
    } catch (err) {
      setError(err.message)
      return null
    } finally {
      setLoading(false)
    }
  }

  // Gestion des catégories
  async function fetchServiceCategories() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_categories')
        .select('*')
        .order('sort_order', { ascending: true })
      
      if (dbError) throw dbError
      serviceCategories.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function createServiceCategory(categoryData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_categories')
        .insert([categoryData])
        .select()
      
      if (dbError) throw dbError
      serviceCategories.value.push(data[0])
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  async function updateServiceCategory(id, categoryData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_categories')
        .update(categoryData)
        .eq('id', id)
        .select()
      
      if (dbError) throw dbError
      const index = serviceCategories.value.findIndex(c => c.id === id)
      if (index !== -1) {
        serviceCategories.value[index] = data[0]
      }
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  async function deleteServiceCategory(id) {
    setLoading(true)
    clearError()
    try {
      const { error: dbError } = await supabase
        .from('service_categories')
        .delete()
        .eq('id', id)
      
      if (dbError) throw dbError
      serviceCategories.value = serviceCategories.value.filter(c => c.id !== id)
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Gestion des sous-catégories
  async function fetchServiceSubcategories() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_subcategories')
        .select(`
          *,
          service_categories (
            id,
            name,
            icon
          )
        `)
        .order('created_at', { ascending: false })
      
      if (dbError) throw dbError
      serviceSubcategories.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function createServiceSubcategory(subcategoryData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_subcategories')
        .insert([subcategoryData])
        .select()
      
      if (dbError) throw dbError
      await fetchServiceSubcategories() // Recharger pour avoir les relations
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  async function updateServiceSubcategory(id, subcategoryData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_subcategories')
        .update(subcategoryData)
        .eq('id', id)
        .select()
      
      if (dbError) throw dbError
      await fetchServiceSubcategories() // Recharger pour avoir les relations
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  async function deleteServiceSubcategory(id) {
    setLoading(true)
    clearError()
    try {
      const { error: dbError } = await supabase
        .from('service_subcategories')
        .delete()
        .eq('id', id)
      
      if (dbError) throw dbError
      serviceSubcategories.value = serviceSubcategories.value.filter(s => s.id !== id)
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Gestion des services IA
  async function fetchAiServices() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('ai_services')
        .select(`
          *,
          service_subcategories (
            id,
            name,
            service_categories (
              id,
              name
            )
          )
        `)
        .order('created_at', { ascending: false })
      
      if (dbError) throw dbError
      aiServices.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function createAiService(serviceData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('ai_services')
        .insert([serviceData])
        .select()
      
      if (dbError) throw dbError
      await fetchAiServices() // Recharger pour avoir les relations
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  async function updateAiService(id, serviceData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('ai_services')
        .update(serviceData)
        .eq('id', id)
        .select()
      
      if (dbError) throw dbError
      await fetchAiServices() // Recharger pour avoir les relations
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  async function deleteAiService(id) {
    setLoading(true)
    clearError()
    try {
      const { error: dbError } = await supabase
        .from('ai_services')
        .delete()
        .eq('id', id)
      
      if (dbError) throw dbError
      aiServices.value = aiServices.value.filter(s => s.id !== id)
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Gestion tarifaire
  async function fetchServicePricing() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_pricing_by_country')
        .select(`
          *,
          ai_services (
            id,
            name
          )
        `)
        .order('created_at', { ascending: false })
      
      if (dbError) throw dbError
      servicePricing.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function updateServicePricing(serviceId, country, pricingData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_pricing_by_country')
        .upsert([{
          service_id: serviceId,
          country_code: country,
          ...pricingData
        }])
        .select()
      
      if (dbError) throw dbError
      await fetchServicePricing() // Recharger
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Gestion des promotions
  async function fetchPromotions() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('promotions')
        .select('*')
        .order('created_at', { ascending: false })
      
      if (dbError) throw dbError
      promotions.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function createPromotion(promotionData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('promotions')
        .insert([promotionData])
        .select()
      
      if (dbError) throw dbError
      promotions.value.push(data[0])
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  async function updatePromotion(id, promotionData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('promotions')
        .update(promotionData)
        .eq('id', id)
        .select()
      
      if (dbError) throw dbError
      const index = promotions.value.findIndex(p => p.id === id)
      if (index !== -1) {
        promotions.value[index] = data[0]
      }
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  async function deletePromotion(id) {
    setLoading(true)
    clearError()
    try {
      const { error: dbError } = await supabase
        .from('promotions')
        .delete()
        .eq('id', id)
      
      if (dbError) throw dbError
      promotions.value = promotions.value.filter(p => p.id !== id)
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Gestion des utilisateurs
  async function fetchUsers() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('profiles')
        .select(`
          *,
          wallets (
            id,
            balance,
            currency,
            created_at,
            updated_at
          )
        `)
        .order('created_at', { ascending: false })
      
      if (dbError) throw dbError
      users.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  // Nouvelle fonction pour obtenir des statistiques utilisateur détaillées
  async function fetchUserStatistics() {
    setLoading(true)
    clearError()
    try {
      // Statistiques générales
      const { data: generalStats, error: generalError } = await supabase
        .rpc('get_user_statistics')
      
      if (generalError) {
        console.warn('Statistiques générales non disponibles:', generalError)
      }

      // Utilisation par pays
      const { data: countryStats, error: countryError } = await supabase
        .from('profiles')
        .select('country_code')
        .then(({ data }) => {
          const countryCounts = {}
          data?.forEach(profile => {
            countryCounts[profile.country_code] = (countryCounts[profile.country_code] || 0) + 1
          })
          return { data: countryCounts, error: null }
        })

      return {
        general: generalStats || {},
        byCountry: countryStats || {}
      }
    } catch (err) {
      setError(err.message)
      return null
    } finally {
      setLoading(false)
    }
  }

  async function updateUserStatus(userId, statusData) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('profiles')
        .update(statusData)
        .eq('id', userId)
        .select()
      
      if (dbError) throw dbError
      const index = users.value.findIndex(u => u.id === userId)
      if (index !== -1) {
        users.value[index] = { ...users.value[index], ...data[0] }
      }
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Nouvelle fonction pour forcer la synchronisation d'un utilisateur
  async function syncUserProfile(userId) {
    setLoading(true)
    clearError()
    try {
      // Déclencher la fonction de mise à jour du profil via la table auth.users
      const { data, error: dbError } = await supabase
        .rpc('handle_user_update_manual', { user_id: userId })
      
      if (dbError) {
        console.warn('Sync manuel non disponible, utilisation de la méthode standard:', dbError)
        // Fallback: recharger simplement les données utilisateur
        await fetchUsers()
        return true
      }
      
      return data
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Fonction pour obtenir l'historique d'un utilisateur 
  async function fetchUserActivity(userId, limit = 50) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_usage')
        .select(`
          *,
          ai_services (
            id,
            name,
            provider
          )
        `)
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(limit)
      
      if (dbError) throw dbError
      return data || []
    } catch (err) {
      setError(err.message)
      return []
    } finally {
      setLoading(false)
    }
  }

  // Configuration système
  async function fetchSystemConfig() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('system_config')
        .select('*')
      
      if (dbError) throw dbError
      
      // Transformer le tableau en objet clé-valeur
      const configObject = {}
      if (data && data.length > 0) {
        data.forEach(config => {
          configObject[config.key] = config.value
        })
      }
      systemConfig.value = configObject
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function updateSystemConfig(key, value, description = null) {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('system_config')
        .upsert([{
          key,
          value,
          description,
          updated_at: new Date().toISOString()
        }])
        .select()
      
      if (dbError) throw dbError
      
      // Mettre à jour la configuration locale
      systemConfig.value[key] = value
      
      return data[0]
    } catch (err) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Statistiques et monitoring
  async function fetchServiceUsage(dateRange = '30 days') {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('service_usage')
        .select(`
          *,
          ai_services (
            id,
            name
          ),
          profiles (
            id,
            username
          )
        `)
        .gte('created_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
        .order('created_at', { ascending: false })
      
      if (dbError) throw dbError
      serviceUsage.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function fetchWalletTransactions() {
    setLoading(true)
    clearError()
    try {
      const { data, error: dbError } = await supabase
        .from('wallet_transactions')
        .select(`
          *,
          wallets (
            id,
            profiles (
              id,
              username
            )
          )
        `)
        .order('created_at', { ascending: false })
        .limit(1000)
      
      if (dbError) throw dbError
      walletTransactions.value = data || []
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  // Fonction pour créer la configuration système par défaut si elle n'existe pas
  async function ensureSystemConfigExists() {
    try {
      const { data } = await supabase
        .from('system_config')
        .select('key')
      
      if (!data || data.length === 0) {
        // Créer la configuration par défaut selon le schéma
        const defaultConfig = [
          { key: 'points_per_dollar', value: 100, description: 'Number of points per USD' },
          { key: 'min_wallet_recharge', value: 500, description: 'Minimum points for wallet recharge' },
          { key: 'new_service_days', value: 30, description: 'Days to show new badge on services' },
          { key: 'api_rate_limit', value: { requests_per_minute: 60 }, description: 'API rate limiting configuration' },
          { key: 'supported_countries', value: ["US", "CI", "FR", "CA", "GB", "DE", "JP", "BR", "IN"], description: 'List of supported countries' }
        ]
        
        await supabase
          .from('system_config')
          .insert(defaultConfig)
      }
    } catch (error) {
      console.warn('Erreur lors de la création de la configuration système:', error)
    }
  }

  // Fonction d'initialisation
  async function initializeAdminData() {
    setLoading(true)
    try {
      // S'assurer que la configuration système existe
      await ensureSystemConfigExists()
      
      await Promise.all([
        fetchServiceCategories(),
        fetchServiceSubcategories(),
        fetchAiServices(),
        fetchServicePricing(),
        fetchPromotions(),
        fetchUsers(),
        fetchSystemConfig(),
        fetchProfitabilityData(),
        fetchServiceUsage(),
        fetchWalletTransactions()
      ])
    } catch (err) {
      setError('Erreur lors du chargement des données d\'administration')
      console.error('Erreur admin:', err)
    } finally {
      setLoading(false)
    }
  }

  return {
    // État
    isLoading,
    error,
    profitabilityData,
    serviceCategories,
    serviceSubcategories,
    aiServices,
    servicePricing,
    serviceAvailability,
    promotions,
    promotionUsage,
    users,
    wallets,
    walletTransactions,
    serviceUsage,
    systemConfig,
    priceHistory,

    // Computed
    totalUsers,
    activeServices,
    totalRevenue,

    // Actions génériques
    setLoading,
    setError,
    clearError,

    // Dashboard
    fetchProfitabilityData,
    fetchFinancialReports,

    // Catégories
    fetchServiceCategories,
    createServiceCategory,
    updateServiceCategory,
    deleteServiceCategory,

    // Sous-catégories
    fetchServiceSubcategories,
    createServiceSubcategory,
    updateServiceSubcategory,
    deleteServiceSubcategory,

    // Services IA
    fetchAiServices,
    createAiService,
    updateAiService,
    deleteAiService,

    // Tarification
    fetchServicePricing,
    updateServicePricing,

    // Promotions
    fetchPromotions,
    createPromotion,
    updatePromotion,
    deletePromotion,

    // Utilisateurs
    fetchUsers,
    fetchUserStatistics,
    updateUserStatus,
    syncUserProfile,
    fetchUserActivity,

    // Configuration
    fetchSystemConfig,
    updateSystemConfig,
    ensureSystemConfigExists,

    // Monitoring
    fetchServiceUsage,
    fetchWalletTransactions,

    // Initialisation
    initializeAdminData
  }
})