# Models by question (Part A)

This note specifies, for every question in Part A, the model to fit, the patients it is fitted on, the R code, and what to report. Multiple testing is not covered, because it was added to the brief later. The note is self-contained: the data, the predictors and the inference settings are described in the first three sections. Everything is implemented in R, the language of the course notebooks, with `glm` and `MASS::glm.nb`.

## Summary

| Question | Model | Patients | What to report |
|---|---|---|---|
| Logistic (a) | Logit link, 7 predictors | Relapse dataset (1814) | Odds ratios with 95% CIs; interpretation |
| Logistic (b) | Logit link, chemotherapy only | Relapse dataset (1814) | Crude chemotherapy OR with 95% CI |
| Logistic (c) | Model (a) + chemotherapy | Relapse dataset (1814) | Crude vs adjusted chemotherapy OR; confounding; effectiveness |
| Logistic (d) | 4 classical predictors vs the same + ER, PR, HER2 | Relapse dataset, 80/20 split, seed 20592 | Test-set log-loss of both models |
| Probit (e) | Probit link, theory | None | Model, score, Hessian, Fisher information |
| Probit (f) | Own Newton and Fisher scoring code | Relapse dataset (1814) | Code only, not in the report |
| Probit (g) | Probit link, predictors of (a) | Relapse dataset (1814) | Trajectory plot; Newton vs Fisher scoring vs `glm`; logit vs probit |
| Poisson (a) | Poisson, log link, 7 predictors | Mutation dataset (1815) | Rate ratios with 95% CIs; interpretation |
| Poisson (b) | Model (a) | Mutation dataset (1815) | Pearson dispersion statistic; how the NB model helps |
| Poisson (c) | Negative binomial, log link, θ by ML | Mutation dataset (1815) | NB vs Poisson CIs; conclusions that change |
| Poisson (d) | (a) vs (c) | Mutation dataset (1815) | AIC of both models |

## 1. Data

All models use `metabric_clinical.csv` and are fitted by complete-case analysis on one of two fixed datasets. The brief requires that models being compared are fitted on the same patients; otherwise a difference between two fits could come from the change of patients rather than the change of model.

- **Relapse dataset, 1814 patients:** no missing value in the seven predictors, `chemotherapy` and `relapse`. It is used for every logistic and probit model, including question (b), so that all the models compared in this part use exactly the same patients.
- **Mutation dataset, 1815 patients:** no missing value in the seven predictors and `mutation_count`. It is used for the Poisson and negative binomial models, which must share their patients for their AICs to be comparable.

Built in R as follows:

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

## 2. Predictors

The same seven predictors are used for relapse and for the mutation count. They are the classical clinical and pathological variables plus the three receptor statuses, all known at diagnosis:

