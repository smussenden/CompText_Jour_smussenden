create_model_accuracy_stats <- function(output_dir = results_with_corrected_json, test_data = lynching_articles_test_data) {

# Later, when needed, combine all results:
combined_df <- combine_json_results(output_dir) %>%
  ungroup() %>%
  mutate(model_provider_type = paste0(model_provider, "_", model_type)) %>%
  mutate(predicted_specific_lynching_event = if_else(predicted_category_id == 1, "1_lynching_event", "0_not_lynching_event")) %>%
  mutate(actual_specific_lynching_event = if_else(actual_class_id == 1, "1_lynching_event", "0_not_lynching_event")) %>%
  # classify whether model got true positive or true negative or false positive or false negative
  mutate(specific_lynching_event_confusion_matrix_value = case_when(
    predicted_specific_lynching_event == "1_lynching_event" & actual_specific_lynching_event == "1_lynching_event" ~ "true_positive",
    predicted_specific_lynching_event == "0_not_lynching_event" & actual_specific_lynching_event == "0_not_lynching_event" ~ "true_negative",
    predicted_specific_lynching_event == "1_lynching_event" & actual_specific_lynching_event == "0_not_lynching_event" ~ "false_positive",
    predicted_specific_lynching_event == "0_not_lynching_event" & actual_specific_lynching_event == "1_lynching_event" ~ "false_negative"
  )) %>%
  mutate(specific_class_predicted_v_actual = if_else(predicted_category_id == actual_class_id, "true", "false")) 

# Make confusion matrix table

specific_lynching_event_predicted_v_actual <- combined_df %>%
  group_by(model_provider_type, specific_lynching_event_confusion_matrix_value) %>%
  count() %>%
  ungroup() %>%
  pivot_wider(names_from = specific_lynching_event_confusion_matrix_value, values_from = n) %>%
  # replace all na values with 0
  replace_na(list(true_positive = 0, true_negative = 0, false_positive = 0, false_negative = 0)) %>%
  mutate(total = true_positive + true_negative + false_positive + false_negative) %>%
  mutate(total_correct = true_positive+true_negative) %>%
  mutate(total_incorrect = false_positive+false_negative) %>%
  mutate(pct_correct = total_correct/total*100) %>%
  arrange(desc(pct_correct))

# make detailed class error table
specific_class_predicted_v_actual <- combined_df %>%
  group_by(model_provider_type, specific_class_predicted_v_actual) %>%
  count() %>%
  ungroup() %>%
  pivot_wider(names_from=specific_class_predicted_v_actual, values_from=n) %>%
  mutate(total=true+false) %>%
  mutate(pct_correct = true/total*100)

# make detailed class error table
actual_class_count <- test_data %>%
  group_by(actual_class_id, class_definition) %>% 
  count() %>%
  mutate(actual_class_id = paste0(actual_class_id, "_", class_definition)) %>%
  ungroup() %>%
  select(-class_definition) %>%
  pivot_wider(names_from=actual_class_id, values_from=n) %>%
  clean_names() 

specific_class_counts <- combined_df %>%
  group_by(model_provider_type, predicted_category_id) %>%
  count() %>%
  mutate(predicted_category_id = paste0("class_0", predicted_category_id)) %>%
  pivot_wider(names_from=predicted_category_id, values_from=n) %>%
  # replace all na values with 0
  mutate(across(everything(), ~replace_na(., 0))) %>%
  select(model_provider_type, class_01, class_02, class_03, class_04, class_05, class_06, class_00) %>%
  bind_cols(actual_class_count) 


# add each dataframe to a list and return that
list(specific_lynching_event_predicted_v_actual = specific_lynching_event_predicted_v_actual,
     specific_class_predicted_v_actual = specific_class_predicted_v_actual,
     specific_class_counts = specific_class_counts)

}
