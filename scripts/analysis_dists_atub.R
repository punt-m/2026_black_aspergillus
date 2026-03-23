getwd()
rm(list = ls())
library(tidyverse)
# 1. Load the data
plink_df = read.table('raw_data/atubingensis_dists/highQual/atub_197iso.genome', header = T)  %>% 
  #select(FID1,FID2,IBS0,IBS1,IBS2,HOMHOM) %>% 
  mutate(SNP_dif = IBS0+IBS1) #%>% 
  #filter(FID1 %in% c(1:2000) & FID2 %in% c(1:2000))

variant_info = read.csv('raw_data/2026_variant_info.csv') %>% select(isolate,variant) %>% rename(strain = isolate)
info_df = read.csv('raw_data/2026_meta_info.csv')  %>% select(-1)
calif_df =read.table('raw_data/calif_MIC_data.txt', header = T) %>% 
  mutate_at(c('ITC','VOR','POS'),~ gsub('>','',.)) %>% 
  mutate_at(c('ITC','VOR','POS'),~ as.numeric(.)) %>% select(Species,ID,ITC,VOR,POS) %>% 
  rename(strain = ID, itc = ITC, pos =POS, vrc= VOR,species = Species) %>% mutate(origin = 'Clinical', location = 'California', strain = as.character(strain)) %>% 
  mutate(across(c(species), ~ gsub('A.','aspergillus ', .x)))

t = full_join(info_df,calif_df) %>% left_join(variant_info)
rm(variant_info,info_df,calif_df)

matching_df = t %>% select(strain,origin) %>% rename(match = strain, origin_match = origin)

df <- plink_df %>% filter(DST > 0.998) %>% rename(strain = FID1, match = FID2 ) %>%  left_join(t) %>% 
  select(strain, match, DST,origin,source,year_of_isolation,location) %>% left_join(matching_df)
rm(matching_df,plink_df)

if (!require("igraph")) install.packages("igraph")
library(igraph)
# 1. Create the graph object from your strain pairs
# We use only the 'strain' and 'match' columns
edges <- df[, c("strain", "match")]
g <- graph_from_data_frame(edges, directed = FALSE)
# 2. Find connected components (the clonal groups)
clusters <- components(g)
# 3. Create a lookup table for which strain belongs to which group
clonal_groups <- data.frame(
    strain = names(clusters$membership),
    group_id = as.vector(clusters$membership)
)
# 4. Count how many strains are in each group
    group_sizes <- as.data.frame(table(clonal_groups$group_id))
    colnames(group_sizes) <- c("group_id", "strains_count")
# 5. Merge everything back to see your clusters
    final_clusters <- merge(clonal_groups, group_sizes, by = "group_id")
    final_clusters <- final_clusters[order(-final_clusters$strains_count), ] %>% left_join(t)
    
write.csv(final_clusters,'output_data/cluster_data.csv')
