# Shared colors, labels, and functions used by the eight figure scripts.

navy <- "#264653"
teal <- "#2A9D8F"
blue <- "#4C78A8"
orange <- "#D97732"
gold <- "#C59B2A"
slate <- "#6B7280"
light_blue <- "#AEC7E8"
light_teal <- "#A8D5C6"
light_orange <- "#F2B880"
light_gold <- "#E6D18A"
rose <- "#B46A7A"
purple <- "#7B6FA6"

topic_colors <- c(
  "Public culture and community" = teal,
  "Rural development" = "#7AA65A",
  "Tourism, heritage, and place" = orange,
  "Digital, virtual, and media" = blue,
  "Cultural consumption" = gold,
  "Urban renewal and design" = "#52A7A0",
  "Interdisciplinary/other" = "#9AA0A6",
  "Creative industries and innovation" = "#D99A5B",
  "Policy, governance, and measurement" = navy,
  "Theory gateways and reviews" = purple,
  "Arts, identity, and education" = rose,
  "Sport and leisure" = "#8CB3C7",
  "Residential and housing" = "#B7A99A"
)

topic_order <- names(topic_colors)[1:12]

field_labels <- c(
  INTERDISC_OTHER = "Interdisciplinary/other",
  ARCH_DES_HER = "Architecture, design, and heritage",
  CULT_MEDIA = "Culture, arts, and media",
  URBAN_PLAN_GEO = "Urban planning and geography",
  INFO_TECH = "Information and library studies",
  SOC_POLICY = "Social science and policy",
  ECON_BUS_CONS = "Economics, business, and consumption",
  SPORT_LEISURE = "Sport and leisure",
  EDUCATION = "Education",
  TOUR_HOSP = "Tourism and hospitality",
  RURAL_AGRI = "Rural and agricultural studies",
  MATH_SYSTEMS = "Mathematics and systems science"
)

field_order <- unname(field_labels)

# Set the fonts, grid lines, margins, and legend styles for a complete figure.
theme_intro <- function(base_size = 10.5) {
  theme_minimal(base_size = base_size, base_family = "Helvetica") +
    theme(
      plot.title.position = "plot",
      plot.title = element_text(face = "bold", size = 14, color = "#111827", margin = margin(b = 10)),
      axis.title = element_text(color = "#374151"),
      axis.text = element_text(color = "#374151"),
      panel.grid.major = element_line(color = "#E5E7EB", linewidth = 0.35),
      panel.grid.minor = element_blank(),
      legend.title = element_text(face = "bold"),
      legend.text = element_text(size = 8.5),
      plot.margin = margin(10, 16, 10, 12)
    )
}

# Use smaller headings when two panels share one figure.
theme_panel <- function(base_size = 9.5) {
  theme_intro(base_size) +
    theme(plot.title = element_text(face = "bold", size = 10.8, margin = margin(b = 8)))
}

# Write the same plot as a 360-dpi PNG and as a scalable SVG.
save_figure <- function(plot, stem, width, height) {
  ggsave(file.path(figure_dir, paste0(stem, ".png")), plot,
         width = width, height = height, units = "in", dpi = 360,
         bg = "white", limitsize = FALSE)
  ggsave(file.path(figure_dir, paste0(stem, ".svg")), plot,
         width = width, height = height, units = "in", device = svglite::svglite,
         bg = "white", limitsize = FALSE)
}

# Wrap the caption text and add space above it.
add_figure_caption <- function(plot, caption, wrap_width = 125) {
  plot +
    labs(caption = str_wrap(caption, width = wrap_width)) +
    theme(
      plot.caption.position = "plot",
      plot.caption = element_text(
        hjust = 0, size = 7.6, lineheight = 1.18,
        color = "#374151", margin = margin(t = 9)
      )
    )
}

# Convert three stored topic labels to the spellings used in the figures.
harmonize_topic <- function(x) {
  recode(
    x,
    "Tourism, heritage, place" = "Tourism, heritage, and place",
    "Policy, governance, measurement" = "Policy, governance, and measurement",
    "Arts, identity, education" = "Arts, identity, and education",
    .default = x
  )
}


# Keep period order shared by Figures 2 and 6, including individual-figure runs.
periods <- c("2012–2016", "2017–2019", "2020–2022", "2023–2025")
