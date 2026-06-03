make_mic_plot <- function(input_data,col,colors, label, lvls, breakpoint = NULL,show_legend = FALSE, facet_by = NULL) {
  guide_setting <- if (show_legend) "legend" else "none"
  
  p <- ggplot(input_data, aes(x = .data[[col]], fill = origin)) +
    geom_bar(position = "stack", na.rm = T) + # "count" stat is default for geom_bar
    scale_x_discrete(limits = lvls, drop = FALSE) +
    scale_fill_manual(values =colors ) +
    labs(x = paste(label, "(mg/L)"), fill = "") +
    base_theme +
    guides(fill = guide_setting)
  
  # Conditional Facet Grid
  if (!is.null(facet_by)) {
    # . ~ .data[[facet_by]] creates a horizontal grid based on your column
    p <- p + facet_grid(rows = vars(.data[[facet_by]]), cols = vars())
  }
  
  if (!is.null(breakpoint)) {
    p <- p + geom_vline(xintercept = which(lvls == breakpoint) + 0.5, linetype = 'dashed')
  }
  return(p)
}



getIsolates <- function(nodes, tree) {
  # Initialize a list or vector to collect isolates from all provided nodes
  all_groups <- list()
  for (node in nodes) {
    all_descendants <- phytools::getDescendants(tree, node)
    num_tips <- length(tree$tip.label)
    tip_indices <- all_descendants[all_descendants <= num_tips]
    
    node_tips <- tree$tip.label[tip_indices]
    all_groups[[as.character(node)]] <- node_tips
  }
  
  # If they only asked for 1 node, unlist it to return a clean vector
  if (length(nodes) == 1) {
    return(unname(unlist(all_groups)))
  }
  
  return(all_groups)
}