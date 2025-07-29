import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'

export const useAIServicesStore = defineStore('aiServices', () => {
  const loading = ref(false)
  const error = ref(null)
  
  // Data
  const categories = ref([])
  const subcategories = ref([])
  const services = ref([])

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
      const categoryId = service.category_id || service.subcategory?.category_id
      if (!grouped[categoryId]) {
        grouped[categoryId] = []
      }
      grouped[categoryId].push(service)
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

  // Fetch all subcategories
  async function fetchSubcategories() {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('service_subcategories')
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
      subcategories.value = data || []
    } catch (err) {
      console.error('Error fetching subcategories:', err)
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
          ),
          service_subcategories(
            id,
            name,
            slug,
            service_categories!inner(
              id,
              name,
              slug
            )
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

  // Create a new subcategory
  async function createSubcategory(subcategoryData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: createError } = await supabase
        .from('service_subcategories')
        .insert([{
          category_id: subcategoryData.category_id,
          slug: subcategoryData.slug,
          name: subcategoryData.name,
          description: subcategoryData.description,
          from_type: subcategoryData.from_type,
          from_icon: subcategoryData.from_icon,
          to_type: subcategoryData.to_type,
          to_icon: subcategoryData.to_icon,
          sort_order: subcategoryData.sort_order || 0,
          is_active: subcategoryData.is_active !== false
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
      
      subcategories.value.push(data)
      subcategories.value.sort((a, b) => a.sort_order - b.sort_order)
      
      return data
    } catch (err) {
      console.error('Error creating subcategory:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Update a subcategory
  async function updateSubcategory(subcategoryId, subcategoryData) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: updateError } = await supabase
        .from('service_subcategories')
        .update({
          category_id: subcategoryData.category_id,
          slug: subcategoryData.slug,
          name: subcategoryData.name,
          description: subcategoryData.description,
          from_type: subcategoryData.from_type,
          from_icon: subcategoryData.from_icon,
          to_type: subcategoryData.to_type,
          to_icon: subcategoryData.to_icon,
          sort_order: subcategoryData.sort_order,
          is_active: subcategoryData.is_active
        })
        .eq('id', subcategoryId)
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
      
      const index = subcategories.value.findIndex(sub => sub.id === subcategoryId)
      if (index !== -1) {
        subcategories.value[index] = data
      }
      
      return data
    } catch (err) {
      console.error('Error updating subcategory:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Delete a subcategory
  async function deleteSubcategory(subcategoryId) {
    loading.value = true
    error.value = null
    
    try {
      const { error: deleteError } = await supabase
        .from('service_subcategories')
        .delete()
        .eq('id', subcategoryId)
      
      if (deleteError) throw deleteError
      
      subcategories.value = subcategories.value.filter(sub => sub.id !== subcategoryId)
    } catch (err) {
      console.error('Error deleting subcategory:', err)
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
          subcategory_id: serviceData.subcategory_id,
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
          ),
          service_subcategories(
            id,
            name,
            slug,
            service_categories!inner(
              id,
              name,
              slug
            )
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
          subcategory_id: serviceData.subcategory_id,
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
          ),
          service_subcategories(
            id,
            name,
            slug,
            service_categories!inner(
              id,
              name,
              slug
            )
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

  // Fetch all data
  async function fetchAllData() {
    await Promise.all([
      fetchCategories(),
      fetchSubcategories(),
      fetchServices()
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
    subcategories,
    services,
    
    // Computed
    activeCategories,
    activeServices,
    servicesByCategory,
    
    // Actions
    fetchCategories,
    fetchSubcategories,
    fetchServices,
    fetchAllData,
    refreshData,
    
    // Categories CRUD
    createCategory,
    updateCategory,
    deleteCategory,
    
    // Subcategories CRUD
    createSubcategory,
    updateSubcategory,
    deleteSubcategory,
    
    // Services CRUD
    createService,
    updateService,
    deleteService
  }
})