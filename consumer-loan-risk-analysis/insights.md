# Consumer Loan Delinquency and Roll-rate Analysis

## Scope

This project uses the public Home Credit Default Risk dataset to describe overdue consumer loans, monthly delinquency transitions, and applicant-profile coverage. It uses SQL Server, Power BI, and DAX.

The report has three pages: Portfolio Overview, Roll Rates & Cure, and Applicant Profile. The portfolio and profile pages use each contract's latest observed record and then retain Active contracts. The transition page uses historical consecutive-month observations. These are different analytical populations.

## Key insights

### 1. Most overdue Active loans are in early delinquency

There are **236,149 latest-observed Active contracts**, including **5,894 overdue contracts (2.50%)**. Of the overdue contracts, **4,646 are 1-30 DPD**, representing **78.83%** of overdue contracts. There are **923 contracts at 91+ DPD**, equivalent to **0.39%** of the latest-observed Active sample.

Early delinquency accounts for most overdue cases by count. This makes early-stage follow-up a useful area to investigate, while severe delinquency should remain visible as a separate measure.

### 2. Overdue rates vary by product and acquisition channel

Among loans matched to previous applications, the overdue rate is **2.98% for Consumer loans** and **1.19% for Cash loans**. Channel rates include **3.39% for Stone**, **2.95% for Country-wide**, **1.76% for Regional / Local**, and **1.24% for Credit and cash offices**.

The product and channel charts use matched previous applications, covering **98.96%** of the latest-observed Active sample. The overall portfolio KPIs include unmatched contracts as well.

These differences identify segments for further review. They do not establish that a product or channel causes delinquency. Comparisons should retain loan volumes and match coverage alongside the percentages.

### 3. Later delinquency stages show substantial deterioration or persistence

Among valid next-month observations:

- **61.93%** of 31-60 DPD observations move to 61-90 DPD.
- **89.40%** of 61-90 DPD observations move to 91+ DPD.
- **95.75%** of 91+ DPD observations remain at 91+ DPD.

These transition patterns highlight the importance of monitoring movement between stages, rather than relying only on the latest portfolio overdue rate.

### 4. Next-month cure falls sharply as starting DPD increases

There are **274,968 observed delinquent loan-month pairs**, of which **75,729 return to Active 0 DPD**, giving an overall cure rate of **27.54%**. Separately, **17,913 pairs transition to Completed**, giving a completion rate of **6.51%**.

| Starting DPD | Next-month cure rate | Next-month completion rate |
|---|---:|---:|
| 1-30 DPD | 45.79% | 9.17% |
| 31-60 DPD | 13.48% | 10.23% |
| 61-90 DPD | 3.72% | 5.11% |
| 91+ DPD | 1.89% | 2.26% |

Completed is reported separately from cure. A status transition is not a measure of cash recovered, and pair counts are not unique loan counts. Overall rates use the combined counts, rather than an average of the four group percentages.

### 5. Applicant-profile differences are descriptive and are not uniform

Among contracts matched to current application profiles, overdue rates by income band are:

| Income band in dataset units | Overdue rate |
|---|---:|
| Below 100,000 | 2.84% |
| 100,000 to below 200,000 | 2.49% |
| 200,000 to below 300,000 | 2.30% |
| 300,000 and above | 2.56% |

The rate does not decline consistently across all income bands. Within the 12 largest occupation groups by Active-loan count, rates include **2.95% for Cooking staff**, **2.83% for Core staff**, and **2.72% for Drivers**.

The occupation chart selects groups by loan volume, then orders them by overdue rate. It is not a ranking of all occupations by risk. These associations should not be interpreted as causal effects or used alone to determine individual credit decisions.

### 6. Profile availability is a material part of the analysis

Current application profiles are matched for **203,743 of 236,149 contracts (86.28%)**. The remaining **32,406 contracts (13.72%)** are unmatched.

Among matched profiles, **69,364 contracts have Unknown occupation**, representing **34.04% of matched contracts**. An unmatched profile and a matched profile with an unknown occupation are different data-quality situations and should remain separate.

## Recommendations and measurement

| Focus | Practical next step | What to monitor |
|---|---|---|
| Early delinquency | Evaluate earlier follow-up for 1-30 DPD cases using comparable starting-stage groups. | Cure, completion, movement to a worse DPD group, pair counts, and next-month observation coverage. |
| Product and channel review | Review higher-rate segments using both counts and rates before proposing operational changes. | Overdue counts, overdue rates, 91+ DPD counts, and previous-application match coverage. |
| Profile data quality | Investigate unmatched IDs and unknown occupations separately; retain both categories in reporting. | Profile coverage, unknown occupation rate among matched profiles, and coverage by DPD group. |
| Reporting consistency | Keep latest-observed contract metrics separate from historical loan-month metrics, and keep Completed separate from cure. | Reconciliation to SQL totals, stable denominators, and readable exports showing every intended category. |

These are proposed areas for review or testing. The project does not demonstrate an improvement caused by a collection action or a change in lending policy.

## Definitions and interpretation limits

- **Loan unit:** a previous contract identified by SK_ID_PREV. Contract counts are not unique customer counts. A current application can be associated with more than one previous contract.
- **Overdue:** SK_DPD greater than zero on the latest observed Active record. This is a delinquency measure, not a default or loss rate.
- **Latest observed:** selected separately for each contract across all statuses, before filtering to Active. It is not a common calendar-date snapshot.
- **Observed transition:** the next observation is exactly one month later for the same contract and application ID. Missing observations or month gaps are excluded from rate denominators; they are not treated as cure or completion.
- **Cure:** an Active delinquent observation followed in the next month by Active 0 DPD. Cure and completion rates use observed pairs starting at 1-30 DPD or worse. The transition-matrix denominator also includes observed Completed and Other status destinations.
- **Profile timing:** income and occupation come from current applications and can postdate earlier loan observations. The comparisons are descriptive. Income bands retain dataset units; no VND conversion is assumed.
- **Rounding:** displayed rates have two decimal places. A displayed 0.00% can contain a small positive transition count. A blank matrix cell can reflect a transition combination absent from the aggregated source; it should not be interpreted as a missing next-month observation.
- **Coverage:** product/channel comparisons use matched previous applications, while income/occupation comparisons use matched current application profiles. These two coverage measures have different scopes.

## Evidence

- Consumer_Loan_Risk_Analysis.pdf, pages 1-3: reported KPIs, segment rates, transition matrix, cure/completion charts, and profile-coverage metrics.
- Previously checked SQL result tables: source counts and reconciliation of repeated loan-month observations.
- Public data source: Home Credit Default Risk, https://www.kaggle.com/competitions/home-credit-default-risk/data.
