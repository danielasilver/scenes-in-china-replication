# Compare only figures requested in this run. Check columns and rows in order;
# compare numeric values with a small tolerance for CSV floating-point rounding.
reference_dir <- file.path(root, "reference_tables")
results <- list()
for (i in figures) {
  paths <- list.files(reference_dir, pattern = sprintf("^figure_%02d[a-z]?_.*\\.csv$", i), full.names = TRUE)
  stopifnot(length(paths) == c(2L, 1L, 2L, 2L, 2L, 1L, 3L, 1L)[i])
  for (path in paths) {
    expected <- read_csv(path, show_col_types = FALSE)
    actual <- read_csv(file.path(table_dir, basename(path)), show_col_types = FALSE)
    columns_ok <- identical(names(expected), names(actual))
    same <- columns_ok && isTRUE(all.equal(as.data.frame(expected), as.data.frame(actual),
                                           check.attributes = FALSE, tolerance = 1e-10))
    results[[length(results) + 1L]] <- tibble(file = basename(path), rows = nrow(actual),
                                            matches_reference = same)
    if (!same) {
      print(all.equal(as.data.frame(expected), as.data.frame(actual),
                      check.attributes = FALSE, tolerance = 1e-10))
    }
  }
  # Check that both image formats were actually written and contain bytes.
  images <- list.files(figure_dir, pattern = sprintf("^figure_%02d_.*\\.(png|svg)$", i), full.names = TRUE)
  stopifnot(length(images) == 2L, all(file.info(images)$size > 1000))
}
result <- bind_rows(results)
write_csv(result, file.path(root, "outputs/validation_results.csv"))
if (!all(result$matches_reference)) stop("A figure table differs from the chapter reference. See outputs/validation_results.csv.")
message("Validated ", nrow(result), " figure tables against the chapter references.")
