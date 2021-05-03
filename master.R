# This script produces all the files required to deploy an SNSF data story. 
# 
# By running this file, the following components of a data story are generated
# and stored in the output directory: 
# 
# 1) a HTML file (self-contained), which contains all visualizations and 
#   images in encoded form, one for every specified language.
# 2) one file "metadata.json", which contains the metadata essential for 
#   the story (including all language versions in one file).
# 
# The files are stored in output/xxx, where xxx stands for the title of the
# data story in English, how it can also be used for the vanity URL to the 
# story, that means: no special characters, only lowercase.

# Unique name of this data story in English (all lowercase, underscore as 
# white-space, no special characters etc.)
datastory_name <- "key_figures_2020"

# Language-specific names, do adapt! (used for vanity URL! Format: all 
# lowercase, minus as white-space (!) and no special characters, no special 
# characters etc.)
datastory_name_de <- "kennzahlen-2020"
datastory_name_en <- "key-figures-2020"
datastory_name_fr <- "chiffres-cles-2020"

# Contact persons, always (first name + last name)
contact_person <- c("datastories@snf.ch")
# Mail address to be displayed as contact persons, put "datastories@snf.ch" for 
# every name of a contact person listed above.
contact_person_mail <- c("datastories@snf.ch")
# One of the following categories:  "standard", "briefing", "techreport", 
# "policybrief", "flagship", "figure". Category descriptions are 
datastory_category <- "standard"
# Date, after which the story should be published. Stories not displayed if the 
# date lies in the future. 
publication_date <- "2021-05-04 05:00:00"
# Available language versions in lowercase, possible: "en", "de", "fr".
languages <- c("en", "de", "fr") 
# English title of the story (Mandatory, even if there is no EN story version)
title_en <- "937 million Swiss francs for 3300 new research projects" 
# German title of the story (Mandatory, even if there is no DE story version)
title_de <- "3300 neue Forschungsprojekte für 937 Millionen Franken" 
# French title of the story (Mandatory, even if there is no FR story version)
title_fr <- "3 300 nouveaux projets de recherche pour 937 millions de francs"
# English Lead of the story (Mandatory, even if there is no EN story version)
lead_en <- "In 2020, researchers submitted 8200 grant applications to the SNSF. 3300 of them were selected for funding in a competitive process. At short notice, the SNSF funded 73 projects on COVID-19." 
# German Lead of the story (Mandatory, even if there is no DE story version)
lead_de <- "Im Jahr 2020 haben Forschende 8200 Fördergesuche beim SNF eingereicht. Er wählte in wettbewerbsorientierten Verfahren 3300 davon aus. Kurzfristig finanzierte er 73 Projekte zu Covid-19." 
# French Lead of the story (Mandatory, even if there is no FR story version)
lead_fr <- "En 2020, le FNS a reçu 8 200 requêtes et en a retenu 3 300 lors d’une procédure compétitive. De plus, 73 projets sur le Covid-19 ont été sélectionnés en accéléré." 
# Whether this story should be a "Feature Story" story (true/false)
feature_story <- FALSE
# DOI of the story (optional)
doi <- "" 
# URL to Github page (optional)
github_url <- "https://github.com/snsf-data/datastory_key_figures_2020/" 
# Put Tag IDs here. Only choose already existing tags. 
tags_ids <- c(40, 80, 60, 170)

# IMPORTANT: Put a title image (as .jpg) into the output directory. 
# example: "output/datastory-template.jpg"

# Install pacman package if needed
if (!require("pacman")) {
  install.packages("pacman")
}

# Install snf.datastory package if not available, otherwise load it
if (!require("snf.datastory")) {
  if (!require("devtools")) {
    install.packages("devtools")
  }
  install_github("snsf-data/snf.datastory")
}

# Load packages
p_load(tidyverse,
       scales, 
       conflicted, 
       jsonlite, 
       here)

# Conflict preferences
conflict_prefer("filter", "dplyr")

# Function to validate a mandatory parameter value
is_valid <- function(param_value) {
  if (is.null(param_value))
    return(FALSE)
  if (is.na(param_value))
    return(FALSE)
  if (str_trim(param_value) == "")
    return(FALSE)
  return(TRUE)
}

# Validate parameters and throw error message when not correctly filled
if (any(!is_valid(datastory_name), 
        !is_valid(title_en),
        !is_valid(title_de),
        !is_valid(title_fr), 
        !is_valid(datastory_category),
        !is_valid(publication_date), 
        length(languages) < 1,
        !is_valid(lead_en), 
        !is_valid(lead_de), 
        !is_valid(lead_fr)))
stop("Incorrect value for at least one of the mandatory metadata values.")

# Create output directory in main directory
if (!dir.exists(here("output")))
  dir.create(here("output"))

# Create story directory in output directory
if (!dir.exists(here("output", datastory_name)))
  dir.create(here("output", datastory_name))

# Create a JSON file with the metadata and save it in the output directory
tibble(
  title_en = title_en, 
  title_de = title_de, 
  title_fr = title_fr, 
  author = paste(contact_person, collapse = ";"), 
  datastory_category = datastory_category, 
  publication_date = publication_date, 
  languages = paste(languages, collapse = ";"),
  short_desc_en = lead_en, 
  short_desc_de = lead_de, 
  short_desc_fr = lead_fr, 
  tags = paste(paste0("T", tags_ids, "T"), collapse = ","), 
  author_url = paste(contact_person_mail, collapse = ";"), 
  top_story = feature_story, 
  github_url = github_url, 
  doi = doi
) %>%  
  toJSON() %>%  
  write_lines(here("output", datastory_name, "metadata.json"))

# Knit HTML output for each language version
for (idx in seq_len(length(languages))) {
  current_lang <- languages[idx]
  output_file <- here("output", datastory_name, 
                      paste0(str_replace_all(
                        get(paste0("datastory_name_", current_lang)), "_", "-"),
                        "-", current_lang, ".html"))
  print(paste0("Generating output for ", current_lang, " version..."))
  rmarkdown::render(
    input = here(paste0(current_lang, ".Rmd")),
    output_file = output_file, 
    params = list(
      title = get(paste0("title_", current_lang)),
      publication_date = publication_date,
      doi = doi
    ),
    envir = new.env()
  )
  
  # # Generate raw text version of each story for the search feature
  # readLines(output_file)

  # # inputFile <- "
  # con  <- file(output_file, open = "r")
  # while (length(oneLine <- readLines(con, n = 1)) > 0) {
  #   myLine <- unlist((strsplit(oneLine, ",")))
  #   print(myLine)
  # }
  # close(con)
}