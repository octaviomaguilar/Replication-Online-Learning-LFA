library(ggplot2)

# Create the data for the "2011-2018" phase only
data_combined <- data.frame(
  variable = c("Quartile 2", "Quartile 3", "Quartile 4"),
  estimate = c(0.007503, 0.17104, 0.175331),
  se = c(0.018193, 0.020888, 0.023712),
  low_ci = c(0.043162, 0.22982, 0.221805),
  high_ci = c(-0.02816, 0.1301, 0.128856),
  phase = "2011-2018"  # Added 'phase' column with the phase label
)

# Specify the order of the x-axis labels
x_axis_order_combined <- c("Quartile 2", "Quartile 3", "Quartile 4")
data_combined$variable <- factor(data_combined$variable, levels = x_axis_order_combined)

scaleFUN <- function(x) {
  formatted_labels <- format(x, nsmall = 1)
  formatted_labels[formatted_labels == "0.0"] <- "0.0"
  paste0(formatted_labels)
}

# Create the plot for the "2011-2018" phase only
plot_combined <- ggplot(data_combined, aes(x = variable, color = phase)) +
  geom_point(aes(y = estimate), size = 1.20, position = position_dodge(width = 0.40)) +
  geom_errorbar(aes(ymin = low_ci, ymax = high_ci), size = 0.1, 
                width = 0.2, 
                color = "black", 
                position = position_dodge2(width = 0.4)) +  # Set error bar color to black
  geom_hline(yintercept = 0.28, linetype = "dashed", color = "black", size = 0.3) +
  labs(title = "",
       x = "",
       y = "",
       color = "Phase") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    panel.border = element_blank(),
    panel.spacing = unit(0.5, "lines"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line.x = element_line(color = "black", size = 0.25),
    axis.line.y = element_line(color = "black", size = 0.25),
    axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = -3, size = 6.2, family = "CM Roman"),
    axis.ticks.length.y = unit(-0.10, "cm"),
    axis.title.y = element_text(vjust = 1),
    axis.text.y = element_text(vjust = 0.5, hjust = -6, size = 6.2, family = "CM Roman"),
    axis.text.y.left = element_blank(),
    axis.text.y.right = element_text(hjust = 1.2), 
    plot.margin = margin(0.1, 0.1, 0.1, 0.1, "cm"),
    axis.ticks.x = element_line(size = unit(0.3, "cm"), color = "black"),
    axis.ticks.length.x = unit(-0.10, "cm"),
    axis.ticks.y = element_line(size = unit(0.3, "cm"), color = "black"),
    axis.ticks.margin = unit(0.2, "cm"),
    legend.text = element_text(size = 5, family = "CM Roman"),  # Adjust the size here for the legend text
    legend.position = c(0.97, 0.40),
    legend.justification = c("right", "top"),
    legend.box.just = "right",
    legend.margin = margin(0, 3, 0, 0),
    legend.spacing.x = unit(-0.1, "cm"),  # Adjust the spacing between dot and label
  ) +
  coord_cartesian(clip = "off", ylim = c(-0.04, 0.28)) +
  scale_color_manual(values = c("2011-2018" = "blue")) +
  scale_y_continuous(
    expand = c(0, 0), 
    breaks = seq(0.00, 0.28, by = 0.04),
    sec.axis = sec_axis(
      trans = ~., 
      breaks = seq(-0.04, 0.28, by = 0.04), 
      labels = c("", scaleFUN(seq(0.00, 0.27, 0.04)), "")
    )
  ) +
  annotate("text", x = 3.45, y = 0.29, label = "Coefficient", size = 1.8, family = "CM Roman")

# Remove the legend title
plot_combined <- plot_combined +
  theme(legend.title = element_blank(),
        legend.key.height = unit(0.50, "lines")) +
  guides(color = FALSE)  # This line removes the legend for the color (blue dot and "2011-2018")

# View the modified plot
print(plot_combined)

filename <- "ols_ipums_cps_xtile_wage.eps"  # Specify the desired filename
ggsave(paste0("/mq/home/m1oma00/Michael/michael_egon/",filename), plot = plot_combined, width = 4.75, height = 2.10, units = "in", device = cairo_ps)

filename_pdf <- "ols_ipums_cps_xtile_wages.pdf"  # Specify the desired filename with a .pdf extension
ggsave(paste0("/mq/home/m1oma00/Michael/michael_egon/", filename_pdf), plot = plot_combined, width = 4.75, height = 2.10, units = "in", device = cairo_pdf)
