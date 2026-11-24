# Variable choice and missing values (Part A)

This note fixes, for every regression in Part A, which variables enter as predictors, how they are coded, and which patients each model is fitted on. All decisions are final.

## Summary

| Variable | Logistic and probit models | Poisson and negative binomial models | Reason |
|---|---|---|---|
| `age` | In, as `age10` (age in decades) | In, as `age10` | Prognostic factor known at diagnosis |
| `tumor_size` | In, as `size_cm` (size in cm) | In, as `size_cm` | Tumour burden, core pathology variable |
| `grade` | In, factor (reference grade 1) | In, factor (reference grade 1) | How aggressive the tumour cells are |
| `lymph_nodes_positive` | In, as `log2_nodes` = log₂(1 + nodes) | In, as `log2_nodes` | Nodal spread, the strongest classical factor |
| `er_status` | In (reference Negative) | In (reference Negative) | Hormone receptor |
| `pr_status` | In (reference Negative) | In (reference Negative) | Second hormone receptor, not redundant with ER |
| `her2_status` | In (reference Negative) | In (reference Negative) | Aggressive, drug-targetable subtype |
| `chemotherapy` | Only in questions (b) and (c) | Out | Treatment decided after diagnosis |
| `surgery`, `hormone_therapy`, `radiotherapy` | Out | Out | Treatments decided after diagnosis |
| `os_months`, `death`, `vital_status`, `rfs_months` | Out | Out | Information leakage |
| `relapse` | Response | Out | Outcome observed after the tissue was sampled |
| `mutation_count` | Out | Response | Not part of routine diagnosis |
| `menopause`, `npi`, `tmb` | Out | Out | Deterministic functions of other variables |
| `er_ihc`, `tumor_stage` | Out | Out | Near-duplicates of included predictors |
| `patient_id`, `cohort` | Out | Out | Identifier and grouping variable |
| `intclust`, `laterality`, `cellularity` | Out | Out | Not relevant to the clinical question |

**Patients used.** Every model is fitted on one of two fixed datasets, defined in Section 4:
- the **relapse dataset**: 1814 patients with complete data on the seven predictors, chemotherapy and relapse, used for all logistic and probit models;
- the **mutation dataset**: 1815 patients with complete data on the seven predictors and the mutation count, used for all Poisson and negative binomial models.

Unless stated otherwise, the figures quoted below are computed on the relapse dataset.

## 1. How the choices were made

The predictor list follows from what each variable measures and when it becomes known, and was fixed before looking at any model output. The brief names four reasons to exclude a variable: information leakage, deterministic functions, near-duplicates and identifiers. Two more apply here: treatments are excluded from the prognostic model by instruction, and some variables are not relevant to the question being asked.

The data were used for two things only:
- to confirm that a variable is redundant (for example, that menopause is just age below 50);
- to choose the functional form of the included predictors with AIC, the criterion of Wasserman Section 13.6 and of the brief's Appendix.

No predictor was added or dropped because of its association with the response.

## 2. Included predictors and their coding

The seven predictors are the classical clinical and pathological variables (age, tumour size, grade, nodal status) plus the three receptor statuses. These are the standard prognostic factors in breast cancer, all are known at diagnosis, and none is a function of another.

**Grade and nodal status are not substitutes.** Grade describes how aggressive the cells look; nodal status describes how far the tumour has spread. In the relapse dataset they are only weakly related (Spearman correlation 0.16).

**PR is kept even though it is correlated with ER.** Correlation alone is no reason to exclude a variable, and PR carries information of its own: almost all ER-negative tumours are PR-negative (414 of 431), but ER-positive tumours split into 450 PR-negative and 933 PR-positive.

**Collinearity is not a problem (added check).** All variance inflation factors are below 4. The two grade indicators have the highest values, about 3.5, only because the reference group (grade 1) is small.

The same seven predictors are used for the mutation count. The question asks which clinical characteristics of the tumour go with a higher mutational burden, and size, grade, nodal spread and receptor status are exactly those. Age is kept because mutations accumulate over a lifetime, which makes it a natural adjustment.

**Age and tumour size** enter in decades (`age10 = age / 10`) and in centimetres (`size_cm = tumor_size / 10`). Rescaling changes the units of the coefficient but not the fit. It gives odds ratios per 10 years and per centimetre, which are easier to read than the tiny per-year and per-millimetre ratios. Both stay linear: neither a quadratic term in age (AIC 2304.1) nor log tumour size (AIC 2302.5) improves on the linear terms (AIC 2302.2).

