
default_model_provider_type_list <- c(
  # Pass 1 
  "openai_gpt-4o",
  "groq_gemma2-9b-it",
  "bedrock_anthropic.claude-3-5-sonnet-20240620-v1:0",
  
  # Pass 2
  "openai_gpt-4o-mini", # works
  "groq_gemma-7b-it",# works
  "bedrock_anthropic.claude-v2:1", # works
  
  
  # Pass 3  
  "openai_gpt-4-turbo", # works
  "groq_llama3-groq-70b-8192-tool-use-preview",
  "bedrock_anthropic.claude-v2",# works
  
  
  # Pass 4
  "openai_gpt-4-turbo-preview", # works
  "groq_llama3-groq-8b-8192-tool-use-preview",
  "bedrock_anthropic.claude-instant-v1", # works
  
  # Pass 5
  "openai_gpt-3.5-turbo", # works
  "groq_llama-3.1-70b-versatile",# works
  "bedrock_anthropic.claude-3-haiku-20240307-v1:0", # works
  
  # Pass 6
  "openai_o1-preview",# works  
  "groq_llama-3.1-8b-instant",# works
  "bedrock_anthropic.claude-3-sonnet-20240229-v1:0", # works
  
  
  # Pass 7
  "openai_o1-mini",# works
  "groq_llama-3.2-1b-preview",# works
  
  # Pass 8
  "groq_llama-3.2-3b-preview",# works
  "bedrock_cohere.command-text-v14", # works
  
  
  
  # Pass 9 
  "groq_llama3-70b-8192",# works
  "bedrock_cohere.command-light-text-v14", # works
  
  
  # Pass 10 
  "groq_llama3-8b-8192",# works
  "bedrock_cohere.command-r-v1:0", # works
  
  
  # Pass 12  
  "groq_mixtral-8x7b-32768",# works
  "bedrock_cohere.command-r-plus-v1:0", # works
  #"gemini_gemini-exp-1114",#works
  
  # Pass 13
  "bedrock_ai21.jamba-1-5-large-v1:0", # this works
  #"gemini_gemini-exp-1121", #works
  
  # Pass 14
  "bedrock_ai21.jamba-1-5-mini-v1:0", # this works
  #"gemini_gemini-1.5-pro",
  
  # Pass 15
  "bedrock_meta.llama3-70b-instruct-v1:0", # this works
  #"gemini_gemini-1.5-flash",#works
  
  # Pass 16
  "bedrock_amazon.titan-text-premier-v1:0"#,# this works
  #"gemini_learnlm-1.5-pro-experimental"#works
  
)
