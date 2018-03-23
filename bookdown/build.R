# Convert the results of transcription ranking in to a structured yaml file that
# can be easily processed into a pdf or website

library(tidyverse)
library(yaml)
library(bookdown)
library(fs)

available_images <- dir_ls("images", glob = "*.jpg") %>% path_file()

replacements <- c(
  " +" = " ",
  "\\t" = " ",
  "\\\\" = " "
)

transcriptions <- read_csv("mm-post-process.csv") %>%
  filter(file_name %in% available_images) %>%
  mutate(annotation_text = str_trim(str_replace_all(annotation_text, pattern = replacements))) %>%
  arrange(file_name)

filename <- transcriptions$file_name[1]
text <- transcriptions$annotation_text[1]
image_path <- transcriptions$file_name[1]

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

produce_spread <- function(filename, text, image_path) {
  header <- str_glue("# {filename}")
  body <- text

  parsed_path <- parse_path(filename)

  caption <- str_glue("Series {parsed_path$year}.{parsed_path$letter}.{parsed_path$series}, box {parsed_path$box}, folder {parsed_path$folder}, sheet {parsed_path$sheet}")

  image_body <- str_glue("include_graphics('images/{image_path}')")

  str_glue(
"

{header}

{body}

```{{r, out.width = '100%', fig.fullwidth = TRUE, fig.cap = '{caption}'}}
{image_body}
```


")
}

named_input <- list(filename = transcriptions$file_name,
                    text = transcriptions$annotation_text,
                    image_path = transcriptions$file_name)

spreads <- pmap(named_input, produce_spread)
spreads[1]

spread_paths <- path("scratch", path_ext_set(transcriptions$file_name, "Rmd"))

doc_metadata <- list(
  title = "Mutual Muses"
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
error = TRUE
)
```
")

rmd_path <- "mutual_muses.Rmd"

write_lines(header, path = rmd_path)

walk(spreads, ~ write_lines(., path = rmd_path, append = TRUE))

render_book("mutual_muses.Rmd", output_format = "bookdown::tufte_book2")

