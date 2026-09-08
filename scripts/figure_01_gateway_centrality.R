# Figure 1: gateway centrality
# Run from the package root with: Rscript run.R 1

# Keep confirmed publications and attach the topic groups and display labels.
f1_nodes <- cocitation_nodes %>%
  filter(tier_label == "Confirmed Scenes") %>%
  mutate(
    topic_label = harmonize_topic(topic_label),
    topic_group = case_when(
      topic_label %in% c("Theory gateways and reviews", "Policy, governance, and measurement") ~ "Theory and policy",
      topic_label %in% c("Public culture and community", "Rural development") ~ "Public and rural culture",
      topic_label %in% c("Tourism, heritage, and place", "Urban renewal and design") ~ "Tourism, heritage, and design",
      topic_label %in% c("Creative industries and innovation", "Cultural consumption") ~ "Creative industries and consumption",
      topic_label == "Digital, virtual, and media" ~ "Digital and media",
      TRUE ~ "Other"
    ),
    label = case_when(
      target_work_id == "WORK-0B7C450D6ADC" ~ "Xu Xiaolin, Zhao Tie & Clark 2012",
      target_work_id == "WORK-3DD575407739" ~ "Wu Jun, Xia Jianzhong & Clark 2013",
      target_work_id == "WORK-11BA0618FDA2" ~ "Wu Jun 2014",
      target_work_id == "WORK-80AC7412450E" ~ "Fu Caiwu & Hou Xueyan 2016",
      target_work_id == "WORK-258AF028DD78" ~ "Chen Bo & Hou Xueyan 2017",
      target_work_id == "WORK-EECC280B6161" ~ "Wen & Dai 2021",
      target_work_id == "WORK-7647EECE73A6" ~ "Chen & Yan 2022",
      TRUE ~ ""
    ),
    gateway = target_work_id %in% c("WORK-0B7C450D6ADC", "WORK-3DD575407739", "WORK-11BA0618FDA2"),
    topic_label = factor(topic_label, levels = topic_order),
    topic_group = factor(topic_group, levels = c(
      "Theory and policy", "Public and rural culture", "Tourism, heritage, and design",
      "Creative industries and consumption", "Digital and media", "Other"
    ))
  )

topic_group_colors <- c(
  "Theory and policy" = navy,
  "Public and rural culture" = teal,
  "Tourism, heritage, and design" = orange,
  "Creative industries and consumption" = gold,
  "Digital and media" = blue,
  "Other" = slate
)

# Keep only links whose two endpoints are in the displayed confirmed set.
confirmed_ids <- f1_nodes$target_work_id
f1_edges <- cocitation_edges %>% filter(a %in% confirmed_ids, b %in% confirmed_ids)
# Build an undirected graph from the selected nodes and weighted links.
g1 <- graph_from_data_frame(
  f1_edges %>% transmute(from = a, to = b, weight = shared_citing_sources),
  directed = FALSE,
  vertices = f1_nodes %>% rename(name = target_work_id)
)
# Calculate node positions, using the square root of each link weight.
layout1 <- layout_with_fr(g1, weights = sqrt(E(g1)$weight), niter = 2500, grid = "nogrid")
layout1 <- norm_coords(layout1, xmin = -1, xmax = 1, ymin = -1, ymax = 1)
# Join graph coordinates to the node data and position the seven text labels.
f1_nodes_plot <- tibble(
  target_work_id = V(g1)$name,
  x = layout1[, 1], y = layout1[, 2]
) %>%
  left_join(f1_nodes, by = "target_work_id") %>%
  mutate(
    label_text = case_when(
      target_work_id == "WORK-0B7C450D6ADC" ~ "Xu Xiaolin, Zhao Tie &\nClark 2012",
      target_work_id == "WORK-3DD575407739" ~ "Wu Jun, Xia Jianzhong &\nClark 2013",
      target_work_id == "WORK-11BA0618FDA2" ~ "Wu Jun 2014",
      target_work_id == "WORK-80AC7412450E" ~ "Fu Caiwu & Hou Xueyan\n2016",
      target_work_id == "WORK-258AF028DD78" ~ "Chen Bo & Hou Xueyan\n2017",
      target_work_id == "WORK-EECC280B6161" ~ "Wen & Dai 2021",
      target_work_id == "WORK-7647EECE73A6" ~ "Chen & Yan 2022",
      TRUE ~ ""
    ),
    label_x = case_when(
      target_work_id %in% c("WORK-0B7C450D6ADC", "WORK-EECC280B6161", "WORK-7647EECE73A6") ~ -1.32,
      target_work_id %in% c("WORK-3DD575407739", "WORK-11BA0618FDA2", "WORK-80AC7412450E", "WORK-258AF028DD78") ~ 1.32,
      TRUE ~ NA_real_
    ),
    label_y = case_when(
      target_work_id == "WORK-0B7C450D6ADC" ~ 0.70,
      target_work_id == "WORK-3DD575407739" ~ 0.70,
      target_work_id == "WORK-11BA0618FDA2" ~ -0.63,
      target_work_id == "WORK-80AC7412450E" ~ -0.27,
      target_work_id == "WORK-258AF028DD78" ~ 0.27,
      target_work_id == "WORK-EECC280B6161" ~ 0.12,
      target_work_id == "WORK-7647EECE73A6" ~ -0.61,
      TRUE ~ NA_real_
    ),
    label_hjust = case_when(
      label_x > 0 ~ 1,
      label_x < 0 ~ 0,
      TRUE ~ 0.5
    ),
    line_xend = case_when(
      target_work_id == "WORK-0B7C450D6ADC" ~ -0.70,
      target_work_id == "WORK-3DD575407739" ~ 0.70,
      target_work_id == "WORK-11BA0618FDA2" ~ 1.00,
      target_work_id %in% c("WORK-80AC7412450E", "WORK-258AF028DD78") ~ 0.70,
      target_work_id == "WORK-EECC280B6161" ~ -0.90,
      target_work_id == "WORK-7647EECE73A6" ~ -0.88,
      TRUE ~ NA_real_
    )
  )
