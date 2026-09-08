# Figure 3: disciplinary spread
# Run from the package root with: Rscript run.R 3

# Prepare publishing-field counts and add zero rows for unused field codes.
f3a <- publication_fields %>%
  transmute(
    field_code = venue_field_complete,
    field = unname(field_labels[field_code]),
    count = works,
    share = share_of_confirmed_primary
  ) %>%
  complete(field_code = names(field_labels), fill = list(count = 0, share = 0)) %>%
  mutate(
    field = coalesce(field, unname(field_labels[field_code])),
    field = factor(field, levels = rev(field_order))
  )

# Prepare citing-field counts and add zero rows for unused field codes.
f3b <- citing_fields %>%
  transmute(
    field_code = harmonized_field,
    field = unname(field_labels[field_code]),
    count = unique_citing_sources,
    share = share
  ) %>%
  complete(field_code = names(field_labels), fill = list(count = 0, share = 0)) %>%
  mutate(
    field = coalesce(field, unname(field_labels[field_code])),
    field = factor(field, levels = rev(field_order))
  )

# Draw publishing-field bars with count and percentage labels.
p3a <- ggplot(f3a, aes(count, field)) +
  geom_col(fill = teal, width = 0.66) +
  geom_text(aes(label = paste0(count, " (", percent(share, accuracy = 1), ")")),
            hjust = -0.08, size = 2.85, color = "#374151") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.30))) +
  labs(title = "A. Where Scenes research was published", x = "Scenes Publications", y = NULL) +
  theme_panel(9.2) +
  theme(panel.grid.major.y = element_blank(), axis.text.y = element_text(size = 8.0))

# Draw citing-field bars using the same field order as the left panel.
p3b <- ggplot(f3b, aes(count, field)) +
  geom_col(fill = blue, width = 0.66) +
  geom_text(aes(label = paste0(comma(count), " (", percent(share, accuracy = 1), ")")),
            hjust = -0.08, size = 2.85, color = "#374151") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.28))) +
  labs(title = "B. Where Scenes research was cited", x = "Unique citing publications", y = NULL) +
  theme_panel(9.2) +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text.y = element_blank(), axis.ticks.y = element_blank()
  )

# Place the two panels side by side and add the shared title and caption.
p3 <- p3a + p3b + plot_layout(widths = c(1.13, 1)) +
  plot_annotation(
    title = "Chinese scenes research crosses disciplinary boundaries",
    caption = str_wrap(
      "Panel A shows the disciplinary fields of the venues in which 488 Scenes publications appeared. Panel B shows the fields of publications that cited Scenes publications.",
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
save_figure(p3, "figure_03_disciplinary_spread", 10.2, 6.38)
write_csv(f3a %>% mutate(field = as.character(field)),
          file.path(table_dir, "figure_03a_publication_fields.csv"), na = "")
write_csv(f3b %>% mutate(field = as.character(field)),
          file.path(table_dir, "figure_03b_citing_fields.csv"), na = "")
