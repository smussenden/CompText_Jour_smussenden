# Your .Renviron file should open up here.
# It's a text file you can edit.  
# It's where you'll store your API keys so you don't have to put them in your script.
# Make sure the file is git-ignored, so you don't expose your keys to the public. 
# You'll need to add in API keys for OpenAI, Groq, Amazon Bedrock, Google Gemini, and AWS if you want this script to work.
# DO NOT EDIT THE EXAMPLES BELOW IN THE QMD FILE. 
# THIS IS JUST TO SHOW YOU WHAT IT SHOULD LOOK LIKE IN Renviron. 
# Be sure to save the change to the file when you make edits
#OPENAI_API_KEY = "key_here"
#GROQ_API_KEY = "key_here"
#AWS_ACCESS_KEY_ID = "access_key_here"
#AWS_SECRET_ACCESS_KEY = "secret_key_here"
#AWS_REGION = "region_name"
#GEMINI_API_KEY = "key_here"
#GOOGLE_API_KEY = "key_here"

# If you have added or changed keys in your .Renviron file, you have to restart R to make sure they're loaded.
# If you have done that, you'll need to restart R and then reload libraries.
# You can do that by uncommenting the two lines of code below and then running
# If you have not made changes to .Renviron (you only have to do it once, or when your keys change), then leave these uncommented.
# rstudioapi::restartSession()


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
  "rstudioapi",   # Access RStudio IDE API
  "fs"           # File system operations
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

# Let's see those keys

# If all of these keys are set, then you can run the following to check
# print("--------------------------")
# print("Currently set environment variables, stored LLM keys")
# print("Run usethis::edit_r_environ() to open renviron file to edit")
# print("Then restart R session for changes to take effect")
# print("--------------------------")
# print(paste0("OPENAI_API_KEY: ",Sys.getenv("OPENAI_API_KEY")))
# print(paste0("GROQ_API_KEY: ",Sys.getenv("GROQ_API_KEY")))
# print(paste0("AWS_ACCESS_KEY_ID: ",Sys.getenv("AWS_ACCESS_KEY_ID")))
# print(paste0("AWS_SECRET_ACCESS_KEY: ",Sys.getenv("AWS_SECRET_ACCESS_KEY")))
# print(paste0("AWS_REGION: ",Sys.getenv("AWS_REGION")))
# print(paste0("GEMINI_API_KEY: ",Sys.getenv("GEMINI_API_KEY")))
# print(paste0("GOOGLE_API_KEY: ",Sys.getenv("GOOGLE_API_KEY")))