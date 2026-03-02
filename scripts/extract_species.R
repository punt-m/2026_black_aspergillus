#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")

#BiocManager::install("ggtree")
#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")

#BiocManager::install("ggtree")
#install.packages('ggtree')
library(ape)
library(ggtree)
library(ggplot2)
library(treeio)
library(tidyverse)
setwd("/rivm/s/puntm/tree_projects/")
t= read.newick(file = 'input_data/tree_info/UFCG_243_plusRefs.nwk')
md = read.csv(file = 'input_data/meta_info_2026.csv') %>% rename(file_name = strain)
strain_names = read.csv(file = 'input_data/study_samples_2026.csv') %>% 
  select(strain, file_name) %>% distinct()
meta_data <- left_join(md, strain_names) %>% mutate(strain = case_when(is.na(strain) ~ file_name, T ~ strain ))

t1 = root(t,outgroup = c('Aspergillus_homomorphus|none'))
labels = data.frame(label = t1$tip.label) %>% tidyr::separate(label, sep = '\\|', into = c("species",'file_name')) %>% 
  left_join(strain_names) %>% mutate(strain = case_when(is.na(strain) ~ file_name, T ~ strain )) %>% 
  mutate(strain = case_when(strain %in% c('none', 'CBS141172','CBS_134.48','CBS_513.88')   ~ species, 
                            TRUE ~ strain)) %>% 
  mutate(strain = gsub('_',' ', strain)) %>% 
  mutate(strain = gsub('DTO-','DTO', strain)) %>%
  mutate(strain = gsub('tubingenesis','tubingensis', strain))
t1$tip.label <- labels$strain
t1$tip.label  <- gsub('Aspergillus', 'A.', t1$tip.label) 

meta <- meta_data[c(2,4:11)]
rownames(meta) <- meta_data[,2]
meta <- meta[,-1] %>% mutate_at(1:3, as.numeric)
colnames(meta) <- c('Itraconazole','Posaconazole','Voriconazole', 'Tebuconazole','Prochloraz','Difenoconazole','Prothioconazole','Origin')
meta <- meta %>% mutate(resistance = case_when(Itraconazole >1 ~ 'NWT',
                                               Itraconazole < 2 ~ 'WT',
                                               is.na(Itraconazole) ~ NA, TRUE ~ ''))

p = groupOTU(t1, split(meta[2], meta$Origin),group_name = 'Origin') 
p1 = ggtree(t1)
#get Most recent common ancestor to determine which node divides these two species
shared_node = MRCA(p1, c("A. tubingensis", "A. niger"))
groups = offspring(p1, shared_node,tiponly = F) %>% filter(parent == shared_node)


#Get the nodes that fall in niger/tubingensis groups:
aniger_node = groups$node[which(groups$node %in% ancestor(p, p1$data$node[p1$data$label == 'A. niger']))]
atub_node = groups$node[which(groups$node %in% ancestor(p,   p1$data$node[p1$data$label == 'A. tubingensis']))]

#assign color block to species niger/tubingensis
tree_df = data.frame(node = c(aniger_node,atub_node), species = c('A. niger', 'A. tubingensis'))
p2 = p1 + geom_highlight(tree_df, aes(node = node, fill = species)) + new_scale_fill() + geom_tiplab(align = F)


aniger_strains = offspring(p2,aniger_node, tiponly = T) %>% 
  select(label) %>% 
  mutate(species = 'aspergillus niger')

atub_strains = offspring(p2,atub_node, tiponly = T) %>% 
  select(label) %>% 
  mutate(species = 'aspergillus tubingensis')

all_strains = rbind(aniger_strains,atub_strains) %>% rename(strain  = label)
#write strain ID labels to file
write.csv(all_strains,'output_data/species_id.csv')

t = left_join(meta_data, all_strains, by = 'strain') %>% mutate(species = case_when(species.x == 'no data' | is.na(species.x) ~ species.y , T ~species.x)) %>% 
  select(strain, species, flu,itc,pos,vrc,teb,pro,dif,pth,origin,azole_history,year_of_isolation,location,source,specimen_types,mating_type) %>% 
  mutate(species = case_when(strain == 'ASFU-8363' ~ "aspergillus brasiliensis",
                             strain %in% c("M043-17","DTO108-H8","DTO270-C8") ~ 'aspergillus japonicus',
                             T ~ species))

ggsave(plot = p2, 'plots/UFCG_tree.svg', height = 30, width = 20)
write.csv(t, 'output_data/2026_meta_info.csv')





