# Figure 4: publication takeoff and citation timing
# Run from the package root with: Rscript run.R 4

# Select annual confirmed publication counts for 2011 through 2025.
f4a <- annual_growth %>%
  filter(population == "Confirmed Scenes", between(year, 2011, 2025)) %>%
  select(year, publications = works)

# Specify the six citation histories to display and their label order.
selected_cases <- c(
  "Xu-Zhao-Clark 2012",
  "Wu-Xia-Clark 2013",
  "Wu 2014 review",
  "Chen-Hou 2017",
  "Wen-Dai 2021",
  "Chen-Yan 2022"
)
case_labels <- c(
  "Xu-Zhao-Clark 2012" = "Xu-Zhao-Clark\n2012",
  "Wu-Xia-Clark 2013" = "Wu-Xia-Clark\n2013",
  "Wu 2014 review" = "Wu 2014",
  "Chen-Hou 2017" = "Chen-Hou 2017",
  "Wen-Dai 2021" = "Wen-Dai 2021",
  "Chen-Yan 2022" = "Chen-Yan 2022"
)
case_colors <- c(
  "Xu-Zhao-Clark 2012" = "#19364A",
  "Wu-Xia-Clark 2013" = "#315D72",
  "Wu 2014 review" = "#4D7E8F",
  "Chen-Hou 2017" = teal,
  "Wen-Dai 2021" = purple,
  "Chen-Yan 2022" = gold
)

# Keep the selected histories through 2025 and order them for plotting.
f4b <- citation_histories %>%
  filter(case_label %in% selected_cases, citing_year <= 2025) %>%
  mutate(case_label = factor(case_label, levels = selected_cases))
# Find the last point of each history and attach its direct label.
f4b_end <- f4b %>%
  group_by(case_label) %>%
  slice_max(years_since_publication, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(direct_label = unname(case_labels[as.character(case_label)]))

# Draw annual publication counts as bars.
p4a <- ggplot(f4a, aes(year, publications)) +
  geom_col(fill = navy, width = 0.72) +
  geom_vline(xintercept = 2019.5, linetype = "dotted", color = "#7C8792", linewidth = 0.55) +
  scale_x_continuous(breaks = c(2011, 2014, 2017, 2020, 2023, 2025)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(title = "A. Annual publication output", x = "Publication year", y = "Scenes Publications") +
  theme_panel(9.3) + theme(panel.grid.major.x = element_blank())

# Draw cumulative citation histories against years since publication.
p4b <- ggplot(f4b, aes(years_since_publication, cumulative_citing_sources,
                       color = case_label, group = case_label)) +
  geom_line(linewidth = 0.9) +
  geom_point(data = f4b_end, size = 1.9) +
  geom_text(
    data = f4b_end,
    aes(label = direct_label),
    hjust = 0, nudge_x = 0.25, size = 3.0, show.legend = FALSE
  ) +
  scale_color_manual(values = case_colors, guide = "none") +
  scale_x_continuous(breaks = 0:13, limits = c(0, 16.2), expand = expansion(mult = c(0.01, 0))) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.07))) +
  labs(title = "B. Citations at the same publication age", x = "Years since publication",
       y = "Cumulative unique citing publications") +
  theme_panel(9.3) +
  theme(panel.grid.major.x = element_blank())

# Combine the publication and citation-history panels.
p4 <- p4a + p4b + plot_layout(widths = c(0.82, 1.35)) +
  plot_annotation(
    title = "Chinese scenes research took off after 2020",
    caption = str_wrap(
      "Panel A shows the annual number of Scenes publications. Panel B compares the cumulative number of publications that cite key selected Scenes articles at the same number of years after publication. Lines extend through the 2025 display cutoff, so recent articles have shorter citation histories.",
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
save_figure(p4, "figure_04_publication_takeoff_and_citation_timing", 10.2, 5.98)
write_csv(f4a, file.path(table_dir, "figure_04a_annual_publications.csv"), na = "")
write_csv(f4b %>% mutate(case_label = as.character(case_label)),
          file.path(table_dir, "figure_04b_citation_age_histories.csv"), na = "")
