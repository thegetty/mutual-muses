library(tidyverse)
library(yaml)
library(bookdown)
library(fs)
library(tokenizers)
library(knitr)
library(tufte)
library(xtable)
library(lubridate)

doc_metadata <- function(partname) {
  list(
    title = str_glue("Mutual Muses {partname}"),
    subtitle = "The Correspondence of Lawrence Alloway and Sylvia Sleigh",
    author = list(
      "The Zooniverse Mutual Muses Community"
    ),
    date = as.character(Sys.Date())
  )
}

header <- function(partname = "") {

  specific_doc_meta <- doc_metadata(partname)

  str_glue(
    "
---
{as.yaml(specific_doc_meta)}---

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
}

replacements <- c(
  " +" = " ",
  "\\t" = " ",
  "\\\\" = " ",
  "˚" = "º"
)

create_title <- function(s, n = 7) {
  word_tokens <- tokenize_words(s, lowercase = FALSE, simplify = TRUE, stopwords = "unclear")
  section_brief <- paste0(word_tokens[1:n], collapse = " ")
  str_glue("{section_brief}...")
}

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
    imap(components, produce_chapter, partname = partname)
  )
}

produce_chapter <- function(df, chapname, partname) {
  if (nrow(df) > 0) {
    named_input <- list(filename = df$file_name,
                        text = df$annotation_text,
                        image_path = df$full_path,
                        user = df$user_name,
                        completed = df$day_of,
                        has_drawing = df$has_drawing)
    c(
      str_glue("# {chapname} {partname}"),
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

  drawing_note <- if_else(has_drawing, "\\index{Drawings}", "")

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


