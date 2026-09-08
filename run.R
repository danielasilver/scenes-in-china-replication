#!/usr/bin/env Rscript
# Run all figures with Rscript run.R, or one figure with Rscript run.R 7.

# Find this script's folder so the package can be run from any working directory.
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
root <- dirname(normalizePath(gsub("~+~", " ", sub("^--file=", "", script_arg[1]), fixed = TRUE), mustWork = TRUE))

# Use the package-local R library if install.R has created it.
local_library <- file.path(root, "renv/library")
if (dir.exists(local_library)) .libPaths(c(local_library, .libPaths()))

# Set UTF-8 text handling for the Chinese names and titles in the CSV files.
for (loc in c("en_US.UTF-8", "C.UTF-8", "UTF-8")) {
  result <- suppressWarnings(Sys.setlocale("LC_CTYPE", loc))
  if (nzchar(result)) break
}
Sys.setenv(TZ = "UTC")

# Check dependencies before loading them; stop with an installation instruction.
packages <- c("readr", "dplyr", "tidyr", "stringr", "forcats", "ggplot2", "scales",
              "igraph", "ggrepel", "patchwork", "svglite")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "),
                          ". Run Rscript install.R first.")
# Compare dependency versions with the recorded environment before loading them.
# A different version is reported explicitly; output tables are still checked below.
recorded <- read.csv(file.path(root, "config/software_versions.csv"), stringsAsFactors = FALSE)
versions <- vapply(recorded$package, function(p) {
  if (requireNamespace(p, quietly = TRUE)) packageDescription(p, fields = "Version") else NA_character_
}, character(1))
different <- is.na(versions) | versions != recorded$version
if (any(different)) warning("Dependency versions differ from the tested environment: ",
                           paste(recorded$package[different], collapse = ", "),
                           ". Run Rscript install.R to restore the lockfile.")
suppressPackageStartupMessages(invisible(lapply(packages, library, character.only = TRUE)))

# Accept no argument (all eight figures) or one integer from 1 to 8.
args <- commandArgs(trailingOnly = TRUE)
figures <- if (!length(args)) 1:8 else suppressWarnings(as.integer(args))
if (length(args) > 1 || anyNA(figures) || any(!figures %in% 1:8)) {
  stop("Usage: Rscript run.R [1-8]")
}

# Create output folders and load the shared plotting settings and data calculations.
figure_dir <- file.path(root, "outputs/figures")
table_dir <- file.path(root, "outputs/tables")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)
source(file.path(root, "scripts/plot_helpers.R"), encoding = "UTF-8")
source(file.path(root, "scripts/prepare_data.R"), encoding = "UTF-8")

# Restore the original random state before each figure. This keeps network
# positions the same whether a figure is run alone or in the full sequence.
random_states <- readRDS(file.path(root, "config/figure_random_states.rds"))
for (i in figures) {
  assign(".Random.seed", random_states[[as.character(i)]], envir = .GlobalEnv)
  path <- list.files(file.path(root, "scripts"), pattern = sprintf("^figure_%02d_.*\\.R$", i), full.names = TRUE)
  stopifnot(length(path) == 1L)
  message("Creating Figure ", i, "...")
  source(path, encoding = "UTF-8")
}

# Compare generated figure tables with the saved chapter tables and save the
# software versions from this run. No reference table is read by the figure code.
source(file.path(root, "scripts/validate_outputs.R"), encoding = "UTF-8")
writeLines(capture.output(sessionInfo()), file.path(root, "outputs/sessionInfo.txt"))
message("Completed. Figures: ", figure_dir)
