# Project layout: Part A

Course: 20592 Statistics and Probability, final project, Part A (classical inference).
Deadline: **3 Dec 2026** (preliminary submission, bonus points). Final submission with Part B: 9 Jan 2027.

Companion files:
- `variable_choice.md`: predictors, exclusions, missing values
- `models_by_question.md`: model, data, output and text points for every question

---

## 1. Work split

| Part | Owner | Questions | Report sections |
|---|---|---|---|
| 1. Logistic | | Logistic (a), (b), (c), (d) | Logistic regression; Limitations |
| 2. Probit | | Probit (e), (f), (g) | Probit regression |
| 3. Poisson + data | | Data prep, Poisson/NB (a) to (d) | Introduction and data; Preliminaries; Poisson and NB |
| Multiple testing | TBD | Released 23 Nov | Multiple testing |

**Why this split:**
- Probit is the heaviest part (theory + own code), so it gets nothing else.
- Poisson is the lightest, so its owner also builds the shared data sets. That person needs set P first anyway.
- Multiple testing: assign as soon as the section is read. Default: whoever is furthest ahead on 28 Nov.

---

## 2. Dependencies

```
Shared settings + variable_choice.md  (everyone, 24 to 25 Nov)
        |
     00_prep  -> sets L and P  (Part 3, by 25 Nov)
        |
   +----+--------------------+-------------------+
   |                         |                   |
Part 1: logistic         Part 2: probit       Part 3: Poisson
(a) -> (b), (c), (d)     (e) -> (f) -> (g)    (a) -> (b) -> (c) -> (d)
```

- Probit (e) is pure theory and needs no data: Part 2 starts it **today**.
- Probit (g) uses the predictors from logistic (a), which are already fixed in `models_by_question.md`. Part 2 fits its own logit model for the logit vs probit comparison, so it never waits for Part 1.
- After 00_prep, the three parts are fully independent.

**Rule:** any change to the variable choice is made in `variable_choice.md` and `00_prep` only, announced in the group chat, and everyone re-runs. Nobody filters or recodes data inside their own script.

---

## 3. Folder structure

```
metabric-project/
  data/
    raw/            the 3 provided files, never edited
    processed/      L and P, written by 00_prep only
  code/
    00_prep.R            Part 3
    01_logistic.R        Part 1
    02_probit.R          Part 2 (Newton + Fisher scoring, (g))
    03_poisson_nb.R      Part 3
    04_multiple_testing.R
  output/
    tables/
    figures/
  notes/
    project_layout.md
    variable_choice.md
    models_by_question.md
  report/
```

(Use `.py` instead of `.R` if the group picks Python.)

---

## 4. Shared settings (fix on day 1)

- [ ] Language: R / Python
- [ ] Seed for the 80/20 split (logistic (d)):
- [ ] CI type: profile likelihood / Wald
- [ ] Factor coding and reference levels (set in 00_prep only): grade reference = 1, ER/PR/HER2 reference = Negative (or Positive)
- [ ] lymph_nodes_positive: raw or log(1 + nodes)
- [ ] cellularity in the Poisson models: in / out

---

## 5. Checklist per part

### Part 3: data prep (by 25 Nov)
- [ ] `00_prep`: read the raw data, set factor levels, build L (n = 1814) and P (n = 1815, or 1765 with cellularity), save both to `data/processed/`
- [ ] Print n for both sets and check them against `variable_choice.md`
- [ ] Write the Introduction and data section and the Preliminaries section (exclusion table + missing values)

### Part 1: logistic
- [ ] (a) coefficient table with ORs and CIs + interpretation
- [ ] (b) chemo-only OR; check it equals 1.92 (the 2x2 table OR in L)
- [ ] (c) crude vs adjusted chemo OR + descriptive table chemo vs no chemo + confounding and effectiveness discussion
- [ ] (d) seeded split, two models, test log-loss, verdict
- [ ] Limitations paragraph (observational data; binary relapse ignores follow-up length; L contains cohorts 1 to 5 only)

### Part 2: probit
- [ ] (e) derivation: model, log-likelihood, score, Hessian, Fisher information
- [ ] (f) Newton and Fisher scoring code, storing β̂ at every iteration
- [ ] (g) trajectory plot, estimates table (Newton / Fisher / glm), logit vs probit comparison

### Part 3: Poisson and NB
- [ ] (a) Poisson table with rate ratios and CIs + interpretation
- [ ] (b) Pearson X²/(n − p) + NB explanation
- [ ] (c) NB fit, θ̂, Poisson vs NB CIs side by side, which conclusions change
- [ ] (d) AIC for both, verdict

### Multiple testing
- [ ] Read the section, split it, add the questions to `models_by_question.md`

---

## 6. Timeline

| Date | Milestone |
|---|---|
| 24 to 25 Nov | Shared settings fixed; variable_choice.md final; 00_prep done; Part 2 starts (e) |
| 26 to 28 Nov | Part 1 (a) to (d); Part 2 (e) and (f); Part 3 Poisson (a) to (d); multiple testing assigned |
| 29 to 30 Nov | Part 2 (g); multiple testing; Parts 1 and 3 write their sections |
| 1 Dec | All sections drafted and merged into one report |
| 2 Dec | Cross-check (below); re-run all code from a clean session; every number in the text matches the output |
| 3 Dec | Submit |

**Cross-check rotation (2 Dec):** Part 1 reviews Part 2, Part 2 reviews Part 3, Part 3 reviews Part 1. The reviewer checks that every "Text" point in `models_by_question.md` is answered and every number matches the output.

---

## 7. Report conventions

- **Sections:** 1 Introduction and data, 2 Preliminaries, 3 Logistic, 4 Probit, 5 Poisson and NB, 6 Multiple testing, 7 Limitations
- **Notation:** β̂ for estimates, OR for odds ratios, RR for rate ratios, 95% CI throughout
- **Rounding:** estimates and ORs to 2 decimals, p-values to 3 decimals (report < 0.001 below that)
- **Tables:** same column order everywhere: estimate, SE, OR or RR, 95% CI, p-value
- **Figures:** labelled axes and a caption, saved to `output/figures/`
- **Open with the n:** each model section states the analysis set and its n in its first sentence
- **Still to confirm with the course:** report length and format, whether code goes in an appendix
