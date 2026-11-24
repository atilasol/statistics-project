# Variable choice and missing values

Data: `metabric_clinical.csv` (2509 patients, 27 variables).
Responses: `relapse` (logistic and probit models), `mutation_count` (Poisson and negative binomial models).

## 1. Final predictor sets

| Model family | Predictors | Analysis set |
|---|---|---|
| Logistic / probit | age, tumor_size, grade, lymph_nodes_positive, er_status, pr_status, her2_status (+ chemotherapy in (b), (c)) | L, n = 1814 |
| Poisson / NB | age, tumor_size, grade, lymph_nodes_positive, er_status, pr_status, her2_status (+ cellularity: OPEN) | P, n = 1815 (1765 with cellularity) |

## 2. Included variables

| Variable | Logistic | Poisson | Reason |
|---|---|---|---|
| age | yes | yes | Standard prognostic factor, known at diagnosis. Mutations accumulate with age. |
| tumor_size | yes | yes | Tumour burden; core pathology variable. |
| grade | yes | yes | How aggressive the cells look. Only weakly related to nodes (Spearman 0.16), so not redundant. Entered as a factor. |
| lymph_nodes_positive | yes | yes | Nodal spread; the strongest classical prognostic factor. |
| er_status | yes | yes | Hormone-driven tumours behave differently. Chosen over er_ihc: named in (d), same source (gene expression) as PR and HER2, fewer NAs. |
| pr_status | yes | yes | Not redundant with ER: ER-positive tumours split 450 PR-negative vs 933 PR-positive. Correlation alone is not a reason to exclude. |
| her2_status | yes | yes | HER2-amplified tumours are an aggressive subtype. |
| chemotherapy | (b), (c) only | no | Excluded from the prognostic model (a) by instruction; added back in (b) and (c). |

## 3. Excluded variables

Grouped by the categories the brief names, plus one for treatments and one for judgment calls.

### 3.1 Information leakage (observed after diagnosis, or part of the response)

| Variable | Excluded from | Reason |
|---|---|---|
| os_months, death | both | Follow-up outcomes, observed after diagnosis. `death` includes deaths from the disease, which count as relapse events. |
| vital_status | both | Follow-up outcome. "Died of Disease" implies relapse = 1 by definition (601 of 601 in L). |
| rfs_months | both | The time to the relapse event itself, recorded together with the response. |
| relapse | Poisson | Outcome observed after the tissue was sampled. (It is the response in the logistic models.) |

### 3.2 Not available at diagnosis (treatments)

| Variable | Excluded from | Reason |
|---|---|---|
| surgery, hormone_therapy, radiotherapy, chemotherapy | logistic (a), (d), (g) | Decided after diagnosis, so not available to a prognostic model at diagnosis (brief, question (a)). They are also chosen based on tumour severity. |
| surgery, hormone_therapy, radiotherapy, chemotherapy | Poisson | The tissue was collected at surgery, before any treatment, so treatment cannot affect the mutations measured in it. |

### 3.3 Deterministic functions

| Variable | Excluded from | Reason |
|---|---|---|
| menopause | both | Function of age: "Pre" exactly when age < 50. |
| npi | both | Function of tumor_size, grade and lymph_nodes_positive. |
| tmb | both | Function of mutation_count (mutations per megabase of a fixed panel). In the Poisson models it is a function of the response itself. |

### 3.4 Near-duplicates

| Variable | Excluded from | Reason |
|---|---|---|
| er_ihc | both | Same receptor as er_status, measured by staining; the two disagree for 6.5% of patients in L. Including both makes the ER coefficients uninterpretable. |
| tumor_stage | both | Built from tumour size and nodes (plus metastasis), both already included. Only 9 stage-4 patients in L. 25% NA in L: would cut n from 1814 to 1353. |

### 3.5 Identifiers and grouping variables

| Variable | Excluded from | Reason |
|---|---|---|
| patient_id | both | Identifier. |
| cohort | both | Recruitment cohort (hospital/period): a grouping variable, not a patient attribute. |

### 3.6 Not relevant to the question (judgment calls)

| Variable | Excluded from | Reason |
|---|---|---|
| cellularity | logistic | Measures the quality of the tissue sample, not the patient or tumour; no plausible link to relapse; 24% NA. |
| cellularity | Poisson: OPEN | Low tumour purity hides mutations (mean count 4.9 Low vs 5.8 High). Defensible to include as an adjustment for detection sensitivity; costs 50 patients. |
| laterality | both | No biological reason left vs right should matter; 26% NA, costs 102 patients (1814 to 1712). |
| mutation_count | logistic | Requires sequencing a 173-gene research panel, not routine at diagnosis, and not a "classical clinical and pathological variable" (question (d)). |
| intclust | both | Genomic classification from expression and copy-number clustering, not a clinical measurement. Cluster 4 is split by ER, so it overlaps er_status. 11 levels = 10 extra parameters. |

## 4. Missing values

**Approach:** complete-case analysis on one fixed analysis set per model family. All models compared with each other are fitted on the same patients, as the brief requires.

| Set | Complete on | n | Used for |
|---|---|---|---|
| L | 7 predictors + chemotherapy + relapse | 1814 | Logistic (a), (b), (c), (d), probit (g) |
| P | 7 predictors + mutation_count | 1815 (1765 with cellularity) | Poisson (a), (b), (d); NB (c), (d) |

**What is lost (set L):** 2509 to 1814, i.e. 695 patients.
- 529 form a structural block with no PR, HER2, intclust or treatment data at all (cohorts 1 and 6 to 9). Chemotherapy is missing for exactly these patients, so adding it to the model costs nothing.
- 166 have scattered NAs in size, grade, nodes, ER or relapse.
- As a result, L contains cohorts 1 to 5 only.

**Why (b) also uses L:** fitting (b) on all 1980 patients with chemotherapy data would make the comparison with (c) mix two effects: adjustment and change of sample. In L, relapse rates are 53.2% (chemo, n = 387) vs 37.2% (no chemo, n = 1427).

**Justification:** complete-case regression stays unbiased if being missing does not depend on the response, given the predictors. Here missingness is driven by which hospital/period the patient came from, and the relapse rate in the dropped block (39%) is close to the kept data (41%). Reassuring, not proof: mention in the limitations.

**No imputation:** not asked for by the brief.

**Implementation:** build L and P once (`na.omit` on exactly the columns of the largest model in each family) and pass `data = L` or `data = P` to every fit.

## 5. Decisions still open

- [ ] cellularity in the Poisson models: include as adjustment, or exclude
- [ ] lymph_nodes_positive: raw count or log(1 + nodes) (very skewed: median 0, max 45)
- [ ] Reference levels for factors (e.g. grade 1, ER-positive, HER2-negative)
