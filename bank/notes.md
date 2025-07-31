il y'a un probème, je veux rédéfinir les choses. Je veux que la table service_subcategories soit renommée en service_abilities(c'est une capacité d'un modèle). Pour une catégorie donnée, il peut y avoir plusieurs modèles, ensuite chaque modèle peut avoir plusieurs capacités. j'ai actuellement tous les détails actuels sont dans les fichiers /Users/angenor/Documents/projets/projets_perso/ia_web/bank/schema_updated_Version2.sql; /Users/angenor/Documents/projets/projets_perso/ia_web/bank/seed_llm_models.sql; /Users/angenor/Documents/projets/projets_perso/ia_web/bank/seed_llm_subcategories.sql. Il faut creer un autre fichier pour les migrations. tu mettras également à jour le fichier /Users/angenor/Documents/projets/projets_perso/ia_web/bank/conception-saas-ia-centralise-finale.md avec les modifications apportées.


il faut mettre à jour /Users/angenor/Documents/projets/projets_perso/ia_web/bank/schema_updated_Version2.sql en fonction de /Users/angenor/Documents/projets/projets_perso/ia_web/bank/migration_rename_subcategories_to_abilities.sql

Il faut mettre à jour AppSidebar.vue pour refléter les changements de la table service_abilities.

De meme je veux ajouter les modèles DeepSeek V3 0324(https://openrouter.ai/deepseek/deepseek-chat-v3-0324:free); Qwen3 Coder(https://openrouter.ai/qwen/qwen3-coder:free); Chat GPT-4.5 Preview(https://openrouter.ai/openai/gpt-4.5-preview); GPT-4.1(https://openrouter.ai/openai/gpt-4.1); Llama 4 Maverick(https://openrouter.ai/meta-llama/llama-4-maverick). N'oublie pas d'ajouter les abilities correspondantes pour chaque modèle.


Il semble que LLMService n'utilise pas les informations de mes modèles dans la base de données.


N8N