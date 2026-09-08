# Read the cleaned tables and calculate the summaries used by the figure scripts.
# This script uses stored classifications; it does not classify titles or clean names.

# Read UTF-8 CSVs. Blank cells and the explicit string NA are treated as missing.
read_data <- function(name) {
  read_csv(file.path(root, "data", name), show_col_types = FALSE,
           locale = locale(encoding = "UTF-8"))
}
master <- read_data("publications.csv")
authors <- read_data("authorships.csv")
citing <- read_data("citing_publications.csv")
edges <- read_data("citation_relations.csv")
counts <- read_data("citation_counts.csv")
chapter_crosswalk <- read_data("chapter_sources.csv")

# Stop if identifiers repeat or a link refers to an absent publication.
stopifnot(
  nrow(master) == 1126L, !anyDuplicated(master$target_work_id),
  nrow(citing) == 8186L, !anyDuplicated(citing$citing_source_id),
  nrow(edges) == 14294L,
  !anyDuplicated(edges[c("citing_source_id", "target_work_id")]),
  all(edges$target_work_id %in% master$target_work_id),
  all(edges$citing_source_id %in% citing$citing_source_id),
  all(authors$target_work_id %in% master$target_work_id),
  !anyDuplicated(authors[c("target_work_id", "author_normalized")]),
  !anyDuplicated(counts[c("target_work_id", "database")]),
  all(counts$target_work_id %in% master$target_work_id),
  all(counts$displayed_citation_count >= 0),
  all(counts$displayed_citation_count == floor(counts$displayed_citation_count)),
  nrow(chapter_crosswalk) == 17L,
  identical(sort(chapter_crosswalk$chapter_no), as.double(2:18))
)

# Match stored topic, membership, and period codes to readable labels.
topic_codes <- c(
  ART_IDENTITY_EDUCATION = "Arts, identity, education",
  CULTURAL_CONSUMPTION_COMMERCIAL = "Cultural consumption",
  CULTURAL_CREATIVE_INNOVATION = "Creative industries and innovation",
  DIGITAL_VIRTUAL_MEDIA = "Digital, virtual, and media",
  INTERDISC_OTHER = "Interdisciplinary/other",
  POLICY_GOVERNANCE_MEASUREMENT = "Policy, governance, measurement",
  PUBLIC_CULTURE_COMMUNITY = "Public culture and community",
  RESIDENTIAL_HOUSING = "Residential and housing",
  RURAL_DEVELOPMENT = "Rural development",
  SPORT_LEISURE = "Sport and leisure",
  THEORY_GATEWAY = "Theory gateways and reviews",
  TOURISM_HERITAGE_PLACE = "Tourism, heritage, place",
  URBAN_RENEWAL_DESIGN = "Urban renewal and design"
)
tier_codes <- c(confirmed_scenes = "Confirmed Scenes", probable_scenes = "Probable Scenes",
                adjacent_convergent = "Adjacent/convergent")
period_codes <- c(
  "1994–2011: antecedents", "2012–2016: gateway formation",
  "2017–2019: domestic relay", "2020–2022: rapid application",
  "2023–2025: expansion and convergence", "2026: incomplete"
)
period_short <- c("1994–2011", "2012–2016", "2017–2019", "2020–2022", "2023–2025", "2026*")
master <- master %>%
  mutate(topic_label = unname(topic_codes[primary_topic]),
         tier_label = unname(tier_codes[scenes_membership_tier]),
         period = factor(period, levels = period_codes, ordered = TRUE),
         period_label = period_short[as.integer(period)]) %>%
  left_join(counts %>% filter(database == "Wanfang") %>%
              select(target_work_id, wanfang_count = displayed_citation_count),
            by = "target_work_id")

# Form the confirmed scholarly subset and its journal/collection-article subset.
core <- master %>% filter(scenes_core_member)
core_primary <- core %>% filter(primary_periodical)
stopifnot(nrow(core) == 584L, nrow(core_primary) == 488L,
          sum(master$primary_periodical) == 1030L,
          all(master$scenes_core_member == (master$scenes_membership_tier == "confirmed_scenes")),
          !anyNA(master$topic_label), !anyNA(master$period),
          !anyNA(core_primary$venue_field_complete))

# Join each unique citation link to its target membership and citing publication.
# The link table already has one row per citing-publication/target pair.
edge_meta <- edges %>%
  select(citing_source_id, target_work_id) %>%
  inner_join(master %>% select(target_work_id, target_tier = scenes_membership_tier),
             by = "target_work_id") %>%
  left_join(citing %>% select(citing_source_id, citing_year = year,
                             harmonized_field, field_confidence), by = "citing_source_id")
