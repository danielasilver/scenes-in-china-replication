# Scenes in China: introduction figure replication

This package reproduces the Introduction to Scenes in China's eight figures. The data include final membership, topic, title-marker, and disciplinary coding. The scripts calculate publication summaries, citation histories, networks, and chart coordinates from those inputs.

## Run

Use R 4.4.1, the version used for validation. Open a terminal in this folder and run:

```sh
Rscript install.R
Rscript run.R
```

`install.R` restores the package versions in `renv.lock` into this folder’s local R library. Installation needs internet access; the figure build uses only local files. On systems without matching binary R packages, installation may require the platform’s R build tools. If the recorded packages are already installed, run `Rscript run.R` directly.

To recreate one figure:

```sh
Rscript run.R 7
```

The [finished figures](figures/) and [reference tables](reference_tables/) are included for viewing and download.

The command writes high-resolution PNG and vector SVG figures into `outputs/figures/`, the plotted data into `outputs/tables/`, and checks into `outputs/validation_results.csv`. Existing output files for the selected figures are replaced; input data are not edited. The full run checks all 14 figure tables. Individual runs check only that figure’s tables.

## Contents

| Path | Contents |
| --- | --- |
| [METHODS.md](METHODS.md) | Methodological appendix |
| [data/](data/) | Six cleaned data tables |
| [Data dictionary](docs/DATA_DICTIONARY.md) | Every input field, table grain, join key, and missing-value convention |
| [scripts/prepare_data.R](scripts/prepare_data.R) | Reads inputs, checks joins, and calculates figure summaries |
| [scripts/plot_helpers.R](scripts/plot_helpers.R) | Shared colors, labels, and output functions |
| `scripts/figure_01_*.R` through `figure_08_*.R` | One script per figure, with comments explaining each code block |
| [config/](config/) | Selected citation-history cases, figure random states, and tested software versions |
| [figures/](figures/) | Eight finished figures in PNG and SVG formats |
| [reference_tables/](reference_tables/) | Fourteen expected figure tables used to check a rerun |

The package begins with 1,126 scholarly targets and stored classifications. Collection, screening, and variable construction are documented in the appendix. The citation relation table contains one row per citing publication and eligible target; all calculations deduplicate at the unit stated in the script.

## Figures and scripts

| Figure | Script | Main inputs |
| --- | --- | --- |
| 1. Gateway centrality | [Figure 1](scripts/figure_01_gateway_centrality.R) | Publications, citation counts, citation relations, chapter sources |
| 2. Topic diversification | [Figure 2](scripts/figure_02_topic_diversification.R) | Publications and their stored topic codes |
| 3. Disciplinary spread | [Figure 3](scripts/figure_03_disciplinary_spread.R) | Publications, citing publications, citation relations |
| 4. Publication takeoff and citation timing | [Figure 4](scripts/figure_04_publication_takeoff_and_citation_timing.R) | Publications, counts, citing years, citation relations, selected cases |
| 5. Neighboring literatures and bridges | [Figure 5](scripts/figure_05_neighboring_literatures_and_bridges.R) | Publications, citing publications, citation relations |
| 6. Operational turn | [Figure 6](scripts/figure_06_operational_turn.R) | Publications and their three stored title markers |
| 7. Coauthorship structure | [Figure 7](scripts/figure_07_coauthorship_structure.R) | Publications and normalized authorships |
| 8. Position of the volume | [Figure 8](scripts/figure_08_position_of_the_volume.R) | Chapter-source crosswalk |

## Checking the result

The package was tested with R 4.4.1 on macOS. A standalone run reproduced all 14 figure tables and all eight chapter PNGs exactly.

The runner compares every generated table with the chapter’s reference table, checking row order, columns, text, and numerical values (tolerance `1e-10`). It stops if a table differs. Reference tables are used only for validation; the plotting scripts do not read them. Basic checks also cover sample sizes, identifiers, joins, counts, and output-file creation.

The saved random states let network figures reproduce the same layouts in full and individual runs. Plots use Helvetica, matching the chapter figures. Font substitution and graphics-device differences on another operating system can change text spacing or image bytes while the underlying data remain identical.

The package and appendix use the 8 September 2026 data release; individual citation observations retain their actual saved dates. See the [data dictionary](docs/DATA_DICTIONARY.md) for the distinction between the full collection and the cleaned eligible-target frame.
