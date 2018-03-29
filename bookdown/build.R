source("constructors.R")

unlink("_main.Rmd")

image_directory <- "MMpdfs/"

mm_final <- read_csv("../analysis/data/derived/all_with_winning.csv")

available_image_paths <- data_frame(full_path = dir_ls(image_directory, glob = "*.jpg", recursive = TRUE)) %>%
  mutate(
    file_name = path_file(full_path),
    year = path_split(full_path) %>% map(2) %>% map_int(as.integer),
    month_number = path_split(full_path) %>% map(3) %>% map_int(~ as.integer(str_extract(., pattern = "\\d{2}$"))),
    month_number = if_else(month_number == 0, 13L, month_number),
    month = factor(month_number, labels = c(month.name, "Undated"), ordered = TRUE))

choice_final_data <- mm_final %>%
  filter(selected_as_winning) %>%
  select(subject_ids, classification_id, user_name, day_of, has_drawing = majority_vote)

transcriptions <- read_csv("mm-post-process.csv") %>%
  inner_join(available_image_paths, by = "file_name") %>%
  mutate(
    annotation_text = str_trim(str_replace_all(annotation_text, pattern = replacements))
  ) %>%
  arrange(year, month, file_name) %>%
  inner_join(choice_final_data, by = "subject_ids") %>%
  mutate(
    user_name = if_else(str_detect(user_name, "not-logged-in"), "an anonymous Zooniverse user", user_name),
    day_of = format(day_of),
    part_index = dense_rank(year),
    chapter_index = group_indices(., year, month)) %>%
  mutate_at(vars(annotation_text, user_name), sanitize)

split_transcriptions <- transcriptions %>%
  split(.$year, drop = TRUE) %>%
  map(~ split(., .$month, drop = TRUE))

invisible(lmap(split_transcriptions, ~ produce_volume(title = names(.), split_transcriptions = .)))
