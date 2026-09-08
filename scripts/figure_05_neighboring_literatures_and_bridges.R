# Figure 5: neighboring literatures and bridges
# Run from the package root with: Rscript run.R 5

# Select confirmed and adjacent publication series and set their line labels.
f5a <- annual_growth %>%
  filter(population %in% c("Confirmed Scenes", "Adjacent/convergent"), between(year, 2010, 2025)) %>%
  mutate(
    population = factor(population, levels = c("Confirmed Scenes", "Adjacent/convergent")),
    display_label = if_else(
      as.character(population) == "Confirmed Scenes",
      "Scenes Publications",
      "Neighboring work"
    )
  )
f5a_end <- f5a %>% group_by(population) %>% filter(year == max(year)) %>% ungroup()
# Select 2020–2024 bridge counts and the matching multi-target denominators.
f5b <- bridge_years %>%
  filter(between(citing_year, 2020, 2024)) %>%
  transmute(
    year = citing_year,
    bridge_publications = bridge_sources,
    multi_target_publications = multi_target_sources,
    bridge_share_multi_target
  )

# Draw the trailing three-year publication means for the two populations.
p5a <- ggplot(f5a, aes(year, rolling_3yr, color = population, linetype = population)) +
  geom_line(linewidth = 1.0) +
  geom_point(data = f5a_end, size = 2.0) +
  geom_text(data = f5a_end, aes(label = display_label), hjust = 1, nudge_x = -0.25,
            size = 2.9, show.legend = FALSE) +
  scale_color_manual(values = c("Confirmed Scenes" = navy, "Adjacent/convergent" = "#AAB6BF"), guide = "none") +
  scale_linetype_manual(values = c("Confirmed Scenes" = "solid", "Adjacent/convergent" = "dashed"), guide = "none") +
  scale_x_continuous(breaks = c(2010, 2013, 2016, 2019, 2022, 2025), limits = c(2010, 2028)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(title = "A. Publication growth", x = "Publication year", y = "Three-year rolling average") +
  theme_panel(9.3)

# Draw bridge counts and label each bar with its share of multi-target citers.
p5b <- ggplot(f5b, aes(factor(year), bridge_publications)) +
  geom_col(fill = orange, width = 0.68) +
  geom_text(aes(label = bridge_publications), vjust = 1.45, color = "white", fontface = "bold", size = 3.1) +
  geom_text(aes(label = percent(bridge_share_multi_target, accuracy = 1)),
            vjust = -0.45, color = "#4B5563", size = 2.9) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.16))) +
  labs(title = "B. Publications bridging Scenes and neighboring work",
       x = "Year of citing publication", y = "Bridge publications") +
  theme_panel(9.3) + theme(panel.grid.major.x = element_blank())

# Combine the publication-growth and bridge-count panels.
p5 <- p5a + p5b + plot_layout(widths = c(1.15, 1)) +
  plot_annotation(
    title = "Scenes research became more prominent while remaining connected to neighboring literatures",
    caption = str_wrap(
      "Panel A compares three-year rolling averages for Scenes publications and neighbouring literatures. Neighbouring literatures include related research on amenities, consumption, place, tourism, creative cities, media, and similar topics outside the Scenes tradition. Panel B counts publications that cited work in both groups. Percentages show their share of publications that cited multiple articles in the combined literature.",
      width = 155
    ),
    theme = theme(
      plot.title = element_text(family = "Helvetica", face = "bold", size = 14,
                                color = "#111827", margin = margin(b = 10)),
      plot.caption = element_text(family = "Helvetica", hjust = 0, size = 7.6,
                                  lineheight = 1.18, color = "#374151", margin = margin(t = 9))
    )
  )

# Save the figure and the tables used to construct it.
save_figure(p5, "figure_05_neighboring_literatures_and_bridges", 10.2, 6.08)
write_csv(f5a %>% mutate(population = as.character(population)),
          file.path(table_dir, "figure_05a_growth_comparison.csv"), na = "")
write_csv(f5b, file.path(table_dir, "figure_05b_bridge_publications.csv"), na = "")