- **Age**, in decades (`age10`), so odds ratios read per 10 years.
- **Tumour size**, in centimetres (`size_cm`), so odds ratios read per cm.
- **Grade**, as a factor with grade 1 as reference, so the steps from grade 1 to 2 and from 2 to 3 are not forced to be equal.
- **Positive lymph nodes**, as `log2_nodes = log2(1 + lymph_nodes_positive)`. The count is very skewed (52% zeros, maximum 45). The log scale lets each extra node matter less as the count grows, and it fits clearly better than the raw count (AIC 2302.2 vs 2311.6). The odds ratio reads "per doubling of (1 + number of positive nodes)".
- **ER, PR and HER2 status**, as factors with Negative as reference (R's default), so each odds ratio compares receptor-positive with receptor-negative tumours.

All other variables are excluded:
- treatments, because they are decided after diagnosis (chemotherapy enters only in questions (b) and (c));
- follow-up outcomes, because of information leakage;
- `menopause`, `npi` and `tmb`, because they are deterministic functions of other variables;
- `er_ihc` and `tumor_stage`, because they are near-duplicates;
- `patient_id` and `cohort`, because they are an identifier and a grouping variable;
- `intclust`, `laterality` and `cellularity`, because they are not relevant to the clinical question, and `mutation_count` in the relapse models, because it is not part of routine diagnosis.

Logistic (a), probit (g) and all Poisson and negative binomial models use the same linear predictor:

η_i = β₀ + β₁ age10 + β₂ size_cm + β₃ 1{grade 2} + β₄ 1{grade 3} + β₅ log2_nodes + β₆ 1{ER positive} + β₇ 1{PR positive} + β₈ 1{HER2 positive}

That is 9 parameters. In R the right-hand side is `~ age10 + size_cm + grade + log2_nodes + er_status + pr_status + her2_status`. Logistic (c) adds chemotherapy to it; (b) and (d) are specified below.

## 3. Inference settings for every model

Standard errors come from the inverse Fisher information, as in Lecture 12. By Wasserman Theorem 9.27, β̂ is approximately N(β, J_n), where J_n is the inverse of the Fisher information matrix (9.18), so se_j is the square root of the j-th diagonal element.

95% confidence intervals are Wald intervals, β̂_j ± 1.96 se_j (Theorem 9.19), computed in R with `confint.default(fit)`. Do not use `confint(fit)`: it returns profile-likelihood intervals, which the course did not cover.

Odds ratios and rate ratios are exp(β̂_j), which is their MLE by equivariance (Theorem 9.14). Their intervals are the exponentiated endpoints of the interval for β_j; this keeps the 95% coverage exactly, because exp is strictly increasing.

p-values are those of the Wald test (Definition 10.3) printed by `summary(fit)`, at level α = 0.05. Every coefficient is interpreted with the other predictors held fixed, and as an association, not a causal effect (Wasserman Example 13.17).

## 4. Logistic regression

**(a) Prognostic model.** relapse_i | x_i ~ Bernoulli(p_i) with logit(p_i) = η_i, fitted on the relapse dataset with `glm(relapse ~ age10 + size_cm + grade + log2_nodes + er_status + pr_status + her2_status, family = binomial, data = relapse_data)`. Only information available at diagnosis enters, so all treatments are excluded; say this explicitly in the report.

Report a table with β̂, se, odds ratio, 95% CI and p-value for all 8 predictors. Then interpret four of them in words:
- exp(β̂₅): the multiplicative change in the odds of relapse per doubling of (1 + positive nodes);
- exp(β̂₂): the change per extra centimetre of tumour;
- exp(β̂₄): grade 3 against grade 1;
- one receptor, positive against negative.

For a change of c units the odds ratio is exp(c β̂_j), not c · exp(β̂_j).

**(b) Chemotherapy alone.** logit(p_i) = β₀ + β₁ chemotherapy_i, fitted on the relapse dataset with `glm(relapse ~ chemotherapy, family = binomial, data = relapse_data)`. Report exp(β̂₁) with its 95% CI.
- **Check:** with a single binary predictor the model fits each group's relapse rate exactly. So exp(β̂₁) must equal the odds ratio of the 2×2 table, (206 × 896)/(181 × 531) = 1.92, and β̂₀ must equal log(531/896) = −0.52, the log-odds of relapse without chemotherapy.
- **Text:** state that the relapse dataset is used rather than all 1980 patients with chemotherapy recorded, so that (b) and (c) are fitted on the same patients. Give the relapse rates in this dataset: 53.2% of the 387 treated vs 37.2% of the 1427 untreated.

**(c) Adding chemotherapy to the prognostic model.** Model (a) plus chemotherapy, fitted on the relapse dataset. Put the chemotherapy odds ratio from (b) next to the one from (c).

To explain why they differ, add a short descriptive table comparing treated and untreated patients in the relapse dataset. It shows that chemotherapy went to patients at higher risk of relapse. Compared with untreated patients, treated patients are:
- younger (mean age 50.6 vs 63.8);
- with larger tumours (32.1 vs 24.7 mm);
- with more positive nodes (4.3 vs 1.4);
- more often grade 3 (80% vs 43%);
- more often ER-negative (61% vs 14%).

This is confounding by indication. The crude odds ratio in (b) mixes the effect of the treatment with the risk profile that led to it. Model (c) compares patients with the same measured risk factors.

Effectiveness cannot be concluded from these data:
- the study is observational;
- treatment was assigned by clinicians according to risk;
- adjustment removes only the confounding due to the measured predictors, not that due to anything else the clinicians took into account.

Only randomization makes treated and untreated patients comparable on unmeasured factors.

**(d) Do receptor tests improve prediction?** Two models, both fitted on the same training part of the relapse dataset:
- Base: `relapse ~ age10 + size_cm + grade + log2_nodes`
- Full: base `+ er_status + pr_status + her2_status`

Split the relapse dataset at random, 80% for training and 20% for testing:

```r
set.seed(20592)
idx   <- sample(nrow(relapse_data), 1451)
train <- relapse_data[idx, ]    # 1451 patients
test  <- relapse_data[-idx, ]   # 363 patients
```

Fit both models on `train`, and compute predicted probabilities on `test` with `predict(fit, newdata = test, type = "response")`. Then compute the log-loss −(1/m) Σ_j [Y_j log π̂_j + (1 − Y_j) log(1 − π̂_j)], with m = 363 (Appendix of the brief).

The model with the lower log-loss predicts better and is preferable. Add one sentence of caution: a single test set of 363 patients is noisy, so a small difference in log-loss is weak evidence.

## 5. Probit regression

**(e) Theory.** Y_i | x_i ~ Bernoulli(p_i) independently, with p_i = Φ(η_i), η_i = x_iᵀβ, and Φ the standard Normal CDF. Equivalently, there is a latent score Y*_i = x_iᵀβ + ε_i with ε_i ~ N(0, 1), and Y_i = 1 exactly when Y*_i > 0.

The derivation:
1. Start from the general GLM score of Lectures 10–11, s(β) = Σ_i (Y_i − μ_i)/V(μ_i) · (dμ_i/dη_i) · x_i, with μ_i = Φ(η_i), V(μ) = μ(1 − μ), and dμ_i/dη_i = φ(η_i), the standard Normal density.
2. Differentiate once more to get the Hessian.
3. Take its expectation to get the Fisher information, I_n(β) = −E(H) (Wasserman (9.18)).

The point to make explicitly: probit is not the canonical link, so the Hessian contains Y_i and is not equal to −I_n(β). That is why Newton's method and Fisher scoring are different algorithms here, while for the logit link they coincide.

**(f) Algorithms (code not in the report).**
- Newton's method: β^(t+1) = β^(t) − H(β^(t))⁻¹ s(β^(t)) (Wasserman Section 9.13.4).
- Fisher scoring: β^(t+1) = β^(t) + I_n(β^(t))⁻¹ s(β^(t)).

Build the design matrix from the relapse dataset with the predictors of (a): `X <- model.matrix(~ age10 + size_cm + grade + log2_nodes + er_status + pr_status + her2_status, data = relapse_data)`. Use the settings of the Fisher scoring code in the Lecture 12 notebook:
- start from β^(0) = 0;
- stop when max_j |β_j^(t+1) − β_j^(t)| < 10⁻¹⁰, or after 50 iterations;
- store β^(t) at every iteration.

Our check: from β^(0) = 0 both methods converge on the relapse dataset, Newton in about 5 iterations and Fisher scoring in about 9.

**(g) Fit and comparison.** Fit the probit model with the predictors of (a) on the relapse dataset, using both algorithms. Report three things:
1. **A figure** with one panel per coefficient, showing β_j^(t) against the iteration t for both methods. It shows that the two methods reach the same optimum by different paths, with Newton faster once it is close.
2. **A table** of the final estimates from Newton, Fisher scoring and `glm(relapse ~ age10 + size_cm + grade + log2_nodes + er_status + pr_status + her2_status, family = binomial(link = "probit"), data = relapse_data)`. They should agree to at least 6 decimals; if `glm` falls short, tighten its tolerance with `control = glm.control(epsilon = 1e-12)`.
3. **The comparison with the logit fit of (a)**, which uses the same patients and predictors. The coefficients are not directly comparable. The logit model is the latent model with a standard logistic error, whose standard deviation is π/√3 ≈ 1.81 instead of 1, so logit coefficients come out roughly 1.6 to 1.8 times the probit ones. Compare signs, ratios between coefficients and z-values, which should agree closely. Note that probit coefficients are shifts of the latent score in standard deviations, not log odds ratios.

One remark goes with the table: at the MLE, standard errors from the observed information (−H, used by Newton) and from the expected information (I_n, used by Fisher scoring and `glm`) differ slightly under a non-canonical link. This is expected, not an error.

## 6. Poisson and negative binomial regression

**(a) Poisson model.** mutation_count_i | x_i ~ Poisson(λ_i) with log λ_i = η_i, fitted on the mutation dataset with `glm(mutation_count ~ age10 + size_cm + grade + log2_nodes + er_status + pr_status + her2_status, family = poisson, data = mutation_data)`. Every tumour was sequenced on the same 173-gene panel, so no offset is needed.

Report β̂, se, rate ratio exp(β̂_j), 95% CI and p-value. Interpret each rate ratio as the factor by which the expected number of mutations is multiplied, for example grade 3 against grade 1.

Add one sentence on cellularity (the share of tumour cells in the sample). It is left out because it describes the sample, not the tumour, and a sensitivity check shows this does not matter: on the 1765 patients with cellularity recorded, adding it to the negative binomial model changes every clinical rate ratio by less than 0.015.

**(b) Overdispersion.** Compute the Pearson statistic of model (a), X² = Σ_i (Y_i − λ̂_i)²/λ̂_i, and the ratio X²/(n − k), with n = 1815 and k = 9. In R: `sum(residuals(fit, type = "pearson")^2) / df.residual(fit)`. Under the Poisson model each term has expectation about 1, so the ratio should be close to 1; a ratio well above 1 means overdispersion.

Explain the consequence. The Poisson mean model can still be right, but its standard errors assume V(Y_i) = λ_i. Under overdispersion they are too small, so the intervals are too narrow and the p-values too small.

Then explain the fix. The negative binomial lets each patient's rate vary: if λ_i is Gamma-distributed around μ_i and Y_i | λ_i is Poisson, then E(Y_i) = μ_i and V(Y_i) = μ_i + μ_i²/θ > μ_i. The dispersion parameter θ measures the extra variance, and θ → ∞ gives back the Poisson. Unmeasured differences between tumours, and between samples (for example their tumour-cell content), are natural sources of this heterogeneity.

**(c) Negative binomial model.** Same linear predictor and log link, Y_i | x_i ~ NegBin(μ_i, θ), with β and θ estimated jointly by maximum likelihood on the mutation dataset: `MASS::glm.nb(mutation_count ~ age10 + size_cm + grade + log2_nodes + er_status + pr_status + her2_status, data = mutation_data)`. Mind the parameterization: R's `theta` is the θ above, while some texts use α = 1/θ.

Report θ̂ and a table placing the Poisson and NB rate ratios and 95% CIs side by side. The point estimates should be similar, because the two models have the same mean structure, while the NB intervals are wider. The conclusions that change are the predictors whose interval contains 1 under the NB model but not under the Poisson, or equivalently whose Wald p-value rises above 0.05.

**(d) AIC.** Use AIC = 2p − 2ℓ(β̂) as defined in the brief, with p = 9 for the Poisson model and p = 10 for the NB model, since θ is also estimated. R's `AIC(fit)` already counts θ for `glm.nb` fits. Both models are fitted on the mutation dataset, so their AICs are comparable, and the lower AIC indicates the better model.

Wasserman (Section 13.6, eq. (13.27)) defines AIC as ℓ_S − |S|, to be maximized. The brief's version is −2 times that, so it selects the same model, as Wasserman's own footnote points out.
