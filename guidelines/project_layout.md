# Project layout: Part A


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



## 3. Shared settings

- [ ] Language: R 
