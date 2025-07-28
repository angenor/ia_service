// Configuration pour les APIs
export const config = {
  supabase: {
    url: import.meta.env.VITE_SUPABASE_URL,
    anonKey: import.meta.env.VITE_SUPABASE_ANON_KEY
  },
  openrouter: {
    apiKey: import.meta.env.VITE_OPENROUTER_API_KEY,
    baseUrl: 'https://openrouter.ai/api/v1'
  },
  fal: {
    apiKey: import.meta.env.VITE_FAL_API_KEY
  }
}