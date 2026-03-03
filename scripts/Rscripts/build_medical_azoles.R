#install.packages('fansi', INSTALL_opts = '--no-lock', dependencies = F)
pkgs = c('tidyverse','janitor','ggplot2')
#install.packages(pkgs, INSTALL_opts = '--no-lock', dependencies = TRUE)
lapply(pkgs, require, character.only = TRUE)

base_loc = '~/my_scratch_dir/2026_black_aspergillus/'
data = openxlsx::read.csv(paste0(base_loc,'data/2026_meta_info.csv'))

mic_levels <- c("0.031", "0.062", "0.125", "0.25", "0.5", "1", "2", "4", "8", "16","32")

# Function to apply this order to a column
reorder_column_fixed <- function(x) {
  factor(x, levels = mic_levels, ordered = TRUE)
}

# List of MIC columns in your dataframe
mic_columns <- c("itc", "pos", "vrc", "vor", "teb", "pro", "dif", "pth")

# Apply to all MIC columns
for (col in mic_columns) {
  if (col %in% names(data)) {
    data[[col]] <- reorder_column_fixed(data[[col]])
  }
}

df = data %>% filter(species %in% c("aspergillus niger",'aspergillus tubingensis'))

# Optional: sort dataframe by one or more MIC columns
# Example: sort by ITC first, then POS
base_theme = theme(#panel.grid.major.y = element_line(colour = '#535353', linetype = 1, linewidth = 0.25),
  panel.grid.minor = element_blank(),
  strip.background = element_blank(),
  panel.background = element_blank(),
  axis.ticks = element_line(colour = '#535353'),
  legend.text = element_text(size =14),
  legend.title = element_text(size =16),
  strip.text.x = element_text(size = 20, face = 'bold'),
  axis.text.x=element_text(angle = 45, hjust = 1),
  axis.line.x.bottom = element_line(colour = "#535353", linewidth = 1))

color_set = c('#8fcae7','#777b00')



ITC = ggplot(df, aes(x = itc)) +
  geom_histogram(stat = "count", aes(fill = origin)) +
  #facet_grid(species~.) +  Uncomment this line to produce per species overview
  geom_vline(xintercept = '2',linetype = 'dotted',color = 'black') + 
  scale_x_discrete(limits = mic_levels, labels = mic_levels) +
  scale_fill_manual(values= color_set)+
  base_theme + guides(fill="none") +
  xlab('Itraconazole (mg/L)')

POS = ggplot(df, aes(x = pos)) +
  geom_histogram(stat = "count", aes(fill = origin)) + 
  #facet_grid(species~.) + Uncomment this line to produce per species overview
  scale_x_discrete(limits = mic_levels, labels = mic_levels) +
  geom_vline(xintercept = '0.5',linetype = 'dotted',color = 'black') + 
  
  scale_fill_manual(values= color_set)+
  base_theme + guides(fill="none") +xlab('Posaconazole (mg/L)')

VRC = ggplot(df, aes(x = vrc)) +
  geom_histogram(stat = "count", aes(fill = origin)) +
  #facet_grid(species~.) + Uncomment this line to produce per species overview
  geom_vline(xintercept = '2',linetype = 'dotted',color = 'black') + 
  
  scale_x_discrete(limits = mic_levels, labels = mic_levels) +
  scale_fill_manual(values= color_set)+
  base_theme +
  guides(fill="none") +
  xlab('Voriconazole (mg/L)')

legend = ggplot(df, aes(x = itc)) +
  geom_histogram(stat = "count", aes(fill = origin)) +
  #facet_grid(species~.) + 
  scale_x_discrete(limits = mic_levels, labels = mic_levels) +
  guides(fill = guide_legend(title = 'Origin')) + 
  scale_fill_manual(values= color_set)

legend_grob  = cowplot::get_legend(legend)
p = gridExtra::grid.arrange(ITC,POS,VRC,legend_grob , ncol = 2)

#save the plots:
ggsave(paste0(base_loc,'results/plots/MICs.svg'), width = 10, height = 8, plot = p)
