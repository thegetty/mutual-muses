# Convert the results of transcription ranking in to a structured yaml file that
# can be easily processed into a pdf or website

library(tidyverse)
library(yaml)
library(bookdown)
library(fs)
library(tokenizers)
library(knitr)
library(tufte)
library(xtable)
library(lubridate)

unlink("_main.Rmd")

image_directory <- "/Volumes/data_mdlincoln/MMpdfs/"

mm_final <- read_csv("mm-final.csv")

available_image_paths <- data_frame(full_path = dir_ls(image_directory, glob = "*.jpg", recursive = TRUE)) %>%
  mutate(
    file_name = path_file(full_path),
    year = path_split(full_path) %>% map(5) %>% map_int(as.integer),
    month_number = path_split(full_path) %>% map(6) %>% map_int(~ as.integer(str_extract(., pattern = "\\d{2}$"))),
    month_number = if_else(month_number == 0, 13L, month_number),
    month = factor(month_number, labels = c(month.name, "Undated"), ordered = TRUE))

create_title <- function(s, n = 7) {
  word_tokens <- tokenize_words(s, lowercase = FALSE, simplify = TRUE, stopwords = "unclear")
  section_brief <- paste0(word_tokens[1:n], collapse = " ")
  str_glue("{section_brief}...")
}

replacements <- c(
  " +" = " ",
  "\\t" = " ",
  "\\\\" = " ",
  "˚" = "º"
)

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
    day_of = format(day_of)) %>%
  slice(1:100) %>%
  mutate_at(vars(annotation_text, user_name), sanitize)


split_transcriptions <- transcriptions %>%
  split(.$year) %>%
  map(~ split(., .$month))


parse_path <- function(p) {
  list(
    year = str_match(p, "gri_(\\d{4})")[,2],
    letter = toupper(str_match(p, "gri_\\d{4}_([a-z]+)")[,2]),
    series = str_match(p, "gri_\\d{4}_[a-z]+_(\\d+)")[,2],
    box = as.integer(str_match(p, "b(\\d+)")[,2]),
    folder = as.integer(str_match(p, "f(\\d+)")[,2]),
    sheet = as.integer(str_match(p, "f\\d+_(\\d+)")[,2])
  )
}

produce_part <- function(components, partname) {
  c(
    str_glue("# (PART) {partname} {{-}}"),
    imap(components, produce_chapter)
  )
}

produce_chapter <- function(df, chapname) {
  if (nrow(df) > 0) {
    named_input <- list(filename = df$file_name,
                        text = df$annotation_text,
                        image_path = df$full_path,
                        user = df$user_name,
                        completed = df$day_of,
                        has_drawing = df$has_drawing)
    c(
      str_glue("# {chapname}"),
      pmap(named_input, produce_spread)
    )
  }
}

produce_spread <- function(filename, text, image_path, user, completed, has_drawing) {
  titletext <- create_title(text)
  header <- str_glue("## {titletext}")
  body <- text

  ufn <- str_replace_all(path_ext_remove(filename), "_", "-")

  parsed_path <- parse_path(filename)

  safe_user <- str_replace_all(user, "\\\\", "\\\\\\\\")
  margin_note <- str_glue("Transcribed by {safe_user} on {completed}.")

  caption <- str_glue("Series {parsed_path$year}.{parsed_path$letter}.{parsed_path$series}, box {parsed_path$box}, folder {parsed_path$folder}, sheet {parsed_path$sheet}")

  image_body <- str_glue("include_graphics('{image_path}')")

  drawing_note <- if_else(has_drawing, "\\index{doodle}", "")

  str_glue(
"

{header}

`r margin_note('{margin_note}')`

{body}

{drawing_note}

(ref:{ufn}) {caption}

```{{r {ufn}, out.width = '100%', fig.fullwidth = TRUE, fig.cap = '(ref:{ufn})'}}
{image_body}
```

")
}



spreads <- imap(split_transcriptions, ~ produce_part(.x, .y))
flat_spreads <- spreads %>% flatten() %>% flatten() %>% flatten_chr()
flat_spreads[1:3]


doc_metadata <- list(
  title = "Mutual Muses",
  subtitle = "The Correspondence of Lawrence Alloway and Sylvia Sleigh",
  author = list(
    "The Zooniverse Mutual Muses Community"
  ),
  date = as.character(Sys.Date())
)

header <- str_glue("
---
{as.yaml(doc_metadata)}---

```{{r, include = FALSE}}
knitr::opts_chunk$set(
echo = FALSE,
cache = TRUE,
sanitize = TRUE,
warning = FALSE,
message = FALSE,
error = FALSE
)
```
")

rmd_path <- "mutual_muses.Rmd"

write_lines(header, path = rmd_path)

walk(flat_spreads, ~ write_lines(., path = rmd_path, append = TRUE))

render_book("mutual_muses.Rmd", output_format = "bookdown::tufte_book2")
system("open _book/_main.pdf")
