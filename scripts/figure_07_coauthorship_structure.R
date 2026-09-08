# Figure 7: coauthorship structure
# Run from the package root with: Rscript run.R 7

# Select the confirmed scholarly works used to count author publications.
core_ids <- master %>% filter(scenes_core_member) %>% pull(target_work_id)
# Count distinct confirmed works for each normalized author name.
author_stats <- authors %>%
  filter(target_work_id %in% core_ids, !is.na(author_normalized), author_normalized != "") %>%
  group_by(author = author_normalized) %>%
  summarise(confirmed_works = n_distinct(target_work_id), .groups = "drop")

# Collect author names that occur in at least one coauthor pair.
collaborative_names <- unique(c(coauthor_pairs$author_1, coauthor_pairs$author_2))
# Keep collaborative authors and attach labels to five selected names.
f7_nodes <- author_stats %>%
  filter(author %in% collaborative_names) %>%
  mutate(
    label = recode(
      author,
      "陈波" = "Chen Bo",
      "吴军" = "Wu Jun",
      "特里N克拉克" = "Terry Clark",
      "齐骥" = "Qi Ji",
      "傅才武" = "Fu Caiwu",
      .default = ""
    )
  )

# Build the undirected coauthorship graph with shared-work counts as weights.
g7_all <- graph_from_data_frame(
  coauthor_pairs %>% transmute(from = author_1, to = author_2, weight = shared_works),
  directed = FALSE,
  vertices = f7_nodes %>% rename(name = author)
)
# Keep collaborative authors and attach labels to five selected names.
f7_nodes <- f7_nodes %>% mutate(shown_in_network = TRUE)
# Calculate separate component layouts before placing them in one graph.
layout7 <- layout_components(g7_all, layout = layout_with_fr, niter = 900, grid = "nogrid")
# Tighten spacing within each component and retain its x/y coordinates.
layout7 <- tibble(
  x = layout7[, 1], y = layout7[, 2],
  collaboration_group = components(g7_all)$membership
) %>%
  group_by(collaboration_group) %>%
  mutate(
    group_size = n(),
    spacing_factor = case_when(group_size >= 10 ~ 0.92, group_size >= 6 ~ 0.84, TRUE ~ 0.72),
    x = mean(x) + (x - mean(x)) * spacing_factor,
    y = mean(y) + (y - mean(y)) * spacing_factor
  ) %>%
  ungroup() %>%
  select(x, y) %>%
  as.matrix()
layout7 <- norm_coords(layout7, xmin = -1, xmax = 1, ymin = -1, ymax = 1)
# Attach graph coordinates to each author record.
f7_nodes_plot <- tibble(author = V(g7_all)$name, x = layout7[, 1], y = layout7[, 2]) %>%
  left_join(f7_nodes, by = "author")
# Attach the two author coordinates to each coauthorship link.
f7_edges_plot <- as_data_frame(g7_all, what = "edges") %>%
  left_join(f7_nodes_plot %>% select(from = author, x_from = x, y_from = y), by = "from") %>%
  left_join(f7_nodes_plot %>% select(to = author, x_to = x, y_to = y), by = "to")

# Count authors in each connected component and rank component sizes.
f7_component_sizes <- tibble(component = seq_along(components(g7_all)$csize), size = components(g7_all)$csize) %>%
  arrange(desc(size)) %>% mutate(rank = row_number())
stopifnot(nrow(f7_component_sizes) == 260L, max(f7_component_sizes$size) == 27L)
f7_component_distribution <- f7_component_sizes %>% count(size, name = "components")

