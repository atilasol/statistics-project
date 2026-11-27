library(tidyverse)




#HUBERT LOGITISTIC - preparing the data


clinic <- read.csv("./data/metabric_clinical.csv", stringsAsFactors = TRUE)



clilog <- clinic %>% select(age, tumor_size, lymph_nodes_positive,
                            grade, er_status, pr_status, her2_status, relapse, chemotherapy)


                                                      
missing_check <- clinic %>%
  select(age, tumor_size, lymph_nodes_positive,
         grade, er_status, pr_status, her2_status,
         chemotherapy, relapse) %>%
  mutate(
    complete = if_all(everything(), ~ !is.na(.x))
  ) %>%
  filter(!is.na(relapse))

missing_model <- glm(
  relapse ~ complete,
  data = missing_check,
  family = binomial(link = "logit")
)

summary(missing_model)

    ##checking if the values are missing on random
    #with respect to relapse rate, and well they are (coefficient of complete cases on relapse
     # (coefficient of complete cases on relapse not significant) so we can just drop the NAs.

clilog <- clilog %>% mutate(log2_nodes = log2(1 + lymph_nodes_positive),
                            age10 = age / 10,
                            size_cm = tumor_size / 10,
                            grade = factor(grade))   %>%  drop_na()

# PART A - LOGISTIC RELAPSE MODEL


model_a <- glm(relapse ~ age10 + size_cm + grade + log2_nodes
               + er_status + pr_status + her2_status,
               data = clilog,
               family = binomial(link = "logit"))

summary(model_a)

odds_ratios_a <- exp(coef(model_a))


odds_ratios_a


delta_odds_a <- (odds_ratios_a - 1) * 100  


delta_odds_a



confints_a <- confint.default(model_a)

#creating summary table

results_a <- tibble(
  variable = names(coef(model_a)),
  coefficient = as.numeric(coef(model_a)),
  CI_lower = confints_a[, 1],
  CI_upper = confints_a[, 2],
  odds_ratio = as.numeric(odds_ratios_a),
  odds_change_pct = as.numeric(delta_odds_a),
  p_value = summary(model_a)$coefficients[, 4]
) %>%
  mutate(
    across(where(is.numeric), ~ round(.x, 3))
  )

results_a


install.packages("gt")
library(gt)

table_a <- results_a %>%
  mutate(
    CI = sprintf("[%.3f, %.3f]", CI_lower, CI_upper),
    p_value = summary(model_a)$coefficients[, 4],
    p_value = if_else(p_value < 0.001, "<0.001",
                      sprintf("%.3f", p_value))
  ) %>%
  select(variable, coefficient, CI, odds_ratio,
         odds_change_pct, p_value) %>%
  gt()

table_a





#### CHEMOTHERAPY TREATMENT : 

# POINT B, CHEMO AS SOLO PREDICTOR

model_b <- glm(relapse ~ chemotherapy,
               data = clilog,
               family = binomial(link = "logit"))

summary(model_b)

odds_ratios_b <- exp(coef(model_b))


odds_ratios_b


delta_odds_b <- (odds_ratios_b - 1) * 100  


delta_odds_b



confints_b <- confint.default(model_b)

#creating summary table

results_b <- tibble(
  variable = names(coef(model_b)),
  coefficient = as.numeric(coef(model_b)),
  CI_lower = confints_b[, 1],
  CI_upper = confints_b[, 2],
  odds_ratio = as.numeric(odds_ratios_b),
  odds_change_pct = as.numeric(delta_odds_b),
  p_value = summary(model_b)$coefficients[, 4]
) %>%
  mutate(
    across(where(is.numeric), ~ round(.x, 3))
  )

results_b


table_b <- results_b %>%
  mutate(
    CI = sprintf("[%.3f, %.3f]", CI_lower, CI_upper),
    p_value = summary(model_b)$coefficients[, 4],
    p_value = if_else(p_value < 0.001, "<0.001",
                      sprintf("%.3f", p_value))
  ) %>%
  select(variable, coefficient, CI, odds_ratio,
         odds_change_pct, p_value) %>%
  gt()

table_b



#PART C -> CHEMO AS ANOTHER PREDICTOR


model_c <- glm(relapse ~ chemotherapy +
                 age10 + size_cm + grade + log2_nodes
               + er_status + pr_status + her2_status,
               data = clilog,
               family = binomial(link = "logit"))

summary(model_c)

odds_ratios_c <- exp(coef(model_c))


odds_ratios_c


delta_odds_c <- (odds_ratios_c - 1) * 100  


delta_odds_c



confints_c <- confint.default(model_c)

#creating summary table

results_c <- tibble(
  variable = names(coef(model_c)),
  coefficient = as.numeric(coef(model_c)),
  CI_lower = confints_c[, 1],
  CI_upper = confints_c[, 2],
  odds_ratio = as.numeric(odds_ratios_c),
  odds_change_pct = as.numeric(delta_odds_c),
  p_value = summary(model_c)$coefficients[, 4]
) %>%
  mutate(
    across(where(is.numeric), ~ round(.x, 3))
  )

results_c


table_c <- results_c %>%
  mutate(
    CI = sprintf("[%.3f, %.3f]", CI_lower, CI_upper),
    p_value = summary(model_c)$coefficients[, 4],
    p_value = if_else(p_value < 0.001, "<0.001",
                      sprintf("%.3f", p_value))
  ) %>%
  select(variable, coefficient, CI, odds_ratio,
         odds_change_pct, p_value) %>%
  gt()

table_c













