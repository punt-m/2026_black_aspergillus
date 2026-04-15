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

