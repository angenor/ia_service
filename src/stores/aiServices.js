import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'

export const useAIServicesStore = defineStore('aiServices', () => {
  const loading = ref(false)
  const error = ref(null)
  
  // Data
  const categories = ref([])
  const abilities = ref([])
  const services = ref([])
  const serviceModelAbilities = ref([])

  // Computed
  const activeCategories = computed(() => 
    categories.value.filter(cat => cat.is_active)
  )

  const activeServices = computed(() => 
    services.value.filter(service => service.is_active)
  )

  const servicesByCategory = computed(() => {
    const grouped = {}
    services.value.forEach(service => {
      const categoryId = service.category_id
      if (!grouped[categoryId]) {
        grouped[categoryId] = []
      }
      grouped[categoryId].push(service)
    })
    return grouped
  })

  // Get abilities by category
  const abilitiesByCategory = computed(() => {
    const grouped = {}
    abilities.value.forEach(ability => {
      if (!grouped[ability.category_id]) {
        grouped[ability.category_id] = []
      }
      grouped[ability.category_id].push(ability)
    })
    return grouped
  })

  // Get services by ability
  const servicesByAbility = computed(() => {
    const grouped = {}
    serviceModelAbilities.value.forEach(sma => {
      if (!grouped[sma.ability_id]) {
        grouped[sma.ability_id] = []
      }
      const service = services.value.find(s => s.id === sma.service_id)
      if (service) {
        grouped[sma.ability_id].push({
          ...service,
          cost_multiplier: sma.cost_multiplier,
          ability_config: sma.config
        })
      }
    })
    return grouped
  })

  // Fetch all categories
  async function fetchCategories() {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('service_categories')
        .select('*')
        .order('sort_order', { ascending: true })
      
      if (fetchError) throw fetchError
      categories.value = data || []
    } catch (err) {
      console.error('Error fetching categories:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }


  // Fetch all services
  async function fetchServices() {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('ai_services')
        .select(`
          *,
          service_categories(
            id,
            name,
            slug
          )
        `)
        .order('created_at', { ascending: false })
      
      if (fetchError) throw fetchError
      services.value = data || []
    } catch (err) {
      console.error('Error fetching services:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Fetch service model abilities relationships
  async function fetchServiceModelAbilities() {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('service_model_abilities')
        .select(`
          *,
          ai_services(id, name, slug),
          service_abilities(id, name, slug, from_type, to_type)
        `)
        .eq('is_active', true)
      
      if (fetchError) throw fetchError
      serviceModelAbilities.value = data || []
    } catch (err) {
      console.error('Error fetching service model abilities:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Create a new category
  async function createCategory(categoryData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: createError } = await supabase
        .from('service_categories')
        .insert([{
          slug: categoryData.slug,
          name: categoryData.name,
          description: categoryData.description,
          icon: categoryData.icon,
          sort_order: categoryData.sort_order || 0,
          is_active: categoryData.is_active !== false
        }])
        .select()
        .single()
      
      if (createError) throw createError
      
      categories.value.push(data)
      categories.value.sort((a, b) => a.sort_order - b.sort_order)
      
      return data
    } catch (err) {
      console.error('Error creating category:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Update a category
  async function updateCategory(categoryId, categoryData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: updateError } = await supabase
        .from('service_categories')
        .update({
          slug: categoryData.slug,
          name: categoryData.name,
          description: categoryData.description,
          icon: categoryData.icon,
          sort_order: categoryData.sort_order,
          is_active: categoryData.is_active
        })
        .eq('id', categoryId)
        .select()
        .single()
      
      if (updateError) throw updateError
      
      const index = categories.value.findIndex(cat => cat.id === categoryId)
      if (index !== -1) {
        categories.value[index] = data
      }
      
      return data
    } catch (err) {
      console.error('Error updating category:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Delete a category
  async function deleteCategory(categoryId) {
    loading.value = true
    error.value = null
    
    try {
      const { error: deleteError } = await supabase
        .from('service_categories')
        .delete()
        .eq('id', categoryId)
      
      if (deleteError) throw deleteError
      
      categories.value = categories.value.filter(cat => cat.id !== categoryId)
    } catch (err) {
      console.error('Error deleting category:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }




  // Create a new service
  async function createService(serviceData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: createError } = await supabase
        .from('ai_services')
        .insert([{
          category_id: serviceData.category_id,
          slug: serviceData.slug,
          name: serviceData.name,
          description: serviceData.description,
          provider: serviceData.provider,
          api_endpoint: serviceData.api_endpoint,
          icon: serviceData.icon,
          png: serviceData.png,
          video: serviceData.video,
          default_cost_points: serviceData.default_cost_points,
          api_cost_usd: serviceData.api_cost_usd,
          config: serviceData.config || {},
          is_active: serviceData.is_active !== false,
          is_new: serviceData.is_new || false,
          new_until: serviceData.new_until,
          features: serviceData.features || [],
          limitations: serviceData.limitations || {}
        }])
        .select(`
          *,
          service_categories(
            id,
            name,
            slug
          )
        `)
        .single()
      
      if (createError) throw createError
      
      services.value.unshift(data)
      
      return data
    } catch (err) {
      console.error('Error creating service:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Update a service
  async function updateService(serviceId, serviceData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: updateError } = await supabase
        .from('ai_services')
        .update({
          category_id: serviceData.category_id,
          slug: serviceData.slug,
          name: serviceData.name,
          description: serviceData.description,
          provider: serviceData.provider,
          api_endpoint: serviceData.api_endpoint,
          icon: serviceData.icon,
          png: serviceData.png,
          video: serviceData.video,
          default_cost_points: serviceData.default_cost_points,
          api_cost_usd: serviceData.api_cost_usd,
          config: serviceData.config,
          is_active: serviceData.is_active,
          is_new: serviceData.is_new,
          new_until: serviceData.new_until,
          features: serviceData.features,
          limitations: serviceData.limitations
        })
        .eq('id', serviceId)
        .select(`
          *,
          service_categories(
            id,
            name,
            slug
          )
        `)
        .single()
      
      if (updateError) throw updateError
      
      const index = services.value.findIndex(service => service.id === serviceId)
      if (index !== -1) {
        services.value[index] = data
      }
      
      return data
    } catch (err) {
      console.error('Error updating service:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Delete a service
  async function deleteService(serviceId) {
    loading.value = true
    error.value = null
    
    try {
      const { error: deleteError } = await supabase
        .from('ai_services')
        .delete()
        .eq('id', serviceId)
      
      if (deleteError) throw deleteError
      
      services.value = services.value.filter(service => service.id !== serviceId)
    } catch (err) {
      console.error('Error deleting service:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Fetch all abilities
  async function fetchAbilities() {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('service_abilities')
        .select(`
          *,
          service_categories!inner(
            id,
            name,
            slug
          )
        `)
        .order('sort_order', { ascending: true })
      
      if (fetchError) throw fetchError
      abilities.value = data || []
    } catch (err) {
      console.error('Error fetching abilities:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Create a new ability
  async function createAbility(abilityData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: createError } = await supabase
        .from('service_abilities')
        .insert([{
          category_id: abilityData.category_id,
          slug: abilityData.slug,
          name: abilityData.name,
          description: abilityData.description,
          from_type: abilityData.from_type,
          from_icon: abilityData.from_icon,
          to_type: abilityData.to_type,
          to_icon: abilityData.to_icon,
          sort_order: abilityData.sort_order,
          is_active: abilityData.is_active
        }])
        .select(`
          *,
          service_categories!inner(
            id,
            name,
            slug
          )
        `)
        .single()
      
      if (createError) throw createError
      
      abilities.value.push(data)
      abilities.value.sort((a, b) => a.sort_order - b.sort_order)
      
      return data
    } catch (err) {
      console.error('Error creating ability:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Update an ability
  async function updateAbility(abilityId, abilityData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: updateError } = await supabase
        .from('service_abilities')
        .update({
          category_id: abilityData.category_id,
          slug: abilityData.slug,
          name: abilityData.name,
          description: abilityData.description,
          from_type: abilityData.from_type,
          from_icon: abilityData.from_icon,
          to_type: abilityData.to_type,
          to_icon: abilityData.to_icon,
          sort_order: abilityData.sort_order,
          is_active: abilityData.is_active
        })
        .eq('id', abilityId)
        .select(`
          *,
          service_categories!inner(
            id,
            name,
            slug
          )
        `)
        .single()
      
      if (updateError) throw updateError
      
      const index = abilities.value.findIndex(ability => ability.id === abilityId)
      if (index !== -1) {
        abilities.value[index] = data
      }
      
      return data
    } catch (err) {
      console.error('Error updating ability:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Delete an ability
  async function deleteAbility(abilityId) {
    loading.value = true
    error.value = null
    
    try {
      const { error: deleteError } = await supabase
        .from('service_abilities')
        .delete()
        .eq('id', abilityId)
      
      if (deleteError) throw deleteError
      
      abilities.value = abilities.value.filter(ability => ability.id !== abilityId)
    } catch (err) {
      console.error('Error deleting ability:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Get abilities for a specific service
  function getServiceAbilities(serviceId) {
    return serviceModelAbilities.value
      .filter(sma => sma.service_id === serviceId && sma.is_active)
      .map(sma => ({
        ...sma.service_abilities,
        cost_multiplier: sma.cost_multiplier,
        config: sma.config
      }))
  }

  // Get count of models using an ability
  function getAbilityModelsCount(abilityId) {
    return serviceModelAbilities.value
      .filter(sma => sma.ability_id === abilityId && sma.is_active)
      .length
  }

  // Update service abilities (many-to-many)
  async function updateServiceAbilities(serviceId, abilities) {
    loading.value = true
    error.value = null
    
    try {
      // Delete existing abilities for this service
      const { error: deleteError } = await supabase
        .from('service_model_abilities')
        .delete()
        .eq('service_id', serviceId)
      
      if (deleteError) throw deleteError
      
      // Insert new abilities
      if (abilities.length > 0) {
        const { error: insertError } = await supabase
          .from('service_model_abilities')
          .insert(
            abilities.map(ability => ({
              service_id: serviceId,
              ability_id: ability.id,
              cost_multiplier: ability.cost_multiplier || 1.0,
              config: ability.config || {},
              is_active: ability.is_active !== false
            }))
          )
        
        if (insertError) throw insertError
      }
      
      // Refresh the service model abilities
      await fetchServiceModelAbilities()
    } catch (err) {
      console.error('Error updating service abilities:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Update ability models (many-to-many)
  async function updateAbilityModels(abilityId, services) {
    loading.value = true
    error.value = null
    
    try {
      // Delete existing services for this ability
      const { error: deleteError } = await supabase
        .from('service_model_abilities')
        .delete()
        .eq('ability_id', abilityId)
      
      if (deleteError) throw deleteError
      
      // Insert new services
      if (services.length > 0) {
        const { error: insertError } = await supabase
          .from('service_model_abilities')
          .insert(
            services.map(service => ({
              service_id: service.id,
              ability_id: abilityId,
              cost_multiplier: service.cost_multiplier || 1.0,
              config: service.config || {},
              is_active: service.is_active !== false
            }))
          )
        
        if (insertError) throw insertError
      }
      
      // Refresh the service model abilities
      await fetchServiceModelAbilities()
    } catch (err) {
      console.error('Error updating ability models:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Fetch all data
  async function fetchAllData() {
    await Promise.all([
      fetchCategories(),
      fetchAbilities(),
      fetchServices(),
      fetchServiceModelAbilities()
    ])
  }

  // Refresh all data
  function refreshData() {
    return fetchAllData()
  }

  return {
    // State
    loading,
    error,
    categories,
    abilities,
    services,
    serviceModelAbilities,
    
    // Computed
    activeCategories,
    activeServices,
    servicesByCategory,
    abilitiesByCategory,
    servicesByAbility,
    
    // Actions
    fetchCategories,
    fetchAbilities,
    fetchServices,
    fetchServiceModelAbilities,
    fetchAllData,
    refreshData,
    
    // Categories CRUD
    createCategory,
    updateCategory,
    deleteCategory,
    
    
    // Abilities CRUD
    createAbility,
    updateAbility,
    deleteAbility,
    
    // Services CRUD
    createService,
    updateService,
    deleteService,
    
    // Many-to-many helpers
    getServiceAbilities,
    getAbilityModelsCount,
    updateServiceAbilities,
    updateAbilityModels
  }
})