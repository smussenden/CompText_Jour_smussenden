
correct_malformed_json_with_llm <- function(df, n_workers = 3, output_dir = "../data/output_data/corrected_json", skip_existing = TRUE) {
  # Validate required columns exist
  required_cols <- c("model_provider", "model_type", "article_id")
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop(sprintf("Missing required columns: %s", paste(missing_cols, collapse = ", ")))
  }
  
  # Create directory structure
  dir_create(output_dir)
  dir_create(path(output_dir, "no_repair_needed"))
  dir_create(path(output_dir, "fixed"))
  dir_create(path(output_dir, "failed_to_fix"))
  
  # Function to generate consistent filenames
  generate_filename <- function(row_data) {
    filename <- sprintf("%s_%s_%s.rds",
                       row_data$model_provider,
                       row_data$model_type,
                       row_data$article_id)
    gsub("[^a-zA-Z0-9_.-]", "_", filename)
  }
  
  # Check for existing files before processing
  if (skip_existing) {
    # Generate all potential filenames
    potential_files <- df %>%
      split(1:nrow(df)) %>%
      map_chr(generate_filename)
    
    # Check all directories for existing files
    existing_files <- c(
      list.files(path(output_dir, "no_repair_needed")),
      list.files(path(output_dir, "fixed")),
      list.files(path(output_dir, "failed_to_fix"))
    )
    
    # Filter out rows that have already been processed
    rows_to_process <- which(!potential_files %in% existing_files)
    
    if (length(rows_to_process) < nrow(df)) {
      message(sprintf("Skipping %d already processed files", nrow(df) - length(rows_to_process)))
      if (length(rows_to_process) == 0) {
        message("All files already exist. Nothing to process.")
        return(invisible(output_dir))
      }
      df <- df[rows_to_process, ]
    }
  }
  
  # Initialize counters
  counters <- list(
    no_repair = 0,
    fixed = 0,
    failed = 0
  )
  
  # Set up parallel processing
  plan(multisession, workers = n_workers)
  
  # Create chat client factory function
  create_chat_client <- function() {
    chat_openai(
      model = "gpt-4-turbo",
      system_prompt = "I will pass you a malformed json object. Your task is to fix any errors that will prevent this from returning TRUE when passed directly through the jsonlite::validate() function in R. Do not change the content of the json object, only the structure.Format your response as a JSON object with these exact fields:{
          \"article_id\": \"string, unchanged from input\",
          \"spellchecked_text\": \"string, corrected spelling of article\",
          \"category_id\": \"string, single digit 1-6\",
          \"category_description\": \"string, exact category description from above\",
          \"explanation\": \"string, brief reason for classification\"}
      
      If a value is missing for a specific key, or if a key is not present at all, include the key with an empty string as the value in your response. Important formatting rules:
- Use double quotes for all strings
- No line breaks in text fields
- No trailing commas
- No comments or additional text
- No markdown formatting
- Never escape single quotes (') in text
- Replace escaped single quotes (\') with regular single quotes (')
- Double quotes within text must be escaped with backslash (\")
- Remove any \r or \n characters from text
- End the JSON object with a single closing curly brace",
      echo = FALSE
    )
  }
  
  # Process and save function for each row
  process_and_save_row <- function(row_data, row_index) {
    filename <- generate_filename(row_data)
    
    if (row_data$valid_json_in_raw_response) {
      # No repair needed
      saveRDS(row_data, path(output_dir, "no_repair_needed", filename))
      return("no_repair")
    }
    
    # Create a new chat client for this worker
    chat <- create_chat_client()
    
    # Process the row
    result <- tryCatch({
      R.utils::withTimeout({
        attempt <- 1
        max_attempts <- 3
        chat_result <- NULL
        
        while (attempt <= max_attempts && is.null(chat_result)) {
          chat_result <- tryCatch({
            chat$chat(row_data$raw_response)
          }, error = function(e) {
            if (attempt == max_attempts) {
              return(paste0("Error after ", max_attempts, " attempts: ", e$message))
            }
            Sys.sleep(2^attempt)
            return(NULL)
          })
          attempt <- attempt + 1
        }
        chat_result
      }, timeout = 30)
    }, error = function(e) {
      paste0("Error: ", e$message)
    })
    
    # Check if repair was successful
    is_valid <- tryCatch(
      jsonlite::validate(result),
      error = function(e) FALSE
    )
    
    # Update row data with result
    row_data$repaired_json <- result
    row_data$recheck_valid_json_in_raw_response <- is_valid
    
    # Save to appropriate directory
    if (is_valid) {
      saveRDS(row_data, path(output_dir, "fixed", filename))
      return("fixed")
    } else {
      saveRDS(row_data, path(output_dir, "failed_to_fix", filename))
      return("failed")
    }
  }
  
  # Add progress bar
  pb <- progress::progress_bar$new(
    format = "[:bar] :current/:total (:percent) :eta",
    total = nrow(df)
  )
  
  # Process rows in parallel
  results <- future_map2(
    .x = split(df, 1:nrow(df)),
    .y = 1:nrow(df),
    ~{
      result <- process_and_save_row(.x, .y)
      pb$tick()
      result
    },
    .options = furrr_options(seed = TRUE)
  )
  
  # Clean up parallel processing
  plan(sequential)
  
  # Count results from this run
  counts <- table(unlist(results))
  
  # Get total counts including existing files if skip_existing is TRUE
  if (skip_existing) {
    total_counts <- c(
      no_repair = length(list.files(path(output_dir, "no_repair_needed"))),
      fixed = length(list.files(path(output_dir, "fixed"))),
      failed = length(list.files(path(output_dir, "failed_to_fix")))
    )
    
    message(sprintf("\nProcessing Summary:
This run:
- Processed: %d new files
- Already valid (no repair needed): %d
- Successfully fixed: %d
- Failed to fix: %d

Total including existing files:
- Total files: %d
- No repair needed: %d
- Fixed: %d
- Failed: %d

Results saved in: %s", 
      nrow(df),
      counts["no_repair"],
      counts["fixed"],
      counts["failed"],
      sum(total_counts),
      total_counts["no_repair"],
      total_counts["fixed"],
      total_counts["failed"],
      normalizePath(output_dir)
    ))
  } else {
    message(sprintf("\nProcessing Summary:
Total JSON objects processed: %d
- Already valid (no repair needed): %d
- Successfully fixed: %d
- Failed to fix: %d

Results saved in: %s", 
      nrow(df),
      counts["no_repair"],
      counts["fixed"],
      counts["failed"],
      normalizePath(output_dir)
    ))
  }
  
  return(invisible(output_dir))
}

combine_json_results <- function(output_dir = "../data/output_data/corrected_json") {
  # Read and combine all files from each directory
  no_repair <- list.files(path(output_dir, "no_repair_needed"), full.names = TRUE) %>%
    map_dfr(readRDS) %>%
    mutate(folder = "no_repair_needed")
  
  fixed <- list.files(path(output_dir, "fixed"), full.names = TRUE) %>%
    map_dfr(readRDS) %>%
    mutate(folder = "fixed")
  
  failed <- list.files(path(output_dir, "failed_to_fix"), full.names = TRUE) %>%
    map_dfr(readRDS) %>%
    mutate(folder = "failed_to_fix")
  
  # Combine all results
  combined_results <- bind_rows(no_repair, fixed, failed)
  
  # Prepare the data and create the output_json column
  combined_results <- combined_results %>%
    arrange(row_number()) %>%
    mutate(output_json = case_when(
      folder == "fixed" ~ repaired_json,
      folder == "no_repair_needed" ~ raw_response,
      folder == "failed_to_fix" ~ NA_character_
    ))
  
  # Parse JSON with error handling and consistent naming
  combined_results <- combined_results %>%
    mutate(
      extracted_json = map(output_json, function(x) {
        tryCatch({
          parsed <- jsonlite::fromJSON(x, simplifyVector = TRUE)
          # Ensure all elements have names
          if (is.null(names(parsed))) {
            names(parsed) <- paste0("value_", seq_along(parsed))
          }
          parsed
        },
        error = function(e) NA)
      })
    )
  
  # Store original column names
  original_cols <- names(combined_results)
  
  # Add safe unnesting with auto-generated names
  expanded_results <- combined_results %>%
    unnest_wider(
      extracted_json,
      names_sep = "_",  # Use underscore as separator for auto-generated names
      names_repair = "unique"  # Ensure unique column names
    )
  
  # Clean up column names while preserving uniqueness
  expanded_results <- expanded_results %>%
    # First replace dots with underscores in all columns
    rename_with(~gsub("\\.", "_", .), everything()) %>%
    # Then handle the extracted JSON columns separately
    rename_with(
      ~paste0("json_", gsub("extracted_json_", "", .)),  # Add 'json_' prefix
      !any_of(original_cols)  # Only apply to new columns from JSON
    )
  
  return(expanded_results)
}
