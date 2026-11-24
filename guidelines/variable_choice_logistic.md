# for relapse logistic



# variables to include for sure
  - age
  - tumor_size
  - lymph_nodes (or grade)
  - laterality
  - er_status/er_ihc
  - pr_status (even tho correlated with above)
  - her2_status
  - mutation_count
  - -






# variables to drop for sure
  - patientid (identifier)
  - menopause (deterministic function of age)
  - cohort ( constant/grouping, not a patient attribute)
  - npi (deterministric function.....)
  - cellurarity
  - tmb (deterministic function)
  - chemotherapy/surgery/radiotherapy/hormone_therapy (happen after relapse)
  - os_months/death/vital_status (happen after relapse)
  - rfs_months (information leakage)




#we dont know yet
  - tumor_stage
    -grade\
    - intclust (do we remove grouping
   
# specified in another point (question 1b 1c)
- chemotherapy


  
