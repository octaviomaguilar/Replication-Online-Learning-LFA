library(ggplot2)

# Combine the data for the two panels into a single data frame and add a 'phase' column
data_combined <- rbind(
  data.frame(
    variable = c("Two","Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen"),
    estimate = c(0.1208316,	0.1110865,	0.0578944,	0.0795354,	0.091766,	0.085331,	0.0763201,	0.0842728,	0.0695959,	0.0684883,	0.054551,	0.0529644,	0.0491159
),
    se = c(0.0483422,	0.0517536,	0.0423829,	0.0437696,	0.0393661,	0.0357076,	0.0350024,	0.0351015,	0.0337261,	0.0304731,	0.0289877,	0.02767,	0.0262532	
),
    low_ci = c(0.026080888,	0.009649444,	-0.025176084,	-0.006253016,	0.014608444,	0.015344104,	0.007715396,	0.01547386,	0.003492744,	0.008761024,	-0.002264892,	-0.0012688,	-0.002340372	
),
    high_ci = c(0.215582312,	0.212523556,	0.140964884,	0.165323816,	0.168923556,	0.155317896,	0.144924804,	0.15307174,	0.135699056,	0.128215576,	0.111366892,	0.1071976,	0.100572172	
),      
    phase = "2019-2020"  # Added 'phase' column with the phase label
  ),
  data.frame(
    variable = c("Two","Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen"),
    estimate = c(-0.0039199,	0.0064493,	0.0422489,	0.0450465,	0.0454671,	0.0514414,	0.0615638,	0.0738339,	0.0674243,	0.0702456,	0.0707019,	0.0665521,	0.055709	
),
    se = c(0.0567786,	0.0459004,	0.041,	0.0442816,	0.0418322,	0.0397856,	0.0364609,	0.0347854,	0.0310453,	0.0284644,	0.0278207,	0.0243373,	0.0228974	
),
    low_ci = c(-0.115205956,	-0.083515484,	-0.0381111,	-0.041745436,	-0.036524012,	-0.026538376,	-0.009899564,	0.005654516,	0.006575512,	0.014455376,	0.016173328,	0.018850992,	0.010830096	
),
    high_ci = c(0.107366156,	0.096414084,	0.1226089,	0.131838436,	0.127458212,	0.129421176,	0.133027164,	0.142013284,	0.128273088,	0.126035824,	0.125230472,	0.114253208,	0.100587904	
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
  geom_hline(yintercept = 0.23, linetype = "dashed", color = "black", size = 0.3) +
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
    legend.position = c(0.97, 0.25),
    legend.justification = c("right", "top"),
    legend.box.just = "right",
    legend.margin = margin(0, 3, 0, 0),
    legend.spacing.x = unit(-0.1, "cm"),  # Adjust the spacing between dot and label
  ) +
  coord_cartesian(clip = "off", ylim = c(-0.12, 0.23)) +
  scale_color_manual(values = c("2019-2020" = "red", "2021-2022" = "blue")) +
  scale_y_continuous(
    expand = c(0, 0), 
    breaks = seq(-0.09, 0.23, by = 0.03),
    sec.axis = sec_axis(
      trans = ~., 
      breaks = seq(-0.09, 0.23, by = 0.03), 
    )
  ) +
  annotate("text", x = 13.00, y = 0.24, label = "Coefficient", size = 1.8, family = "CM Roman")


# Remove the legend title
plot_combined <- plot_combined +
  theme(legend.title = element_blank(),
        legend.key.height = unit(0.50, "lines")) +
  guides(shape = FALSE)


# View the combined plot
print(plot_combined)

filename <- "jobkeeping_exit_coef_child.eps"  # Specify the desired filename
ggsave(paste0("/mq/home/m1oma00/Michael/michael_egon/",filename), plot = plot_combined, width = 4.75, height = 2.10, units = "in", device = cairo_ps)

filename_pdf <- "jobkeeping_exit_coef_child.pdf"  # Specify the desired filename with a .pdf extension
ggsave(paste0("/mq/home/m1oma00/Michael/michael_egon/", filename_pdf), plot = plot_combined, width = 4.75, height = 2.10, units = "in", device = cairo_pdf)