**Lymph nodes** enter as `log2_nodes = log2(1 + lymph_nodes_positive)`.
- The count is extremely skewed: 52% of patients have no positive node, and the maximum is 45.
- Entered raw, the model would assume that each extra node multiplies the odds by the same factor all the way up to 45, and the few patients with 20 or more nodes would drive the slope.
- On the log scale each extra node matters less as the count grows, which matches clinical staging (0, 1 to 3, 4 to 9, 10 or more nodes).
- The log scale also fits better: AIC 2302.2, against 2311.6 for the raw count and 2317.5 for the four clinical categories.
- The +1 handles the zeros. Base 2 makes the odds ratio read "per doubling of (1 + number of positive nodes)", for example going from 0 to 1, 1 to 3, or 3 to 7 nodes.

**Grade** enters as a factor with grade 1 as reference. A numeric score would force the step from grade 1 to 2 to equal the step from grade 2 to 3. The factor costs one extra parameter and lets the data decide. The two codings fit equally well (AIC 2302.2 for the factor vs 2302.8 for the score), so the less restrictive one is kept.

**ER, PR and HER2 status** are factors with Negative as reference, so each odds ratio compares receptor-positive with receptor-negative tumours. This is also R's default (levels in alphabetical order), so no recoding is needed.

The AIC values above are for the logistic model of question (a), fitted on the relapse dataset. Each compares the final model (AIC 2302.2) with a version that changes the coding of a single predictor.

**The Poisson and negative binomial models use exactly the same coding.** Under the negative binomial model, which fits the counts better than the Poisson (questions (b) to (d) of the Poisson part), the alternative codings differ by at most 4.2 AIC points with no consistent winner. There is therefore no reason to code the two parts differently. Comparing codings with the Poisson AIC would be unreliable, because overdispersion inflates the Poisson log-likelihood differences.

## 3. Excluded variables

**Information leakage.**
- `os_months`, `death` and `vital_status` are recorded during follow-up, after diagnosis, so a model that predicts at diagnosis cannot use them.
- Some of them partly contain the response: every patient who "Died of Disease" has relapse = 1 by definition (601 of 601 in the relapse dataset), and `death` includes those deaths.
- `rfs_months` is the time to the relapse event itself and is recorded together with the response.
- `relapse` is excluded from the Poisson and negative binomial models for the same reason: it happens after the tissue in which the mutations were counted was collected.

**Treatments.** `surgery`, `chemotherapy`, `hormone_therapy` and `radiotherapy` are decided after diagnosis, partly on the basis of how severe the tumour is.
- They are therefore not available to a model meant to predict at diagnosis, and the brief excludes them from question (a) explicitly.
- Chemotherapy comes back in questions (b) and (c), where it is the subject of the question.
- Treatments are also excluded from the Poisson and negative binomial models: the tissue was collected at surgery, before any further treatment, so treatment cannot affect the mutations measured in it.

**Deterministic functions.**
- `menopause` is a function of age: in this file it is "Pre" exactly when age is below 50 (the largest "Pre" age is 49.98, the smallest "Post" age 50.01).
- `npi` is computed from tumour size, grade and nodes, all of which are already in the model.
- `tmb` is `mutation_count` divided by the size of the sequenced panel (tmb = 1.3075 × count for 2302 of the 2357 patients with at least one mutation). In the Poisson and negative binomial models it is a function of the response itself.

**Near-duplicates.**
- `er_ihc` measures the same receptor as `er_status`, by tissue staining instead of gene expression, and the two disagree for only 6.5% of patients in the relapse dataset. With both in the model, each coefficient would mean "the effect of ER while holding ER fixed". `er_status` is kept because the brief names it in question (d), it comes from the same source as PR and HER2, and it has fewer missing values.
- `tumor_stage` is built from tumour size and nodal status (plus distant metastasis), so it largely repeats two included predictors. Its only extra information, metastasis at diagnosis, concerns 9 stage-4 patients in the relapse dataset. It is also missing for 25% of that dataset, which would cut it from 1814 to 1353 patients.