stopifnot(nrow(edge_meta) == nrow(edges))

# Count publications for every year/population combination, adding zero years.
# For each year through 2025, average that year and the previous two years.
annual_growth <- tibble(year = 1994:2026) %>%
  left_join(master %>% filter(primary_periodical) %>%
              mutate(population = case_when(
                scenes_core_member ~ "Confirmed Scenes",
                scenes_membership_tier == "probable_scenes" ~ "Probable extension",
                TRUE ~ "Adjacent/convergent")) %>%
              count(year, population, name = "works") %>%
              complete(year = 1994:2026, population, fill = list(works = 0L)), by = "year") %>%
  group_by(population) %>% arrange(year, .by_group = TRUE) %>%
  mutate(rolling_3yr = vapply(seq_along(works), function(i) {
    if (year[i] > 2025) return(NA_real_)
    mean(works[max(1, i - 2):i])
  }, numeric(1))) %>% ungroup()

# Count primary topics within each period and divide by the period's total.
topic_period <- core_primary %>%
  count(period, period_label, primary_topic, topic_label, name = "works") %>%
  group_by(period) %>% mutate(period_total = sum(works), share = works / period_total) %>%
  ungroup()

# Average each stored 0/1 marker within a period to obtain its publication share.
# Put the three marker columns into a long table, with one row per period/marker.
engineering_period <- core_primary %>% group_by(period, period_label) %>%
  summarise(works = n(), Policy = mean(policy_marker == 1),
            Design = mean(design_marker == 1), Measurement = mean(measurement_marker == 1),
            .groups = "drop") %>%
  pivot_longer(c(Policy, Design, Measurement), names_to = "marker", values_to = "share")

# Count confirmed primary publications by their stored publishing-venue field.
publication_fields <- core_primary %>% count(venue_field_complete, name = "works") %>%
  mutate(share_of_confirmed_primary = works / sum(works)) %>% arrange(desc(works))

# Select sources citing at least one confirmed target, then count each source once.
core_citers <- edge_meta %>% filter(target_tier == "confirmed_scenes") %>%
  distinct(citing_source_id, harmonized_field, field_confidence)
citing_fields <- core_citers %>% count(harmonized_field, name = "unique_citing_sources", sort = TRUE) %>%
  mutate(share = unique_citing_sources / sum(unique_citing_sources))
stopifnot(nrow(core_citers) == 4509L,
          sum(core_citers$field_confidence %in% c("T1", "T2")) == 1682L)

# Attach the six selected citation-history labels to publication metadata.
cases <- read_csv(file.path(root, "config/citation_history_cases.csv"), show_col_types = FALSE)
selected_targets <- cases %>% left_join(
  master %>% select(target_work_id, target_title = title, target_year = year, wanfang_count),
  by = "target_work_id") %>%
  select(target_work_id, target_title, target_year, wanfang_count, case_order, case_label)

# Create a row for every year from a target's publication through 2026. Count
# dated citing publications, replace absent yearly counts with zero, and accumulate.
citation_histories <- tidyr::crossing(selected_targets, citing_year = 2011:2026) %>%
  filter(citing_year >= target_year) %>%
  left_join(edge_meta %>% filter(target_work_id %in% selected_targets$target_work_id,
                                !is.na(citing_year), citing_year <= 2026) %>%
              count(target_work_id, citing_year, name = "new_citing_sources"),
            by = c("target_work_id", "citing_year")) %>%
  mutate(new_citing_sources = replace_na(new_citing_sources, 0L)) %>%
  arrange(case_order, citing_year) %>% group_by(target_work_id) %>%
  mutate(cumulative_citing_sources = cumsum(new_citing_sources),
         years_since_publication = citing_year - target_year) %>% ungroup()

# For each citing publication, count distinct targets and record whether its
# targets include both a confirmed publication and an adjacent publication.
source_tiers <- edge_meta %>% group_by(citing_source_id) %>%
  summarise(targets_cited = n_distinct(target_work_id),
            cites_core = any(target_tier == "confirmed_scenes"),
            cites_adjacent = any(target_tier == "adjacent_convergent"), .groups = "drop") %>%
  left_join(citing %>% select(citing_source_id, citing_year = year), by = "citing_source_id") %>%
  mutate(core_adjacent_bridge = cites_core & cites_adjacent)

# Count bridges and all multi-target citing publications by year. Divide bridge
# counts by the multi-target count to obtain the percentages printed in Figure 5.
bridge_years <- source_tiers %>% filter(!is.na(citing_year), citing_year <= 2026) %>%
  group_by(citing_year) %>% summarise(
    all_sources = n(), multi_target_sources = sum(targets_cited >= 2),
    bridge_sources = sum(core_adjacent_bridge),
    bridge_share_all = bridge_sources / all_sources,
    bridge_share_multi_target = bridge_sources / multi_target_sources, .groups = "drop")

