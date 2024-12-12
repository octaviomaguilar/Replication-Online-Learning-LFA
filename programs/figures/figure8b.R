library(ggplot2)

# Combine the data for the two panels into a single data frame and add a 'phase' column
data_combined <- rbind(
  data.frame(
    variable = c("Two","Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen"),
    estimate = c(-0.0864171, -0.0760732, -0.0406795,	-0.0569814,	-0.069155,	-0.067232,	-0.0548301,	-0.0659203,	-0.0577483,	-0.0570807,	-0.0511731,	-0.0515474,	-0.0470324),
    se = c(0.0339906,	0.0331048, 0.0257269,	0.028948,	0.0259289,	0.0232816,	0.0229237,	0.0232217,	0.0241243,	0.0215509,	0.0203722,	0.0192263,	0.0184132),
    low_ci = c(-0.153038676,	-0.140958608,	-0.091104224,	-0.11371948,	-0.119975644,	-0.112863936,	-0.099760552,	-0.111434832,	-0.105031928,	-0.099320464,	-0.091102612,	-0.089230948,	-0.083122272
),
    high_ci = c(-0.019795524,	-0.011187792,	0.009745,	-0.00024332,	-0.018334356,	-0.021600064,	-0.009899648,	-0.020405768,	-0.010464672,	-0.014840936,	-0.011243588,	-0.013863852,	-0.010942528
),
    phase = "2019-2020"  # Added 'phase' column with the phase label
  ),
  data.frame(
    variable = c("Two","Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen"),
    estimate = c(-0.0183808,	-0.0234805,	-0.0464968,	-0.0550711,	-0.0505669,	-0.0478951,	-0.0547274,	-0.0607627,	-0.0601236,	-0.0609813,	-0.0618632,	-0.0553616,	-0.0472948
),
    se = c(0.0408902,	0.0340842,	0.0318726,	0.0346075,	0.0328686,	0.0325165,	0.0295557,	0.0275198,	0.0257968,	0.0240816,	0.0236218,	0.0208269,	0.0197129
),
    low_ci = c(-0.098525592,	-0.090285532,	-0.108967096,	-0.1229018,	-0.114989356,	-0.11162744,	-0.112656572,	-0.114701508,	-0.110685328,	-0.108181236,	-0.108161928,	-0.096182324,	-0.085932084
),
    high_ci = c(0.061763992,	0.043324532,	0.015973496,	0.0127596,	0.013855556,	0.01583724,	0.003201772,	-0.006823892,	-0.009561872,	-0.013781364,	-0.015564472,	-0.014540876,	-0.008657516
),      
    phase = "2021-2022"  # Added 'phase' column with the phase label
  )

)

# Specify the order of the x-axis labels
x_axis_order_combined <- c("Two","Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen")
data_combined$variable <- factor(data_combined$variable, levels = x_axis_order_combined)

scaleFUN <- function(x) {
  formatted_labels <- format(x, nsmall = 1)
  formatted_labels[formatted_labels == "0.0"] <- "0.0"
  paste0(formatted_labels)
}
# Create the plot with both panels side by side and a legend
plot_combined <- ggplot(data_combined, aes(x = variable, color = phase)) +
  geom_point(aes(y = estimate), size = 1.20, position = position_dodge(width = 0.40)) +
  geom_errorbar(aes(ymin = low_ci, ymax = high_ci), size = 0.1, 
                width = ifelse(data_combined$phase == "2019-2020", 0.4, 0.4), 
                color = "black", 
                position = position_dodge2(width = 0.4)) +  # Set error bar color to black
  geom_hline(yintercept = 0, linetype = "dashed", color = "black", size = 0.3) +
  geom_hline(yintercept = 0.07, linetype = "dashed", color = "black", size = 0.3) +
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
    axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = -3, size = 5.5, family = "CM Roman"),
    axis.ticks.length.y = unit(-0.10, "cm"),
    axis.title.y = element_text(vjust = 1),
    axis.text.y = element_text(vjust = 0.5, hjust = -6, size = 5.5, family = "CM Roman"),
    axis.text.y.left = element_blank(),
    axis.text.y.right = element_text(hjust = 1.2), 
    plot.margin = margin(0.1, 0.1, 0.1, 0.1, "cm"),
    axis.ticks.x = element_line(size = unit(0.3, "cm"), color = "black"),
    axis.ticks.length.x = unit(-0.20, "cm"),
    axis.ticks.y = element_line(size = unit(0.3, "cm"), color = "black"),
    axis.ticks.margin = unit(0.2, "cm"),
    legend.text = element_text(size = 5, family = "CM Roman"),  # Adjust the size here for the legend text
    legend.position = c(0.97, 0.40),
    legend.justification = c("right", "top"),
    legend.box.just = "right",
    legend.margin = margin(0, 3, 0, 0),
    legend.spacing.x = unit(-0.1, "cm"),  # Adjust the spacing between dot and label
  ) +
  coord_cartesian(clip = "off", ylim = c(-0.20, 0.07)) +
  scale_color_manual(values = c("2019-2020" = "red", "2021-2022" = "blue")) +
  scale_y_continuous(
    expand = c(0, 0), 
    breaks = seq(-0.18, 0.07, by = 0.02),
    sec.axis = sec_axis(
      trans = ~., 
      breaks = seq(-0.18, 0.07, by = 0.02), 
    )
  ) +
  annotate("text", x = 13.00, y = 0.08, label = "Coefficient", size = 1.8, family = "CM Roman")


# Remove the legend title
plot_combined <- plot_combined +
  theme(legend.title = element_blank(),
        legend.key.height = unit(0.50, "lines")) +
  guides(shape = FALSE)


# View the combined plot
print(plot_combined)

filename <- "LF_exit_coef_child.eps"  # Specify the desired filename
ggsave(paste0("/mq/home/m1oma00/Michael/michael_egon/",filename), plot = plot_combined, width = 4.75, height = 2.10, units = "in", device = cairo_ps)

filename_pdf <- "LF_exit_coef_child.pdf"  # Specify the desired filename with a .pdf extension
ggsave(paste0("/mq/home/m1oma00/Michael/michael_egon/", filename_pdf), plot = plot_combined, width = 4.75, height = 2.10, units = "in", device = cairo_pdf)

