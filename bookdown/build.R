# Convert the results of transcription ranking in to a structured yaml file that
# can be easily processed into a pdf or website

library(tidyverse)
library(yaml)
library(bookdown)
library(fs)

available_images <- dir_ls("images", glob = "*.jpg") %>% path_file()

transcriptions <- read_csv("mm-post-process.csv") %>%
  filter(file_name %in% available_images) %>%
  mutate(annotation_text = str_trim(str_replace_all(annotation_text, c(" +" = " ", "\\t" = " ")))) %>%
  arrange(file_name) %>%
  slice(1:100)

filename <- transcriptions$file_name[1]
text <- transcriptions$annotation_text[1]
image_path <- transcriptions$file_name[1]


produce_spread <- function(filename, text, image_path) {
  header <- str_glue("# {filename}")
  body <- text

  image_body <- str_glue("include_graphics('images/{image_path}')")

  str_glue(
"

{header}

{body}



```{{r}}
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
  title = "Mutual Muses",
  output = list(
    "bookdown::tufte_book2" = list(
      toc = FALSE,
      split_by = "none",
      number_sections = FALSE
    )
  )
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

render_book("mutual_muses.Rmd", output_format = tufte_book2())