# Enumerate every unordered pair of targets cited by the same source. Count how
# many sources cite each pair, then keep pairs sharing at least two sources.
edge_targets <- edge_meta %>% distinct(citing_source_id, target_work_id)
cocit <- edge_targets %>%
  inner_join(edge_targets, by = "citing_source_id", suffix = c("_a", "_b"), relationship = "many-to-many") %>%
  filter(target_work_id_a < target_work_id_b) %>%
  count(target_work_id_a, target_work_id_b, name = "shared_citing_sources") %>%
  filter(shared_citing_sources >= 2)

# Build the full thresholded graph. Calculate each node's degree (number of
# neighbors) and strength (sum of link weights), then join publication metadata.
g_cocit_all <- graph_from_data_frame(
  cocit %>% transmute(from = target_work_id_a, to = target_work_id_b, weight = shared_citing_sources),
  directed = FALSE, vertices = master %>%
    filter(target_work_id %in% unique(c(cocit$target_work_id_a, cocit$target_work_id_b))) %>%
    transmute(name = target_work_id, title, authors, year, topic_label, tier_label, wanfang_count))
cocit_node_metrics <- tibble(target_work_id = V(g_cocit_all)$name,
                             cocitation_strength = strength(g_cocit_all, weights = E(g_cocit_all)$weight),
                             cocitation_degree = degree(g_cocit_all)) %>%
  left_join(master %>% select(target_work_id, title, authors, year, topic_label, tier_label, wanfang_count),
            by = "target_work_id")

# Select the 48 strongest confirmed/probable nodes. Keep their 85 strongest
# internal links, plus each selected node's two strongest internal links.
selected <- cocit_node_metrics %>% filter(tier_label %in% c("Confirmed Scenes", "Probable Scenes")) %>%
  slice_max(cocitation_strength, n = 48, with_ties = FALSE) %>% pull(target_work_id)
incident <- bind_rows(
  cocit %>% transmute(node = target_work_id_a, partner = target_work_id_b, shared_citing_sources),
  cocit %>% transmute(node = target_work_id_b, partner = target_work_id_a, shared_citing_sources)) %>%
  filter(node %in% selected, partner %in% selected) %>% group_by(node) %>%
  slice_max(shared_citing_sources, n = 2, with_ties = FALSE) %>% ungroup() %>%
  transmute(a = pmin(node, partner), b = pmax(node, partner), shared_citing_sources)
cocitation_edges <- bind_rows(
  cocit %>% filter(target_work_id_a %in% selected, target_work_id_b %in% selected) %>%
    slice_max(shared_citing_sources, n = 85, with_ties = FALSE) %>%
    transmute(a = target_work_id_a, b = target_work_id_b, shared_citing_sources), incident) %>%
  distinct(a, b, .keep_all = TRUE)
cocitation_nodes <- cocit_node_metrics %>%
  filter(target_work_id %in% unique(c(cocitation_edges$a, cocitation_edges$b))) %>%
  left_join(chapter_crosswalk %>% filter(!is.na(target_work_id), target_work_id != "") %>%
              select(target_work_id, chapter_no), by = "target_work_id") %>%
  mutate(topic_group = "")

# Select distinct normalized author/work combinations and attach publication year.
core_author_work <- authors %>% transmute(target_work_id, author = str_squish(author_normalized)) %>%
  filter(!is.na(author), author != "") %>% distinct(target_work_id, author) %>%
  inner_join(core %>% select(target_work_id, year), by = "target_work_id")

# Number authors within a work, join each work's author list to itself, and keep
# pairs whose first index is smaller than the second. Aggregate shared works.
indexed_authors <- core_author_work %>% group_by(target_work_id) %>%
  arrange(author, .by_group = TRUE) %>% mutate(author_index = row_number()) %>% ungroup()
coauthor_pairs <- indexed_authors %>%
  select(target_work_id, year, author_index_1 = author_index, author_1 = author) %>%
  inner_join(indexed_authors %>% select(target_work_id, author_index_2 = author_index, author_2 = author),
             by = "target_work_id", relationship = "many-to-many") %>%
  filter(author_index_1 < author_index_2) %>% group_by(author_1, author_2) %>%
  summarise(shared_works = n_distinct(target_work_id), first_shared_year = min(year),
            latest_shared_year = max(year), .groups = "drop") %>%
  arrange(desc(shared_works), author_1, author_2)
stopifnot(nrow(coauthor_pairs) == 656L, sum(coauthor_pairs$shared_works >= 2) == 16L)
