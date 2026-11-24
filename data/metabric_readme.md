# METABRIC data — `metabric_clinical.csv` and `metabric_genes.csv`

Source: METABRIC (Molecular Taxonomy of Breast Cancer International Consortium), Curtis et al., *Nature* 2012; Pereira et al., *Nature Communications* 2016. The raw data come from the cBioPortal study `brca_metabric` (https://www.cbioportal.org/study/summary?id=brca_metabric) and were retrieved through the cBioPortal API. Two files are provided: `metabric_clinical.csv`, with the clinical data, and `metabric_genes.csv`, with the gene expression data.

The clinical data come from the tables `data_clinical_patient.txt` and `data_clinical_sample.txt`. The sample table provides `tumor_size`, `tumor_stage`, `grade`, `er_status`, `pr_status`, `her2_status`, `mutation_count` and `tmb` (one sample per patient); all the other variables come from the patient table. The two tables were merged into one row per patient and reworked for teaching purposes: columns were renamed, and some were recoded or removed. In the raw data, `mutation_count` is missing for 151 patients, but 75 of them were actually sequenced and no mutation was found: their `mutation_count` was set to 0. The file is therefore not the original export.

The clinical dataset consists of **2509 patients** for which 27 variables are recorded. Missing values are written as `NA`; about 530 patients (21%) have no information on treatments, PR/HER2 status, integrative cluster and overall survival.

Read files in R with

```r
clinical <- read.csv("metabric_clinical.csv", stringsAsFactors = TRUE)
genes    <- read.csv("metabric_genes.csv")
```

## Clinical variables — `metabric_clinical.csv`

Type: *continuous*, *count*, *binary* (0/1), *factor* (number of levels in parentheses), *ordinal* (integer scores).

| Column | Type | Range / levels | Description | NA % |
|---|---|---|---|---|
| `patient_id` | id | `MB-xxxx` | METABRIC patient identifier | 0 |
| `age` | continuous | 22–96 | age at diagnosis, in years | 0.4 |
| `menopause` | factor (2) | `Pre`, `Post` | menopausal state at diagnosis, inferred from age (post ≈ older women) | 21 |
| `cohort` | factor (9) | 1–9 | recruitment cohort (hospital/period, integer-coded); this is a grouping variable, not a clinical attribute | 0.4 |
| `tumor_size` | continuous | 1–182 | size of the primary tumour, in mm | 6 |
| `tumor_stage` | ordinal | 0–4 | stage at diagnosis, determined from extent of tumour, nodes and metastases (higher = more advanced) | 29 |
| `grade` | ordinal | 1–3 | histological grade (1 = well differentiated, 3 = poorly differentiated) | 5 |
| `lymph_nodes_positive` | count | 0–45 | number of armpit lymph nodes containing tumour cells, i.e. extent of spread | 11 |
| `npi` | continuous | 1–7.2 | Nottingham Prognostic Index, a deterministic function of `tumor_size`, `grade` and `lymph_nodes_positive` | 9 |
| `cellularity` | factor (3) | `Low`, `Moderate`, `High` | proportion of tumour cells in the sequenced sample; measures the quality of the sampling procedure | 24 |
| `laterality` | factor (2) | `Left`, `Right` | side of the tumour | 26 |
| `er_status` | factor (2) | `Positive` (74%), `Negative` | oestrogen receptor: positive = tumour growth is hormone-driven (slower, treatable with hormone therapy); from gene expression | 2 |
| `er_ihc` | factor (2) | `Positive`, `Negative` | same as `er_status` but obtained from pathology test (tissue staining); disagrees in around 5% of cases | 3 |
| `pr_status` | factor (2) | `Positive`, `Negative` | progesterone receptor, another hormone receptor; usually positive together with ER | 21 |
| `her2_status` | factor (2) | `Negative` (88%), `Positive` | HER2 growth-factor receptor: positive = gene is amplified (aggressive tumour, but targetable by drugs) | 21 |
| `intclust` | factor (11) | `1`–`10`, with `4ER+` / `4ER-` | METABRIC molecular classification; grouping variable | 21 |
| `mutation_count` | count | 0–81 | number of non-synonymous mutations found in a panel of 173 sequenced genes | 3 |
| `tmb` | continuous | 0–105 | tumour mutational burden, mutations per megabase; a deterministic function of `mutation_count` | 3 |
| `surgery` | factor (2) | `Mastectomy`, `Breast conserving` | type of surgery: mastectomy (whole breast removed) is often chosen for larger/more advanced tumours | 22 |
| `chemotherapy` | binary | 0/1 | received chemotherapy: often given to younger, higher-risk patients | 21 |
| `hormone_therapy` | binary | 0/1 | received hormone therapy: more likely for ER-positive patients | 21 |
| `radiotherapy` | binary | 0/1 | received radiotherapy: more likely after breast-conserving surgery | 21 |
| `os_months` | continuous | 0–355 | overall survival time, in months, from diagnosis to death or last follow-up | 21 |
| `death` | binary | 0/1 | 1 if the patient died during follow-up, 0 if alive at last follow-up (`os_months` censored) | 21 |
| `vital_status` | factor (3) | `Living`, `Died of Disease`, `Died of Other Causes` | vital status at last follow-up; `death` = 1 for both causes, so deaths unrelated to the tumour are included | 21 |
| `rfs_months` | continuous | 0–389 | relapse-free survival time, in months: time to relapse or death from the disease, whichever first | 5 |
| `relapse` | binary | 0/1 | 1 if the disease recurred *or the patient died of the disease* during follow-up (relapse-free survival event), 0 otherwise (`rfs_months` censored at last follow-up or at death from other causes) | 1 |

## Notes on the variables

**Lymph nodes.** Breast tumours typically spread first to the lymph nodes in the armpit, some of which are removed at surgery and examined. `lymph_nodes_positive` is the number of examined nodes that contained tumour cells: the standard measure of nodal spread in breast cancer and one of the strongest prognostic factors. The number of nodes examined varies by patient and is not reported.

**Hormone receptors (ER, PR).** Proteins on tumour cells to which oestrogen and progesterone bind, stimulating growth. A *positive* tumour is hormone-driven: it tends to grow more slowly and can be treated with hormone therapy, which blocks the receptors. `er_status` and `pr_status` come from gene expression, `er_ihc` from the classical pathology test (tissue staining); the two ER measurements disagree for about 5% of patients.

**HER2.** A growth-factor receptor whose gene (ERBB2) is amplified, i.e. present in extra copies, in 15–20% of breast cancers: the protein is over-produced and the tumour grows aggressively, but responds to targeted drugs (trastuzumab). `her2_status` is positive/negative from gene expression; the expression level of ERBB2 is the column `ERBB2` of `metabric_genes.csv`.

**Integrative clusters.** `intclust` is the classification introduced by the METABRIC study itself (Curtis et al., 2012): ten groups of patients obtained by clustering jointly gene expression and DNA copy-number data, with markedly different survival; cluster 4 was later split by ER status. It is a grouping variable derived from genomic data, not a clinical measurement.

## Gene expression data — `metabric_genes.csv`

The file contains the expression levels of **173 genes** for **1980 patients**. The first column is `patient_id`, which links each row to the same patient in `metabric_clinical.csv`; the other 173 columns are named after the genes (official HUGO gene symbols, e.g. `ERBB2`, `GATA3`, `TP53`) and are sorted alphabetically. There are no missing values.

**Measurements.** Gene expression measures how actively a gene is used by the tumour cells, i.e. how much messenger RNA of that gene is present in the tumour sample. These measures are obtained with a microarray (Illumina HT-12 v3) on the tumour tissue collected at surgery. The values are on a log2 scale: a difference of 1 between two patients means that the gene is twice as expressed. Values are comparable across patients for the same gene, not across genes.

**Gene selection.** The 173 genes are those of the panel sequenced to count the mutations in `mutation_count`, namely genes frequently mutated in breast cancer and selected for that purpose.

**Patients.** Expression data are available for 1980 of the 2509 patients of the clinical dataset (cBioPortal profile `brca_metabric_mrna`); they are essentially the patients with complete clinical follow-up.

