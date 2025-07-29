import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'

export const useAdminDashboardStore = defineStore('adminDashboard', () => {
  const loading = ref(false)
  const error = ref(null)
  
  // Dashboard data
  const totalRevenue = ref(0)
  const totalUsers = ref(0)
  const activeServices = ref(0)
  const profitMargin = ref(0)
  const recentTransactions = ref([])
  const topServices = ref([])
  const revenueData = ref([])
  const usageData = ref([])
  const dateRange = ref('last30Days')

  // Computed values
  const formattedRevenue = computed(() => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR'
    }).format(totalRevenue.value)
  })

  const formattedUsers = computed(() => {
    return new Intl.NumberFormat().format(totalUsers.value)
  })

  // Fetch all dashboard statistics
  async function fetchDashboardStats() {
    loading.value = true
    error.value = null
    
    try {
      await Promise.all([
        fetchTotalRevenue(),
        fetchTotalUsers(),
        fetchActiveServices(),
        fetchRecentTransactions(),
        fetchTopServices(),
        fetchRevenueChart(),
        fetchUsageChart()
      ])
      
      calculateProfitMargin()
    } catch (err) {
      console.error('Error fetching dashboard stats:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Fetch total revenue from wallet transactions
  async function fetchTotalRevenue() {
    const dateFilter = getDateFilter()
    
    const { data, error: fetchError } = await supabase
      .from('wallet_transactions')
      .select('amount')
      .eq('type', 'deposit')
      .eq('status', 'completed')
      .gte('created_at', dateFilter)
    
    if (fetchError) throw fetchError
    
    // Convert points to revenue (assuming 100 points = 1 EUR)
    const totalPoints = data.reduce((sum, transaction) => sum + transaction.amount, 0)
    totalRevenue.value = totalPoints / 100
  }

  // Fetch total number of users
  async function fetchTotalUsers() {
    const { count, error: fetchError } = await supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
    
    if (fetchError) throw fetchError
    totalUsers.value = count || 0
  }

  // Fetch number of active services
  async function fetchActiveServices() {
    const { count, error: fetchError } = await supabase
      .from('ai_services')
      .select('*', { count: 'exact', head: true })
      .eq('is_active', true)
    
    if (fetchError) throw fetchError
    activeServices.value = count || 0
  }

  // Fetch recent wallet transactions
  async function fetchRecentTransactions() {
    const { data, error: fetchError } = await supabase
      .from('wallet_transactions')
      .select(`
        id,
        amount,
        type,
        status,
        created_at,
        wallets!inner(
          user_id,
          profiles!inner(
            display_name,
            username
          )
        )
      `)
      .eq('status', 'completed')
      .order('created_at', { ascending: false })
      .limit(10)
    
    if (fetchError) throw fetchError
    
    recentTransactions.value = data.map(transaction => ({
      id: transaction.id,
      amount: transaction.amount,
      type: transaction.type,
      status: transaction.status,
      created_at: transaction.created_at,
      user_name: transaction.wallets.profiles.display_name || transaction.wallets.profiles.username
    }))
  }

  // Fetch top used services
  async function fetchTopServices() {
    const dateFilter = getDateFilter()
    
    const { data, error: fetchError } = await supabase
      .from('service_usage')
      .select(`
        service_id,
        points_consumed,
        ai_services!inner(
          name,
          provider
        )
      `)
      .eq('status', 'completed')
      .gte('created_at', dateFilter)
    
    if (fetchError) throw fetchError
    
    // Group by service and calculate totals
    const serviceStats = {}
    data.forEach(usage => {
      const serviceId = usage.service_id
      if (!serviceStats[serviceId]) {
        serviceStats[serviceId] = {
          name: usage.ai_services.name,
          provider: usage.ai_services.provider,
          totalUsage: 0,
          totalPoints: 0
        }
      }
      serviceStats[serviceId].totalUsage += 1
      serviceStats[serviceId].totalPoints += usage.points_consumed
    })
    
    // Convert to array and sort by usage
    topServices.value = Object.values(serviceStats)
      .sort((a, b) => b.totalUsage - a.totalUsage)
      .slice(0, 5)
  }

  // Fetch revenue chart data
  async function fetchRevenueChart() {
    const dateFilter = getDateFilter()
    
    const { data, error: fetchError } = await supabase
      .from('wallet_transactions')
      .select('amount, created_at')
      .eq('type', 'deposit')
      .eq('status', 'completed')
      .gte('created_at', dateFilter)
      .order('created_at', { ascending: true })
    
    if (fetchError) throw fetchError
    
    // Group by day and sum amounts
    const dailyRevenue = {}
    data.forEach(transaction => {
      const date = new Date(transaction.created_at).toISOString().split('T')[0]
      if (!dailyRevenue[date]) {
        dailyRevenue[date] = 0
      }
      dailyRevenue[date] += transaction.amount / 100 // Convert points to EUR
    })
    
    revenueData.value = Object.entries(dailyRevenue).map(([date, revenue]) => ({
      date,
      revenue
    }))
  }

  // Fetch usage chart data
  async function fetchUsageChart() {
    const dateFilter = getDateFilter()
    
    const { data, error: fetchError } = await supabase
      .from('service_usage')
      .select(`
        created_at,
        ai_services!inner(
          name,
          provider
        )
      `)
      .eq('status', 'completed')
      .gte('created_at', dateFilter)
      .order('created_at', { ascending: true })
    
    if (fetchError) throw fetchError
    
    // Group by day and service
    const dailyUsage = {}
    data.forEach(usage => {
      const date = new Date(usage.created_at).toISOString().split('T')[0]
      const serviceName = usage.ai_services.name
      
      if (!dailyUsage[date]) {
        dailyUsage[date] = {}
      }
      if (!dailyUsage[date][serviceName]) {
        dailyUsage[date][serviceName] = 0
      }
      dailyUsage[date][serviceName] += 1
    })
    
    usageData.value = Object.entries(dailyUsage).map(([date, services]) => ({
      date,
      ...services
    }))
  }

  // Calculate profit margin
  function calculateProfitMargin() {
    // This is a simplified calculation
    // In a real scenario, you'd need to factor in API costs, operational costs, etc.
    if (totalRevenue.value > 0) {
      // Assuming a 70% profit margin for simplification
      profitMargin.value = 70
    } else {
      profitMargin.value = 0
    }
  }

  // Get date filter based on selected range
  function getDateFilter() {
    const now = new Date()
    switch (dateRange.value) {
      case 'last7Days':
        return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString()
      case 'thisMonth':
        return new Date(now.getFullYear(), now.getMonth(), 1).toISOString()
      case 'lastMonth':
        const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1)
        return lastMonth.toISOString()
      case 'last30Days':
      default:
        return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000).toISOString()
    }
  }

  // Update date range and refresh data
  function setDateRange(range) {
    dateRange.value = range
    fetchDashboardStats()
  }

  // Refresh all data
  function refreshData() {
    fetchDashboardStats()
  }

  return {
    // State
    loading,
    error,
    totalRevenue,
    totalUsers,
    activeServices,
    profitMargin,
    recentTransactions,
    topServices,
    revenueData,
    usageData,
    dateRange,
    
    // Computed
    formattedRevenue,
    formattedUsers,
    
    // Actions
    fetchDashboardStats,
    setDateRange,
    refreshData
  }
})