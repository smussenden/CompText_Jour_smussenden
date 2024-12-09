
# combine_responses <- function(base_dir = "../llm_responses") {
#   
#   files <- list.files(base_dir, pattern = "\\.rds$", recursive = TRUE, full.names = TRUE)
# 
#   responses <- map_dfr(files, function(file) {
#     
#     parts <- str_split(file, "/")[[1]]
#     model_provider <- parts[3] 
#     model_type <- parts[4]
#     article_id <- str_remove(basename(file), "\\.rds$")
#     raw_response <- readRDS(file)
#     response_parts <- str_split(raw_response, "Warning:")[[1]]
#     response <- response_parts[1]
#     
#     json <- str_extract(response, "\\{[^}]*\\}")
#     
#     if (is.na(json)) {
#       return(create_empty_row(article_id, model_provider, model_type, raw_response))
#     } else {
#       json <- json %>%
#         str_replace_all("\\\\_", "_") %>%
#         str_replace_all("\\\\([nrt])", "") %>%
#         str_replace_all("\\\\([^\"'\\\\])", "\\1") %>%
#         str_replace_all("\\s+", " ") %>%
#         str_trim()
#       
#       tryCatch({
#         parsed <- jsonlite::fromJSON(json)
#         create_row(article_id, model_provider, model_type, json, parsed)
#       }, error = function(e) {
#       warning(sprintf("Failed to parse JSON for file %s: %s\nResponse: %s", file, as.character(e), json))
#       create_empty_row(article_id, model_provider, model_type, raw_response)
#       })
#   }
#   })}

combine_responses_validate_json <- function(base_dir = "../data/output_data/llm_responses") {
  
  files <- list.files(base_dir, pattern = "\\.rds$", recursive = TRUE, full.names = TRUE)
  
  responses <- map_dfr(files, function(file) {
    parts <- str_split(file, "/")[[1]]
    model_provider <- parts[5] 
    model_type <- parts[6]
    article_id <- str_remove(basename(file), "\\.rds$")
    raw_response <- readRDS(file) 
    
    tibble(
      article_id = article_id,
      model_provider = model_provider,
      model_type = model_type,
      raw_response = raw_response
    )
  })%>%
    mutate(valid_json_in_raw_response = map_lgl(raw_response, ~tryCatch(
      jsonlite::validate(.x),
      error = function(e) FALSE
    ))) 
}

# combine_responses()



# Helper functions
create_empty_row <- function(article_id, model_provider, model_type, raw_response) {
  tibble(
    article_id = article_id,
    model_provider = model_provider,
    model_type = model_type,
    raw_response = raw_response,
    spellchecked_text = NA_character_,
    category_id = NA_character_,
    category_description = NA_character_,
    explanation = NA_character_
  )
}

create_row <- function(article_id, model_provider, model_type, raw_response, parsed) {
  tibble(
    article_id = article_id,
    model_provider = model_provider,
    model_type = model_type,
    raw_response = raw_response,
    spellchecked_text = parsed$spellchecked_text %||% NA_character_,
    category_id = as.character(parsed$category_id) %||% NA_character_,
    category_description = parsed$category_description %||% NA_character_,
    explanation = as.character(parsed$explanation) %||% NA_character_
  )
}

get_model_completeness_status <- function() {
  
  response_count <- responses %>%
    count(model_provider, model_type) %>%
    ungroup() %>%
    summarise(sum=sum(n))
    
  provider_model_type_status_df <- provider_model_type_list %>%
    as_tibble() %>%
    separate(value, into=c("model_provider", "model_type"), sep="_") %>%
    left_join(responses %>% count(model_type, model_provider), by=c("model_provider", "model_type")) %>%
    mutate(model_provider_type = paste0(model_provider, "_", model_type)) %>%
    relocate(model_provider_type, .before = model_provider) %>%
    mutate(status = case_when(
      n == nrow(test_data) ~ "complete",
      is.na(n) ~ "not_started",
      TRUE ~ "incomplete"
    )) %>%
    arrange(status, desc(n), model_provider_type)
  
  provider_model_type_rerun_list <- provider_model_type_status_df %>%
#    arrange(desc(status), desc(n)) %>%
    filter(status %in% c("not_started", "incomplete")) %>%
    pull(model_provider_type)
  
  article_status_matrix <- responses %>%
    mutate(model_provider_type = paste0(model_provider, "_", model_type)) %>%
    select(article_id, model_provider_type) %>%
    mutate(value = "1") %>%
    pivot_wider(names_from = model_provider_type, values_from = value) %>%
    # replace all na values across all columns with string MISSING
    mutate_all(~replace_na(., "MISSING")) %>%
    pivot_longer(names_to = "model_provider_type", values_to = "status", -article_id)
  
  #needs_json_reparse <- responses %>%
    
  
  # return list and dataframe to global environment
  list(provider_model_type_rerun_list = provider_model_type_rerun_list, 
       provider_model_type_status_df = provider_model_type_status_df,
       article_status_matrix=article_status_matrix)
  
}
    