# Attach the coordinates of both endpoints to every link.
f1_edges_plot <- as_data_frame(g1, what = "edges") %>%
  left_join(f1_nodes_plot %>% select(from = target_work_id, x_from = x, y_from = y), by = "from") %>%
  left_join(f1_nodes_plot %>% select(to = target_work_id, x_to = x, y_to = y), by = "to")

# Draw the links, nodes, gateway outlines, labels, and legends.
p1 <- ggplot() +
  geom_segment(
    data = f1_edges_plot,
    aes(x_from, y_from, xend = x_to, yend = y_to, linewidth = weight),
    color = "#9CA3AF", alpha = 0.38, lineend = "round"
  ) +
  geom_point(
    data = f1_nodes_plot,
    aes(x, y, size = pmax(wanfang_count, 1), fill = topic_group),
    shape = 21, color = "white", stroke = 0.55, alpha = 0.98
  ) +
  geom_point(
    data = f1_nodes_plot %>% filter(gateway),
    aes(x, y, size = pmax(wanfang_count, 1)),
    shape = 21, fill = NA, color = "#17212B", stroke = 1.65
  ) +
  geom_segment(
    data = f1_nodes_plot %>% filter(label != ""),
    aes(x, y, xend = line_xend, yend = label_y),
    color = "#68737D", linewidth = 0.52, lineend = "round"
  ) +
  geom_label(
    data = f1_nodes_plot %>% filter(label != "", !gateway),
    aes(label_x, label_y, label = label_text, hjust = label_hjust),
    size = 3.25, lineheight = 0.95, linewidth = 0, color = "#374151",
    fill = NA, label.padding = unit(0.10, "lines")
  ) +
  geom_label(
    data = f1_nodes_plot %>% filter(label != "", gateway),
    aes(label_x, label_y, label = label_text, hjust = label_hjust),
    size = 3.55, fontface = "bold", lineheight = 0.95, linewidth = 0,
    color = "#111827",
    fill = NA, label.padding = unit(0.10, "lines")
  ) +
  scale_linewidth(range = c(0.25, 2.8), trans = "sqrt", guide = "none") +
  scale_size_area(max_size = 10.5, breaks = c(50, 150, 300), name = "Citations (Wanfang)") +
  scale_fill_manual(values = topic_group_colors, drop = TRUE, name = "Broad topic family") +
  guides(
    fill = guide_legend(order = 1, nrow = 2, byrow = TRUE,
                        title.position = "top", title.hjust = 0.5,
                        override.aes = list(shape = 21, size = 4.2, color = "white")),
    size = guide_legend(order = 2, direction = "horizontal",
                        title.position = "top", title.hjust = 0.5,
                        override.aes = list(
                          shape = 21, fill = "#667985", color = "white",
                          size = c(2.8, 4.8, 6.8)
                        ))
  ) +
  coord_equal(xlim = c(-1.42, 1.42), ylim = c(-1.08, 1.08), clip = "off") +
  labs(title = str_wrap("Gateway papers are central nodes in the expanding field of Chinese scenes research", 54),
       x = NULL, y = NULL) +
  theme_void(base_size = 10.5, base_family = "Helvetica") +
  theme(
    plot.title.position = "plot",
    plot.title = element_text(face = "bold", size = 14, color = "#111827", margin = margin(b = 8)),
    legend.position = "bottom", legend.box = "vertical",
    legend.box.just = "center",
    legend.title = element_text(face = "bold", size = 9),
    legend.text = element_text(size = 8.1),
    legend.spacing.x = unit(0.18, "cm"),
    plot.margin = margin(12, 18, 8, 18)
  )

p1 <- add_figure_caption(
  p1,
  "Lines connect articles that were cited together by later publications. Line width shows the number of shared citing publications; color shows articles' topics; node size indicates citation volume on Wanfang, a large database of Chinese-language research literature.",
  wrap_width = 118
)

# Save the figure and the tables used to construct it.
save_figure(p1, "figure_01_gateway_centrality", 8.0, 7.15)
write_csv(f1_nodes %>% mutate(across(where(is.factor), as.character)),
          file.path(table_dir, "figure_01_gateway_nodes_confirmed.csv"), na = "")
write_csv(f1_edges, file.path(table_dir, "figure_01_gateway_edges_confirmed.csv"), na = "")
