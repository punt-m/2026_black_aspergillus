plot_function <- function(df, plot_title='Manhattan Plot', chr_select=NULL, start=NULL, end=NULL) {
  
  # 1. Filter for a specific region if requested
  if (!is.null(chr_select)) {
    df <- df[df$chr == chr_select, ]
    if (!is.null(start)) df <- df[df$ps >= start, ]
    if (!is.null(end)) df <- df[df$ps <= end, ]
    
    # Switch X-axis mapping to 'ps' for regional views
    x_var <- "ps"
    x_label <- paste("Position on Scaffold", chr_select)
    x_scale <- scale_x_continuous() # Default scale for regional view
  } else {
    # Default for whole genome view
    x_var <- "BP_cum"
    x_label <- "Scaffold"
    x_scale <- scale_x_continuous(label = axis_set$chr, breaks = axis_set$center)
  }
  
  # 2. Generate Plot
  p <- ggplot(df, aes(x = .data[[x_var]], y = -log10(p_wald))) + # Use .data[[x_var]]
    geom_point(aes(color = as.factor(chr)), alpha = 1, size = 1) + 
    scale_color_manual(values = my_colors) +
    
    geom_hline(yintercept = -log10(5e-8), color = "red", linetype = "dashed") + 
    geom_hline(yintercept = -log10(1e-5), color = "blue", linetype = "dotted") +
    
    x_scale + 
    
    labs(x = x_label,
         y = expression(-log[10](italic(p))),
         title = plot_title) +
    theme_minimal() +
    theme(
      legend.position = "none",
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.text.x = element_text(angle = 0, hjust = 0.5)
    )
  
  return(p)
}

get_gene_snps <- function(gwas_df, gene_list) {
  
  # Use a fuzzy join approach to find SNPs between start and end
  filtered_snps <- gwas_df %>%
    inner_join(gene_list, by = c("chr")) %>%
    filter(ps >= start, ps <= end) %>%
    select(gene, gene_id, rs, chr, ps, p_wald, everything())
  
  return(filtered_snps)
}


genes <- data.frame(gene = c('cyp51A','cyp51B'),
                    gene_id = c('AtWU_06533','AtWU_09124'),
                    chr  = c(8,10),
                    start= c(582526,91551),
                    end  = c(584493,93312))
                    
my_colors <- rep(c("skyblue", "navy"), length.out = 15)


get_lambda <- function(p_vals){
  chisq <- qchisq(1 - p_vals, 1)
  lambda <- median(chisq) / qchisq(0.5, 1)
  print(paste("Genomic Inflation Factor (Lambda):", round(lambda, 4)))
}  

get_genes_of_interest <- function(gw_results, annotations, p_threshold = 1e-5, buffer = 0) {
  
  # 1. Filter SNPs by significance
  sig_snps <- gw_results %>% 
    filter(p_wald < p_threshold)
  
  # 2. Adjust annotation boundaries
  annot_buffered <- annotations %>%
    mutate(
      search_start = start - buffer,
      search_end = end + buffer
    )
  
  # 3. Perform the spatial join
  joined_data <- sig_snps %>%
    genome_inner_join(annot_buffered, 
                      by = c("chr", "ps" = "search_start", "ps" = "search_end")) %>%
    # 4. Clean up the duplicate chr columns
    rename(chr = chr.x) %>%
    select(-chr.y) %>%
    # Move core columns to the front for readability
    select(chr, ps, p_wald, gene_id, start, end, everything())
  
  return(joined_data)
}


download_data <- function(){
  ftp_path <- "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/013/340/325/GCF_013340325.1_ASM1334032v1/GCF_013340325.1_ASM1334032v1_feature_table.txt.gz"
  # 2. Download the file
  download.file(ftp_path, destfile = "feature_table.txt.gz")
  # 3. Read it directly into R
  feature_table <- fread("feature_table.txt.gz", sep = "\t", quote = "", fill = TRUE) %>% select(locus_tag,name) %>% filter(name != '') %>% rename(gene_id=locus_tag) %>% distinct()
  return(feature_table)
}
