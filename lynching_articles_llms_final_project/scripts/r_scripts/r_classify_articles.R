
###
# Function to classify articles
###


classify_articles <- function(model_provider_type="gemini_gemini-1.5-pro", 
                              sample_size=nrow(test_set_articles), 
                              overwrite=TRUE, 
                              system_prompt=system_prompt_value,
                              model_for_json_reparse="gemini_gemini-1.5-pro") {
  
  if (!is.character(model_provider_type) || length(model_provider_type) != 1) {
    stop("model_provider_type must be a single character string")
  }
  
  parts <- str_split(model_provider_type, "_")[[1]]
  if (length(parts) != 2) stop("model_provider_type must be in format 'provider_model'")
  
  model_provider <- parts[1]
  model_type <- parts[2]
  
  save_dir <- file.path("llm_responses", model_provider, model_type)
  dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
  
  log_file <- file.path(save_dir, "error_log.csv")
  #if (overwrite || !file.exists(log_file)) {
  write.csv(data.frame(
    timestamp = character(),
    article_id = character(),
    error = character(),
    stringsAsFactors = FALSE
  ), log_file, row.names = FALSE)
  #}
  
  result_df <- test_set_articles %>% slice(1:sample_size)
  articles <- result_df %>% pull(article)
  article_ids <- result_df %>% pull(article_id)
  #i <- 1
  process_article <- function(i) {
    file_path <- file.path(save_dir, paste0(article_ids[i], ".rds"))
    if (!overwrite && file.exists(file_path)) {
      print(paste("Article", article_ids[i], "already processed"))
      return(NULL)
    }
    
    print(paste("Article", article_ids[i], "not yet processed, starting..."))
    
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
    }
    
    text <- paste0("Article ID: ", article_ids[i], "\n\nArticle: ", articles[i])
    if (model_provider == "bedrock" | model_provider_type %in% c("openai_o1-preview","openai_o1-mini")) {
      text <- paste0("Instructions: ", system_prompt_value, "\nArticle ID: ", article_ids[i], "\nArticle to process: ", articles[i])
    }
    
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
  
  lapply(seq_along(articles), process_article)
  print(paste0("finished processing ", model_provider_type))
}



overwrite <- FALSE
model_provider_type <- "gemini_gemini-1.5-pro"
sample_size <- nrow(test_set_articles)
classify_articles(model_provider_type, sample_size, overwrite)

# set workers to 1 less than number of cores
# model_provider_type_list <- c("bedrock_amazon.titan-text-premier-v1:0")

workers <- parallel::detectCores() - 1
future::plan(future::multisession, workers = workers)

model_provider_type_list <- unfinished_file_count_models
# Run classification in parallel
future_map(
  model_provider_type_list,
  classify_articles,
  sample_size = nrow(test_set_articles),
  overwrite = FALSE,
  .progress = TRUE
)
nrow(test_set_articles)