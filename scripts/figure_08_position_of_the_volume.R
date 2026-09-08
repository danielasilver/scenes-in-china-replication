# Figure 8: position of the volume
# Run from the package root with: Rscript run.R 8

# Map stored chapter topic codes to the branch labels used on the axis.
chapter_branch_labels <- c(
  CULTURAL_CREATIVE_INNOVATION = "Creative development and talent",
  URBAN_RENEWAL_DESIGN = "Urban renewal and design",
  DIGITAL_VIRTUAL_MEDIA = "Digital and virtual scenes",
  PUBLIC_CULTURE_COMMUNITY = "Public culture and community",
  RURAL_DEVELOPMENT = "Rural development",
  TOURISM_HERITAGE_PLACE = "Tourism, heritage, and place",
  CULTURAL_CONSUMPTION_COMMERCIAL = "Cultural consumption",
  POLICY_GOVERNANCE_MEASUREMENT = "Policy, governance, and city-making",
  ART_IDENTITY_EDUCATION = "Arts, identity, and critique"
)

chapter_branch_order <- unname(chapter_branch_labels)
# Place chapters by source year and branch, offsetting chapters that overlap.
f8_data <- chapter_crosswalk %>%
  mutate(
    branch = unname(chapter_branch_labels[branch_topic]),
    branch = factor(branch, levels = rev(chapter_branch_order)),
    branch_y = as.numeric(branch),
    label = as.character(chapter_no)
  ) %>%
  group_by(source_year, branch) %>%
  arrange(chapter_no, .by_group = TRUE) %>%
  mutate(
    point_offset = if (n() == 1L) 0 else seq(-0.31, 0.31, length.out = n()),
    plot_y = branch_y + point_offset
  ) %>%
  ungroup()

f8_color_map <- c(
  "Creative development and talent" = topic_colors[["Creative industries and innovation"]],
  "Urban renewal and design" = topic_colors[["Urban renewal and design"]],
  "Digital and virtual scenes" = topic_colors[["Digital, virtual, and media"]],
  "Public culture and community" = topic_colors[["Public culture and community"]],
  "Rural development" = topic_colors[["Rural development"]],
  "Tourism, heritage, and place" = topic_colors[["Tourism, heritage, and place"]],
  "Cultural consumption" = topic_colors[["Cultural consumption"]],
  "Policy, governance, and city-making" = topic_colors[["Policy, governance, and measurement"]],
  "Arts, identity, and critique" = topic_colors[["Arts, identity, and education"]]
)

p8_caption <- paste(
  "Numbers in the circles identify chapters. Chapters are placed by the topic and",
  "publication year of the original publication."
)

# Draw chapter-number circles at the calculated year and branch positions.
p8 <- ggplot(f8_data, aes(source_year, plot_y)) +
  geom_point(shape = 21, size = 7.2, fill = navy, color = "white", stroke = 0.65) +
  geom_text(
    aes(label = label),
    color = "white", size = 2.65, fontface = "bold",
    family = "Helvetica"
  ) +
  scale_x_continuous(breaks = 2016:2025, limits = c(2015.5, 2025.5),
                     expand = expansion(mult = c(0, 0))) +
  scale_y_continuous(
    breaks = seq_along(chapter_branch_order),
    labels = rev(chapter_branch_order),
    limits = c(0.5, 9.55)
  ) +
  labs(
    title = "The volume spans nine branches and a decade of Chinese scenes research",
    x = "Year of source article", y = NULL,
    caption = str_wrap(p8_caption, 135)
  ) +
  theme_intro(10.0) +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line.x = element_line(color = "#9CA3AF", linewidth = 0.35),
    axis.ticks.x = element_line(color = "#9CA3AF", linewidth = 0.35),
    axis.ticks.length.x = unit(3, "pt"),
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    axis.text.y = element_text(size = 9.0),
    axis.title.x = element_text(margin = margin(t = 7)),
    plot.caption.position = "plot",
    plot.caption = element_text(
      hjust = 0, size = 7.6, lineheight = 1.18,
      color = "#374151", margin = margin(t = 10)
    ),
    plot.margin = margin(10, 18, 10, 12)
  )

# Save the figure and the tables used to construct it.
save_figure(p8, "figure_08_position_of_the_volume", 9.2, 5.8)
write_csv(f8_data %>% mutate(branch = as.character(branch)),
          file.path(table_dir, "figure_08_chapter_positions.csv"), na = "")
