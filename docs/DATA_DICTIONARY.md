# Data dictionary

CSV inputs are UTF-8. Blank cells denote missing information. TRUE/FALSE are logical values, and marker fields use 0/1. Publication IDs and DOI/ISBN fields are strings. Dates use YYYY-MM-DD.

The machine-readable [dictionary](data_dictionary.csv) defines every input column; [code values](code_values.csv) lists the categories actually present.

## Tables and joins

| File | Rows | One row represents | Join key |
| --- | ---: | --- | --- |
| [publications.csv](../data/publications.csv) | 1,126 | An eligible scholarly target | target_work_id |
| [authorships.csv](../data/authorships.csv) | 1,955 | A normalized author attached to a target | target_work_id + author_normalized |
| [citing_publications.csv](../data/citing_publications.csv) | 8,186 | A canonical citing publication | citing_source_id |
| [citation_relations.csv](../data/citation_relations.csv) | 14,294 | A unique citing-publication/target pair | citing_source_id + target_work_id |
| [citation_counts.csv](../data/citation_counts.csv) | 1,089 | A latest saved target/database count | target_work_id + database |
| [chapter_sources.csv](../data/chapter_sources.csv) | 17 | One focal chapter and its published source | chapter_id |

The publication table contains 1,126 scholarly targets: 584 confirmed, 70 probable, and 472 adjacent/convergent. Of these, 1,030 are primary journal or collection articles, including the 488 confirmed primary publications. The remaining confirmed publications include books and theses.

The relation table contains 14,294 pairs involving eligible targets. The full collection described in the appendix contains 14,295 pairs; one pair points outside this target frame. Repeated database/date observations have already been collapsed. The 8,186-row citing-publication table retains all canonical citing records.

Each database count is separate. Wanfang covers 1,055 targets; Google Scholar 29; Baidu Scholar 1; OpenAlex 2; Crossref 2. Their sum counts target/database pairs, not unique publications. Blank/no-match outcomes are not zero counts.

The chapter crosswalk has 17 rows. Eleven chapter sources directly match eligible targets; blank target IDs in the other rows are retained because Figure 8 uses the chapter source year and branch independently of target-frame membership.

Normalized author names remain provisional string identities; the package does not perform affiliation-level disambiguation.

## config/citation_history_cases.csv

| Variable | Type | Meaning and missing values |
| --- | --- | --- |
| `target_work_id` | string | Stable publication identifier; joins to publications.target_work_id. No missing values except unmatched chapter sources. |
| `case_order` | integer | Order assigned to a selected citation-history case. Stored ordering of the six displayed cases; values need not be consecutive. |
| `case_label` | string | Short author/year label for a selected citation-history case. The six labels displayed in Figure 4. |

## data/authorships.csv

| Variable | Type | Meaning and missing values |
| --- | --- | --- |
| `target_work_id` | string | Stable publication identifier; joins to publications.target_work_id. No missing values except unmatched chapter sources. |
| `author_normalized` | string | Previously normalized author name; one author/work row. Names are provisional string identities, not affiliation-disambiguated people. |

## data/chapter_sources.csv

| Variable | Type | Meaning and missing values |
| --- | --- | --- |
| `chapter_id` | string | Stable volume chapter identifier. CN-CH-02 through CN-CH-18. |
| `chapter_no` | integer | Number of the focal chapter in the volume. 2 through 18; Chapter 1 supplies framing. |
| `source_year` | integer | Source publication year used to position a chapter in Figure 8. Chapter 14 uses online year 2022; its target record uses issue year 2023. |
| `published_source` | string | Title of the chapter’s identified published source. Retained from the final chapter-source crosswalk. |
| `target_work_id` | string | Stable publication identifier; joins to publications.target_work_id. No missing values except unmatched chapter sources. |
| `citing_source_id` | string | Stable citing-publication identifier; joins to citing_publications.citing_source_id. Blank when no citing-source identifier is attached; Figure 8 does not require this field. |
| `branch_topic` | category | Assigned thematic branch of the chapter. Topic code mapped to nine chapter branches in the Figure 8 script. |

## data/citation_counts.csv

| Variable | Type | Meaning and missing values |
| --- | --- | --- |
| `target_work_id` | string | Stable publication identifier; joins to publications.target_work_id. No missing values except unmatched chapter sources. |
| `database` | category | Database displaying the target citation count. Wanfang; Google Scholar; Baidu Scholar; OpenAlex; Crossref. |
| `observation_date` | date YYYY-MM-DD | Date of the latest accepted count retained for this target/database. Counts have different observation dates; this is not a live query. |
| `displayed_citation_count` | nonnegative integer | Citation total displayed by this database for the target. Zero is an observed zero. No-match and inaccessible records have no row. |
| `evidence_url` | URL | Public record or query retained as evidence for the observation. Link availability may change after collection. |
| `confidence` | category | Stored confidence of the count observation. T1/T2/T3 as recorded. |