**Identifiers and grouping variables.**
- `patient_id` is an identifier.
- `cohort` records the hospital and period of recruitment: it describes how the data were collected, not the patient, and it is not defined for a new patient.

**Not relevant to the question.**
- `intclust` is a genomic classification obtained by clustering expression and copy-number data, not a clinical or pathological measurement. It overlaps with `er_status` (cluster 4 is split by ER status), and its 11 levels would add 10 parameters. In question (d) it would bring molecular information into the model that is meant to contain only classical variables.
- `laterality`: there is no clinical reason why the left or the right breast should change prognosis or mutational burden, and it is missing for 26% of patients (102 patients would be lost from the relapse dataset).
- `mutation_count` (logistic and probit models only) requires sequencing a 173-gene research panel. It is not part of routine diagnosis and not one of the "classical clinical and pathological variables" of question (d).
- `cellularity` is the share of tumour cells in the sample. It measures the quality of the sample, not a property of the patient or the tumour, and in the logistic and probit models it has no plausible link to relapse.
  - In the Poisson and negative binomial models it does affect the measured count: low-cellularity samples show about 17% fewer mutations (rate ratio 0.83 against high cellularity), because mutations present in few cells are harder to detect.
  - It is still excluded, because the question is about clinical characteristics, and a sensitivity check shows that leaving it out does not distort them. On the 1765 patients with cellularity recorded, adding it to the negative binomial model changes every clinical rate ratio by less than 0.015.
  - Report this check in one sentence when answering Poisson question (a).

## 4. Missing values

All models are fitted by complete-case analysis, which is what `glm` does by default. They are fitted on two fixed datasets, though, rather than letting each model drop its own patients. The brief requires that models being compared are fitted on the same observations; otherwise a difference between two fits could come from the change of patients rather than the change of model.

**The relapse dataset (logistic and probit models) has 1814 patients:** those with no missing value in the seven predictors, `chemotherapy` and `relapse`.
- It is used for logistic questions (a), (b), (c), both models in (d), and the probit model in (g).
- Including `chemotherapy` in the definition costs nothing: it is missing for exactly the same 529 patients as PR and HER2 status.
- Question (b) is fitted on this dataset as well, rather than on all 1980 patients with chemotherapy recorded, so that (b) and (c) differ only by the adjustment.
- Here, 53.2% of treated patients relapse (n = 387) against 37.2% of untreated patients (n = 1427), close to the 54% and 37% quoted in the brief.

**The mutation dataset (Poisson and negative binomial models) has 1815 patients:** those with no missing value in the seven predictors and `mutation_count`. The Poisson and negative binomial models must use the same patients, because AIC compares log-likelihoods and is only meaningful on identical data.

**What is lost, and why it is acceptable.** Going from 2509 patients to the 1814 of the relapse dataset drops 695:
- 529 form a structural block with no receptor, treatment or integrative-cluster data at all: every patient of cohorts 6 to 9, 288 of cohort 1, and 11 with no cohort recorded;
- 166 have scattered missing values in tumour size, grade, nodal status or relapse.

As a result, the relapse dataset contains only cohorts 1 to 5. Complete-case regression estimates stay unbiased when being missing does not depend on the response once the predictors are accounted for (a standard result, added here). In this dataset, missingness is driven mainly by which hospital and period a patient came from, and the relapse rate of the dropped block (39%) is close to that of the kept patients (41%). This is reassuring but not proof, and it belongs in the limitations. Imputation is not used: the brief does not ask for it, and it would add assumptions that would themselves need defending.

**Implementation in R.** Build the coded variables and both datasets once, in the shared preparation script, and pass `data = relapse_data` or `data = mutation_data` to every fit:

```r
clinical <- read.csv("metabric_clinical.csv", stringsAsFactors = TRUE)
clinical$age10      <- clinical$age / 10
clinical$size_cm    <- clinical$tumor_size / 10
clinical$log2_nodes <- log2(1 + clinical$lymph_nodes_positive)
clinical$grade      <- factor(clinical$grade)

pred <- c("age10", "size_cm", "grade", "log2_nodes", "er_status", "pr_status", "her2_status")
relapse_data  <- na.omit(clinical[, c("relapse", "chemotherapy", pred)])   # 1814 patients
mutation_data <- na.omit(clinical[, c("mutation_count", pred)])            # 1815 patients
```
