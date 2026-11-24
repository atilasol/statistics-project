# for relapse logistic



# variables to include for sure
  - age
  - tumor_size
  - lymph_nodes
  - grade
  - er_status
  - pr_status
  - her2_status
  - mutation_count (not leakage/nor deterministic)
  - 
  - -






# variables to drop for sure
  - patientid (identifier)
  - menopause (deterministic function of age)
  - cohort (grouping, not a patient attribute)
  - npi (deterministric function.....)
  - cellularity (no plausible link to relapse (measures quality of sample not related to patient)
  - er_ihc (measure same thing as er_status, near duplicate)
  - tmb (deterministic function)
  - chemotherapy/surgery/radiotherapy/hormone_therapy (information leakage)
  - os_months/death/vital_status (information leakage)
  - rfs_months (information leakage)
  - laterality (no feasible link)
  - -tumor_stage (near duplicate to grade)
  - inclust (whatever mr claude says)



   
# specified in another point (question 1b 1c)
- chemotherapy


  
