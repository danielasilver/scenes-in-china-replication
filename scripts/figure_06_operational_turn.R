# Figure 6: operational turn
# Run from the package root with: Rscript run.R 6

marker_colors <- c("Design" = orange, "Policy" = navy, "Measurement" = blue)
# Select three marker series and calculate period positions and percent labels.
f6_data <- engineering_period %>%
  filter(period_label %in% periods, marker %in% names(marker_colors)) %>%
  mutate(
    period_label = factor(period_label, levels = periods),
    period_index = as.numeric(period_label),
    marker = factor(marker, levels = c("Design", "Policy", "Measurement")),
    value_label = percent(share, accuracy = 1),
    value_label_y = share + if_else(as.character(marker) == "Measurement", -0.017, 0.017)
  )
# Keep the final period’s rows for labels at the ends of the lines.
f6_end <- f6_data %>% filter(period_label == "2023–2025")

# Draw marker shares as lines, with a percentage label at each point.
p6 <- ggplot(f6_data, aes(period_index, share, color = marker, group = marker)) +
  geom_line(linewidth = 1.15) +
  geom_point(size = 2.8) +
  geom_text(aes(y = value_label_y, label = value_label), vjust = 0.5,
            color = "#374151", size = 2.8, show.legend = FALSE) +
  geom_text(
    data = f6_end,
    aes(x = period_index + 0.12, label = as.character(marker)),
    hjust = 0, vjust = 0.5, fontface = "bold", size = 3.0, show.legend = FALSE
  ) +
  scale_color_manual(values = marker_colors, guide = "none") +
  scale_x_continuous(
    breaks = 1:4,
    labels = c("2012–2016\n(n = 15)", "2017–2019\n(n = 39)",
               "2020–2022\n(n = 128)", "2023–2025\n(n = 259)"),
    limits = c(0.92, 4.55)
  ) +
  scale_y_continuous(labels = percent_format(accuracy = 1), breaks = seq(0, 0.4, 0.1),
                     limits = c(0, 0.40), expand = expansion(mult = c(0, 0.08))) +
  labs(
    title = "Chinese scenes research increasingly focuses on designing and making scenes",
    x = NULL, y = "Share of Scenes publications"
  ) +
  theme_intro(10.2) + theme(panel.grid.major.x = element_blank())

# Draw marker shares as lines, with a percentage label at each point.
p6 <- add_figure_caption(
  p6,
  "Lines show the share of Scenes publications whose titles refer to design, policy, or measurement. These categories overlap, so a publication may be counted in more than one.",
  wrap_width = 118
)

# Save the figure and the tables used to construct it.
save_figure(p6, "figure_06_operational_turn", 7.6, 5.42)
write_csv(f6_data %>% mutate(across(where(is.factor), as.character)),
          file.path(table_dir, "figure_06_operational_indicators.csv"), na = "")
