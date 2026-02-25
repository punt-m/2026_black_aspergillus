rm(list= ls())
library(openxlsx)
library(tidyverse)
library(janitor)
getwd()
xl = 'data/meta_info_2026.xlsx'
MICs = read.xlsx(xl,sheet =1 ) %>% clean_names()

df = MICs%>% 
  select(origin, specimen_types, species) %>%
  group_by(origin, specimen_types) %>%
  #Add species to study per species
  #group_by(origin, specimen_types,species) %>%
  summarise(count = n()) 


#%>% pivot_wider(names_from = species, values_from = count)

write.xlsx(df, 'results/Specimen_types.xlsx')

