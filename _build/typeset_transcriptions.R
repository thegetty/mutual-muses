# Convert the results of transcription ranking in to a structured yaml file that
# can be easily processed into a pdf or website

library(tidyverse)
library(stringr)
library(yaml)

transcriptions <- readRDS("../mutual_muses_final/data/derived/all_with_winning.rds")

trans_yml <- transcriptions %>%
  mutate(clean_transcription = str_replace_all(clean_transcription, "\\n", "<br/>")) %>%
  split(.$file_name)

google_drive_sheet <- transcriptions %>%
  select(-is_winning) %>%
  mutate(preview = paste0("https://matthewlincoln.net/mm-final/transcription/", tools::file_path_sans_ext(file_name)))
write_csv(google_drive_sheet, "~/Desktop/gds.csv", na = "")

fnames <- names(trans_yml)

trans_yml <- trans_yml %>%
  map2(.y = fnames, function(x, y) {
    list(
      classifications = transpose(x),
      file_name = y)
  }) %>%
  unname()

unlink("_posts/*")
dir.create("_posts", showWarnings = FALSE)

walk(trans_yml, function(x) {
  fn <- tools::file_path_sans_ext(x$file_name)
  path_fn <- paste("2017-10-18", fn, sep = "-")
  post_path <- paste0("_posts/", path_fn, ".md")
  post_yaml <- list(
    layout = "post",
    categories = "transcription",
    date = "2017-10-18",
    title = fn,
    data = x) %>%
    as.yaml() %>%
    paste("---", ., "---", sep = "\n")


  message(post_path)
  write(post_yaml, file = post_path)
})
