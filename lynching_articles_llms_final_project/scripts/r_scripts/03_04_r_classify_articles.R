
###
# Function to classify articles
###


classify_articles <- function(model_provider_type="gemini_gemini-1.5-pro",
                              model_for_json_reparse="gemini_gemini-1.5-pro",
                              system_prompt=system_prompt_value,
                              test_set_articles_df = test_data, 
                              sample_size=1, 
                              overwrite=TRUE) {
  
  
  ###
  # Parse model input string
  ###
  
  # Check validity of model_provider_type
  # Must be in format of provider_type, i.e. gemini_gemini-1.5-pro
  
  if (!is.character(model_provider_type) || length(model_provider_type) != 1) {
    stop("model_provider_type must be a single character string")
  }
  
  # Split into list of provider, type and check validity 
  
  parts <- str_split(model_provider_type, "_")[[1]]
  
  if (length(parts) != 2) stop("model_provider_type must be in format 'provider_model'")
  
  # Store component parts to pass to build 
  model_provider <- parts[1]
  model_type <- parts[2]
  
  ###
  # Create save directory
  ###
  
  save_dir <- file.path("../llm_responses", model_provider, model_type)
  dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
  
  ###
  # Create log file
  ### 
  log_file <- file.path(save_dir, "error_log.csv")
  #if (overwrite || !file.exists(log_file)) {
    write.csv(data.frame(
      timestamp = character(),
      article_id = character(),
      error = character(),
      stringsAsFactors = FALSE
    ), log_file, row.names = FALSE)
  #}
  
  ###
  # Set number of articles to pass through models
  ###
  
  result_df <- test_set_articles_df %>% 
    slice(1:sample_size)
  
  ###
  # Extract articles and article IDs into lists
  ###
  
  articles <- result_df %>% 
    pull(article)
  
  article_ids <- result_df %>% 
    pull(article_id)
  
  ###
  # Loop through articles and apply process_article function
  ###
  
  walk(seq_along(articles), 
       ~process_article(i = .x, 
                        article_ids = article_ids, 
                        articles = articles, 
                        save_dir = save_dir, 
                        model_provider = model_provider, 
                        model_type = model_type, 
                        overwrite=overwrite,
                        model_provider_type=model_provider_type,
                        log_file=log_file))
  print(paste0("finished processing ", model_provider_type))
}

###
# process article function
###

process_article <- function(i, article_ids, articles, save_dir, model_provider, model_type, overwrite, model_provider_type,log_file) {
  #print(overwrite)
  #return(overwrite)
  ###
  # Define filepath
  ###
  print(model_provider_type)
  file_path <- file.path(save_dir, paste0(article_ids[i], ".rds"))
  
  ###
  # Check if file exists and if overwrite argument is set to FALSE
  # If it is, don't reprocess the article because $$$
  ###
  if (!overwrite && file.exists(file_path)) {
    print(paste("Article", article_ids[i], "already processed"))
    return(NULL)
  }
  
  ###
  # If the file doesn't exist yet or overwrite is TRUE, process the article
  ###
  
  print(paste("Article", article_ids[i], "not yet processed, starting..."))
  
  ###
  # Determine which elmer function to use based on model_provider
  # Store a chat object to use in the chat function later
  ###
  
  chat <- if (model_provider == "ollama") {
    chat_ollama(model = model_type, system_prompt = system_prompt_value, echo = FALSE)
  } else if (model_provider == "groq") {
    chat_groq(model = model_type, system_prompt = system_prompt_value, echo = FALSE)
  } else if (model_provider_type %in% c("openai_o1-preview","openai_o1-mini")) {
    chat_openai(model = model_type, echo = FALSE)
  } else if (model_provider == "openai") {
    chat_openai(model = model_type, system_prompt = system_prompt_value, echo = FALSE)
  } else if (model_provider == "gemini") {
    chat_gemini(model = model_type, system_prompt = system_prompt_value, echo = FALSE)
  } else if (model_provider == "bedrock") {
    chat_bedrock(model = model_type, echo = FALSE)
  } else {
    stop("model_provider not recognized")
  }
  
  ###
  # Account for different system prompt formats
  # Build the prompt to send to the model
  ###
  
  if (model_provider == "bedrock" | model_provider_type %in% c("openai_o1-preview","openai_o1-mini")) {
    text <- paste0("Instructions: ", system_prompt_value, "\nArticle ID: ", article_ids[i], "\nArticle to process: ", articles[i])
  } else {
    text <- paste0("Article ID: ", article_ids[i], "\n\nArticle: ", articles[i])
  }
  
  ###
  # Attempt to get response from model! 
  # Save the response as an RDS file
  # If it fails, log the error
  ###
  
  tryCatch({
    response <- chat$chat(text)
    saveRDS(response, file = file_path)
  }, error = function(e) {
    error_msg <- as.character(e)
    write.table(
      data.frame(
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        article_id = article_ids[i],
        error = error_msg,
        stringsAsFactors = FALSE
      ),
      log_file,
      sep = ",",
      row.names = FALSE,
      col.names = !file.exists(log_file),
      append = TRUE
    )
    warning(sprintf("Row %d: Failed to get response for %s model %s.\nError: %s",
                    i, model_provider, model_type, error_msg))
  })
}

#overwrite <- FALSE
#model_provider_type <- "gemini_gemini-1.5-pro"
#sample_size <- nrow(test_set_articles)
#classify_articles(model_provider_type, sample_size, overwrite)

# set workers to 1 less than number of cores
# model_provider_type_list <- c("bedrock_amazon.titan-text-premier-v1:0")

#workers <- parallel::detectCores() - 1
#future::plan(future::multisession, workers = workers)

#model_provider_type_list <- unfinished_file_count_models
# Run classification in parallel
#future_map(
#  model_provider_type_list,
#  classify_articles,
#  sample_size = nrow(test_set_articles),
#  overwrite = FALSE,
#  .progress = TRUE
#)
#nrow(test_set_articles)