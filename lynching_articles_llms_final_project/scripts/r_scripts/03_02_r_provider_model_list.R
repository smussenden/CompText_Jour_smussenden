###
# Define model list
###




provider_model_type_list <- c(
  ###
  # OpenAI
  ### 
  # GPT-4 Family
  "openai_gpt-4o",
  "openai_gpt-4o-mini",
  "openai_gpt-4-turbo",
  "openai_gpt-4-turbo-preview",
  
  # O1 Family  
  "openai_o1-preview",
  "openai_o1-mini",
  
  # GPT-3.5 Family
  "openai_gpt-3.5-turbo",
  
  ###
  # Groq
  ### 
  
  # Gemma Models
  "groq_gemma2-9b-it",
  "groq_gemma-7b-it",
  
  # LLaMA 3 Series
  "groq_llama3-groq-70b-8192-tool-use-preview",
  "groq_llama3-groq-8b-8192-tool-use-preview", 
  "groq_llama-3.1-70b-versatile",
  "groq_llama-3.1-8b-instant",
  "groq_llama-3.2-1b-preview",
  "groq_llama-3.2-3b-preview",
  "groq_llama3-70b-8192",
  "groq_llama3-8b-8192",
  
  # Mixtral
  "groq_mixtral-8x7b-32768",
  
  ###
  # Bedrock
  ###  
  # Anthropic Claude Models
  "bedrock_anthropic.claude-3-5-sonnet-20240620-v1:0",
  "bedrock_anthropic.claude-v2:1",
  "bedrock_anthropic.claude-v2",
  "bedrock_anthropic.claude-instant-v1",
  "bedrock_anthropic.claude-3-haiku-20240307-v1:0",
  "bedrock_anthropic.claude-3-sonnet-20240229-v1:0",
  
  # Cohere Models
  "bedrock_cohere.command-text-v14",
  "bedrock_cohere.command-light-text-v14", 
  "bedrock_cohere.command-r-v1:0",
  "bedrock_cohere.command-r-plus-v1:0",
  
  # AI21 Models
  "bedrock_ai21.jamba-1-5-large-v1:0",
  "bedrock_ai21.jamba-1-5-mini-v1:0",

  
  # Meta Models
  "bedrock_meta.llama3-70b-instruct-v1:0",
  
  # Amazon Models
  "bedrock_amazon.titan-text-premier-v1:0",
  
  ###
  # Google
  ### 
  # Gemini Models
  "gemini_gemini-exp-1121",
  "gemini_gemini-1.5-pro",
  "gemini_gemini-1.5-flash",
  "gemini_learnlm-1.5-pro-experimental"
)

#print("--------------------------")
#print("List of providers and models to send articles to")
#print("Edit the list in 03_02_r_provider_model_list.R")
#print("--------------------------")

#print(provider_model_type_list)
