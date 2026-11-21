# Data Analytics Portfolio — BichTra10

I am an Accounting and Finance graduate with banking experience, developing practical skills in data analysis and business intelligence.

This portfolio showcases projects that use data to explore business questions and communicate findings.

## Technical Skills

- SQL Server
- Power BI and DAX
- Excel

## Areas of Interest

Data analytics and business intelligence, with a focus on banking, finance, and business operations.

## Featured Project

### Banking Campaign Performance

**Tools:** SQL Server, Power BI, DAX

Analyzed 41,188 bank marketing records to explore customer segments, contact channels, contact intensity, previous campaign outcomes, and economic context.

The project includes SQL queries, a three-page dashboard, a PDF report, and detailed insights and recommendations.

[View project, dashboard, and analysis](./banking-campaign-performance/)

### Consumer Loan Delinquency & Roll-rate Analysis

**Domain:** Consumer Lending and Credit Risk Analytics  
**Tools:** SQL Server, DBeaver, Power BI, DAX  
**Dataset:** Home Credit Default Risk — Kaggle

A descriptive analytics project exploring consumer-loan delinquency
using more than **10 million monthly loan observations**. The analysis
examines overdue contracts, differences across products and acquisition
channels, monthly DPD transitions, cure rates, and applicant-profile
coverage.

DPD stands for **days past due**.

#### Project Objectives

- Describe the delinquency profile of latest-observed Active contracts.
- Compare overdue rates across products and acquisition channels.
- Examine how contracts move between DPD groups in consecutive months.
- Measure next-month cure and completion rates separately.
- Explore income and occupation patterns while assessing profile-data coverage.

#### My Work

- Prepared and validated **10,001,358 monthly POS/Cash loan observations**,
  checking numeric conversions, missing values, and contract-month duplicates.
- Used SQL window functions, including **ROW_NUMBER** and **LEAD**,
  to identify each contract's latest observation and construct
  consecutive-month transitions.
- Joined loan observations with previous-application attributes and
  current application profiles, retaining unmatched cases in coverage checks.
- Created DAX measures with explicit filter context to maintain
  consistent denominators across portfolio, transition, and profile analyses.
- Developed a **three-page Power BI report** with KPI cards,
  a transition matrix, segment comparisons, and coverage indicators.

#### Dashboard Pages

1. **Portfolio Overview**  
   Latest-observed Active contracts, overdue and 91+ DPD counts,
   and overdue-rate comparisons by product and channel.

2. **Roll Rates & Cure**  
   Consecutive-month DPD transitions, cure rates, and completion rates
   from delinquent starting states.

3. **Applicant Profile**  
   Overdue rates by income band and occupation, profile-match coverage,
   and the proportion of unknown occupations.

#### Selected Findings

- Among **236,149 latest-observed Active contracts**, **5,894 were overdue**,
  giving an overdue rate of **2.50%**. There were **923 contracts at 91+ DPD**.
- Among contracts matched to previous applications, overdue rates were
  **2.98% for Consumer loans** and **1.19% for Cash loans**.
- Across **274,968 observed delinquent loan-month pairs**, the next-month
  cure rate was **27.54%**. Cure rates ranged from **45.79% at 1–30 DPD**
  to **1.89% at 91+ DPD**.
- Current application profiles were available for **86.28% of Active contracts**.
  Occupation was unknown for **34.04% of those matched contracts**.

#### Analytical Scope

Contract counts represent loans rather than unique customers.
Historical loan-month pairs can include the same contract multiple times.
Completed is reported separately from cure, and current applicant
attributes are used for descriptive comparisons.

**Skills demonstrated:** Data cleaning, SQL validation, joins,
window functions, aggregation, DAX filter context, dashboard design,
and business interpretation.

**Project materials:** SQL analysis, Power BI report, PDF dashboard,
transition-result data, and written insights and recommendations.

[View Project](./consumer-loan-risk-analysis/) |
[Dashboard PDF](./consumer-loan-risk-analysis/Consumer_Loan_Risk_Analysis.pdf) |
[Power BI Report](./consumer-loan-risk-analysis/Consumer_Loan_Risk_Analysis.pbix) |
[SQL Analysis](./consumer-loan-risk-analysis/analysis.sql) |
[Key Insights](./consumer-loan-risk-analysis/insights.md)

## Certificates and SQL Practice

- [SQL Certificates](./certificates/) — Basic, Intermediate, and Advanced certificates.
- [SQL Practice](./sql-practice/) — SQL exercises and practice queries.
