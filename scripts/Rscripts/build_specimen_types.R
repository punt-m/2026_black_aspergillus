library(tidyverse)
library(janitor)
xl = 'data/meta_info_2026.csv'
MICs = read.csv(xl) %>% clean_names()

df = MICs%>% 
  select(origin, specimen_types, species) %>%
  group_by(origin, specimen_types) %>%
  #Add species to study per species
  #group_by(origin, specimen_types,species) %>%
  summarise(count = n(), .groups = 'drop_last') %>%
  mutate(perc = count / sum(count) * 100)


#%>% pivot_wider(names_from = species, values_from = count)

write.csv(df, 'results/Specimen_types.csv')