# Draw all collaborative authors and links and label selected authors.
p7a <- ggplot() +
  geom_segment(
    data = f7_edges_plot,
    aes(x_from, y_from, xend = x_to, yend = y_to, linewidth = weight),
    color = "#7E8B95", alpha = 0.92, lineend = "round"
  ) +
  geom_point(
    data = f7_nodes_plot,
    aes(x, y, size = confirmed_works),
    shape = 21, fill = teal, color = "white", stroke = 0.25, alpha = 0.94
  ) +
  geom_text_repel(
    data = f7_nodes_plot %>% filter(label != ""),
    aes(x, y, label = label),
    size = 3.0, fontface = "bold", min.segment.length = 0,
    segment.color = "#6B7280", box.padding = 0.48, point.padding = 0.38,
    force = 2.8, seed = 20260904, max.overlaps = Inf
  ) +
  annotate(
    "text", x = -1.0, y = -1.09, hjust = 0,
    label = "656 coauthor pairs; only 16 pairs published together more than once",
    size = 2.9, fontface = "bold", color = "#374151"
  ) +
  scale_linewidth(range = c(0.40, 1.55), breaks = c(1, 2, 3), guide = "none") +
  scale_size_area(max_size = 8.0, guide = "none") +
  coord_equal(xlim = c(-1.04, 1.04), ylim = c(-1.12, 1.04), clip = "off") +
  labs(title = "A. Coauthorship network", x = NULL, y = NULL) +
  theme_void(base_size = 9.5, base_family = "Helvetica") +
  theme(
    plot.title = element_text(face = "bold", size = 10.8, color = "#111827",
                              hjust = 0, margin = margin(b = 7)),
    legend.position = "none",
    plot.margin = margin(6, 6, 10, 6)
  )

# Draw the number of connected components at each component size.
p7b <- ggplot(f7_component_distribution, aes(size, components)) +
  geom_col(fill = light_blue, color = navy, width = 0.72, linewidth = 0.45) +
  geom_text(
    aes(label = components), vjust = -0.45, size = 2.8,
    fontface = "bold", color = navy
  ) +
  annotate(
    "text", x = 8.1, y = 132, hjust = 0,
    label = "260 separate\ncollaboration groups",
    size = 2.85, fontface = "bold", color = "#374151", lineheight = 0.95
  ) +
  annotate(
    "text", x = 8.1, y = 99, hjust = 0,
    label = "Most contain only\n2–3 authors",
    size = 2.85, color = "#374151", lineheight = 0.95
  ) +
  annotate(
    "text", x = 27, y = 12, hjust = 1,
    label = "Largest group:\n27 authors",
    size = 2.75, color = "#374151", lineheight = 0.95
  ) +
  scale_x_continuous(
    breaks = c(2, 3, 4, 5, 6, 10, 20, 27),
    limits = c(1.3, 28.2)
  ) +
  scale_y_continuous(
    limits = c(0, 150),
    breaks = c(0, 50, 100, 150),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "B. Most collaboration groups are very small",
    x = "Authors in collaboration group", y = "Number of groups"
  ) +
  theme_panel(9.0) +
  theme(panel.grid.major.x = element_blank(), plot.margin = margin(6, 10, 10, 4))

# Combine the network and component-size panels.
p7 <- p7a + p7b + plot_layout(widths = c(7, 3)) +
  plot_annotation(
    title = "Chinese scenes research developed through many small collaboration groups",
    caption = str_wrap(
      "Each point is an author and each line connects two authors who published together. Authors belong to the same collaboration group when they are connected either directly or through shared coauthors; groups with no chain of coauthorship between them appear separately. Across the Chinese Scenes literature, the network contains 260 such groups, most with only two or three authors. Only 16 of 656 observed coauthor pairs published together on more than one work.",
      width = 160
    ),
    theme = theme(
      plot.title = element_text(family = "Helvetica", face = "bold", size = 14,
                                color = "#111827", margin = margin(b = 8)),
      plot.caption = element_text(family = "Helvetica", hjust = 0, size = 7.6,
                                  lineheight = 1.18, color = "#374151", margin = margin(t = 9))
    )
  )

# Save the figure and the tables used to construct it.
save_figure(p7, "figure_07_coauthorship_structure", 10.4, 7.0)
write_csv(f7_nodes, file.path(table_dir, "figure_07_coauthor_nodes.csv"), na = "")
write_csv(coauthor_pairs, file.path(table_dir, "figure_07_coauthor_pairs.csv"), na = "")
write_csv(f7_component_sizes, file.path(table_dir, "figure_07_component_sizes.csv"), na = "")
