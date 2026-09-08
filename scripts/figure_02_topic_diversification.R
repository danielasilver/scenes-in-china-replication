# Figure 2: topic diversification
# Run from the package root with: Rscript run.R 2

periods <- c("2012–2016", "2017–2019", "2020–2022", "2023–2025")
# Calculate each denominator from the confirmed primary publications in that period.
period_totals <- core_primary %>% filter(period_label %in% periods) %>%
  count(period_label) %>% { setNames(.$n, .$period_label) }
# Set the order of topic segments within each stacked bar.
f2_topic_order <- c(
  # These five topics occur in every period and therefore provide a stable,
  # visibly repeated base for all four bars.
  "Rural development",
  "Digital, virtual, and media",
  "Interdisciplinary/other",
  "Theory gateways and reviews",
  "Arts, identity, and education",
  "Public culture and community",
  "Tourism, heritage, and place",
  "Cultural consumption",
  "Urban renewal and design",
  "Creative industries and innovation",
  "Policy, governance, and measurement",
  "Sport and leisure"
)
# Fill absent topic/period combinations with zero and calculate period shares.
f2_data <- topic_period %>%
  mutate(topic_label = harmonize_topic(topic_label)) %>%
  filter(period_label %in% periods, topic_label %in% topic_order) %>%
  select(period_label, primary_topic, topic_label, works) %>%
  complete(period_label = periods, nesting(primary_topic, topic_label), fill = list(works = 0L)) %>%
  mutate(
    period_label = factor(period_label, levels = periods),
    topic_label = factor(topic_label, levels = f2_topic_order),
    period_total = unname(period_totals[as.character(period_label)]),
    share = works / period_total
  )

# Direct-label the final bar so readers can match topics to segments without a
# detached legend. Labels retain the stack order, while evenly spaced positions
# keep the small upper segments legible.
# Calculate the final bar’s segment centers and place its direct labels.
f2_labels <- f2_data %>%
  filter(period_label == "2023–2025") %>%
  arrange(topic_label) %>%
  mutate(
    segment_y = cumsum(share) - share / 2,
    # Align labels horizontally with their segment centers. Separate only the
    # tightly packed small segments near the top of the bar.
    label_y = case_when(
      as.character(topic_label) == "Theory gateways and reviews" ~ 0.350,
      as.character(topic_label) == "Arts, identity, and education" ~ 0.390,
      as.character(topic_label) == "Urban renewal and design" ~ 0.870,
      as.character(topic_label) == "Creative industries and innovation" ~ 0.908,
      as.character(topic_label) == "Policy, governance, and measurement" ~ 0.944,
      as.character(topic_label) == "Sport and leisure" ~ 0.982,
      TRUE ~ segment_y
    ),
    label = as.character(topic_label)
  )

# Draw four stacked bars and connect final-period segments to their labels.
p2 <- ggplot(f2_data, aes(period_label, share, fill = topic_label)) +
  geom_col(position = position_stack(reverse = TRUE), width = 0.72, color = "white", linewidth = 0.25) +
  geom_segment(
    data = f2_labels,
    aes(x = 4.36, xend = 4.58, y = segment_y, yend = label_y),
    inherit.aes = FALSE, linewidth = 0.45, color = "#9CA3AF"
  ) +
  geom_point(
    data = f2_labels,
    aes(x = 4.58, y = label_y, fill = topic_label),
    inherit.aes = FALSE, shape = 22, size = 3.1, color = "white", stroke = 0.4
  ) +
  geom_text(
    data = f2_labels,
    aes(x = 4.65, y = label_y, label = label),
    inherit.aes = FALSE, hjust = 0, size = 3.0, color = "#17212B"
  ) +
  scale_x_discrete(labels = c(
    "2012–2016" = "2012–2016\n(n = 15)",
    "2017–2019" = "2017–2019\n(n = 39)",
    "2020–2022" = "2020–2022\n(n = 128)",
    "2023–2025" = "2023–2025\n(n = 259)"
  ), expand = expansion(add = c(0.22, 2.20))) +
  scale_y_continuous(labels = percent_format(accuracy = 1), breaks = seq(0, 1, 0.25),
                     expand = expansion(mult = c(0, 0))) +
  scale_fill_manual(values = topic_colors, breaks = f2_topic_order, drop = FALSE, name = NULL) +
  coord_cartesian(ylim = c(0, 1), clip = "off") +
  labs(
    title = "Chinese scenes research spread across a widening range of topics",
    x = NULL, y = "Share of Scenes publications"
  ) +
  theme_intro(10.2) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(lineheight = 0.95),
    panel.grid.major = element_blank(),
    plot.title = element_text(
      face = "bold", size = 14, color = "#111827",
      margin = margin(b = 22)
    ),
    plot.margin = margin(10, 20, 10, 12)
  )

p2 <- add_figure_caption(
  p2,
  "Bars show the primary topics of Scenes publications, based on classifying their titles. The largest topic accounted for 27%, 26%, 18%, and 19% of publications across the four periods.",
  wrap_width = 118
)

# Save the figure and the tables used to construct it.
save_figure(p2, "figure_02_topic_diversification", 8.0, 6.55)
write_csv(f2_data %>% mutate(across(where(is.factor), as.character)),
          file.path(table_dir, "figure_02_topic_composition.csv"), na = "")