## data/citation_relations.csv

| Variable | Type | Meaning and missing values |
| --- | --- | --- |
| `citing_source_id` | string | Stable citing-publication identifier; joins to citing_publications.citing_source_id. No missing values. |
| `target_work_id` | string | Stable publication identifier; joins to publications.target_work_id. No missing values except unmatched chapter sources. |
| `databases` | string list | Source databases that exposed this citing-publication/target relation. Semicolon-separated unique labels; a pair is counted once regardless of database count. |
| `first_observed` | date YYYY-MM-DD | Earliest saved observation date for the relation. Observation date, not publication year. |
| `last_observed` | date YYYY-MM-DD | Latest saved observation date for the relation. Observation date, not publication year. |

## data/citing_publications.csv

| Variable | Type | Meaning and missing values |
| --- | --- | --- |
| `citing_source_id` | string | Stable citing-publication identifier; joins to citing_publications.citing_source_id. No missing values. |
| `title` | string | Canonical title retained in the cleaned database. Blank only if unavailable. |
| `authors` | string | Bibliographic author string as retained in the cleaned record. Blank means author metadata unavailable; not parsed during replication. |
| `year` | integer | Recorded publication year. Blank means year unavailable; undated citing publications are excluded from time calculations. |
| `venue` | string | Journal, collection, publisher, or other publication venue. Blank means venue unavailable. |
| `doi` | string | Recorded DOI of a citing publication. Blank means no DOI recorded. |
| `document_type` | category | Stored publication type of a citing source. Blank or unknown means unavailable. |
| `language` | category | Recorded language of a citing source. Blank or unknown means unavailable. |
| `harmonized_field` | category | Final disciplinary field assigned to a citing publication. Field codes listed below; provisional assignments remain included. |
| `field_confidence` | category | Evidence confidence of a citing-field assignment. T1 primary evidence; T2 verified synthesis; T3 provisional assignment. |

## data/publications.csv

| Variable | Type | Meaning and missing values |
| --- | --- | --- |
| `target_work_id` | string | Stable publication identifier; joins to publications.target_work_id. No missing values except unmatched chapter sources. |
| `title` | string | Canonical title retained in the cleaned database. Blank only if unavailable. |
| `title_zh` | string | Chinese title, when available. Blank means no Chinese title recorded. |
| `title_en` | string | English title, when available. Blank means no English title recorded. |
| `authors` | string | Bibliographic author string as retained in the cleaned record. Blank means author metadata unavailable; not parsed during replication. |
| `year` | integer | Recorded publication year. Blank means year unavailable; undated citing publications are excluded from time calculations. |
| `venue` | string | Journal, collection, publisher, or other publication venue. Blank means venue unavailable. |
| `work_type` | category | Stored publication type used in forming the scholarly sample. Values listed below. |
| `doi_or_isbn` | string | Recorded DOI or ISBN; kept as an identifier, not a number. Blank means no identifier recorded. |
| `scenes_membership_tier` | category | Final membership classification. confirmed_scenes; probable_scenes; adjacent_convergent. |
| `scenes_core_member` | boolean | TRUE exactly when membership is confirmed_scenes. TRUE/FALSE; no missing values. |
| `primary_periodical` | boolean | TRUE for the primary journal and collection-article population. TRUE/FALSE; no missing values. |
| `primary_topic` | category | Final primary topic code assigned to the publication. One code per work; labels listed in the code values table. |
| `topic_confidence` | category | Recorded evidence-confidence code for the topic assignment. T1/T2/T3 as stored; final coding can remain provisional. |
| `policy_marker` | binary integer | Final title marker: 1 when a policy expression was coded, otherwise 0. 0/1; no missing values. |
| `design_marker` | binary integer | Final title marker: 1 when a design expression was coded, otherwise 0. 0/1; no missing values. |
| `measurement_marker` | binary integer | Final title marker: 1 when a measurement expression was coded, otherwise 0. 0/1; no missing values. |
| `period` | category | Stored publication-year period. Six named periods; the four middle periods enter Figures 2 and 6. |
| `venue_field_complete` | category | Final harmonized venue field for a confirmed primary publication. Blank outside the 488 confirmed primary works; field codes listed below. |
| `venue_field_confidence` | category | Evidence confidence attached to the final venue field. Blank outside the 488 confirmed primary works. |
