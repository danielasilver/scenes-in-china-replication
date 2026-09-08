#!/usr/bin/env Rscript
# Install the package versions listed in renv.lock into this folder's local library.
# Internet access and permission to write inside this package folder are required.

# Resolve the package folder from this script, including R's encoding of spaces.
script_arg <- grep("^--file=", commandArgs(), value = TRUE)[1]
root <- dirname(normalizePath(gsub("~+~", " ", sub("^--file=", "", script_arg), fixed = TRUE)))
local_library <- file.path(root, "renv/library")
dir.create(local_library, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(local_library, .libPaths()))

# Install renv as the environment-restoration helper if it is not already present.
# The analysis dependencies themselves are pinned to versions in the lockfile.
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org", lib = local_library)
}

# Restore the recorded versions into the package-local library. This does not
# activate renv globally or edit another project's environment.
renv::restore(project = root, library = local_library,
              lockfile = file.path(root, "renv.lock"), prompt = FALSE)
message("Dependencies installed. Run Rscript run.R to reproduce the figures.")
