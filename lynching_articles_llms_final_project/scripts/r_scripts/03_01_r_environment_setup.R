# Function to install missing packages
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    message("Installing missing packages: ", paste(new_packages, collapse = ", "))
    install.packages(new_packages)
  }
}

# List of required packages with descriptions
required_packages <- c(
  # Core data manipulation and visualization framework
  "tidyverse",    # Collection of packages for data science including ggplot2, dplyr, tidyr, etc.
  
  # Data import and external services
  "googlesheets4", # Read and write Google Sheets
  "janitor",      # Clean and format messy data, especially column names
  "elmer",        # Interface for working with Large Language Models (LLMs)
  
  # Parallel processing
  "future",       # Framework for parallel and distributed computing
  "furrr",        # Parallel processing operations with purrr syntax
  
  # Data storage and AWS integration
  "arrow",        # Work with Apache Arrow datasets and feather files efficiently
  "paws.common",  # AWS SDK for R, common functionality for AWS services
  
  # Development tools
  "usethis",      # Automate common development tasks and project setup
  "rstudioapi"   # Access RStudio IDE API
)

# Install missing packages
install_if_missing(required_packages)

# Special case for elmer since it's from Github
if(!requireNamespace("elmer", quietly = TRUE)) {
  message("Installing elmer from Github...")
  if(!requireNamespace("pak", quietly = TRUE)) {
    install.packages("pak")
  }
  pak::pak("tidyverse/elmer")
}

# Load all libraries
invisible(lapply(required_packages, library, character.only = TRUE))

# Run to open renviron file to edit
usethis::edit_r_environ() 

# Let's see those keys

# If all of these keys are set, then you can run the following to check
print("--------------------------")
print("Currently set environment variables, stored LLM keys")
print("Run usethis::edit_r_environ() to open renviron file to edit")
print("Then restart R session for changes to take effect")
print("--------------------------")
print(paste0("OPENAI_API_KEY: ",Sys.getenv("OPENAI_API_KEY")))
print(paste0("GROQ_API_KEY: ",Sys.getenv("GROQ_API_KEY")))
print(paste0("AWS_ACCESS_KEY_ID: ",Sys.getenv("AWS_ACCESS_KEY_ID")))
print(paste0("AWS_SECRET_ACCESS_KEY: ",Sys.getenv("AWS_SECRET_ACCESS_KEY")))
print(paste0("AWS_REGION: ",Sys.getenv("AWS_REGION")))
print(paste0("GEMINI_API_KEY: ",Sys.getenv("GEMINI_API_KEY")))
print(paste0("GOOGLE_API_KEY: ",Sys.getenv("GOOGLE_API_KEY")))