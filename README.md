# Nguyễn Bích Trà | Data Analytics Portfolio

**Accounting & Finance Graduate · Banking Experience · Aspiring Data Analyst**

Welcome to my portfolio. I am an **Accounting and Finance graduate
from the International School, Vietnam National University, Hanoi**,
pursuing opportunities in **Data Analytics and Business Intelligence**.

My professional background includes an **internship at MB Bank
(Military Commercial Joint Stock Bank)** and **one year of experience
as a Personal Banking Officer at TPBank (Tien Phong Commercial
Joint Stock Bank)**.

Working in banking has given me practical exposure to customer needs,
financial products, sales activities, and performance targets.
I am building on this experience with **SQL, Power BI, DAX, and Excel**
to investigate business questions, develop clear dashboards,
and communicate findings with appropriate context.

## What I Bring to Data Analytics

- **Accounting and finance foundation:** An academic background that
  helps me interpret financial information, understand business
  performance, and pay attention to consistency in reported figures.

- **Practical banking knowledge:** Experience that helps me connect
  analytical questions with retail banking activities, customer
  acquisition, product needs, and commercial priorities.

- **Customer perspective:** Direct customer-facing experience that
  encourages me to consider the needs and circumstances behind
  the numbers when interpreting customer segments.

- **Clear communication:** Experience explaining financial products
  and working toward business targets, which I apply when presenting
  analytical findings and recommendations.

- **Attention to data quality:** A focus on checking figures,
  defining meaningful denominators, and distinguishing observed
  patterns from assumptions before drawing conclusions.

## Technical Skills

| Area | Skills |
|---|---|
| SQL Server | Data validation, joins, CTEs, aggregations, and window functions |
| Power BI | Power Query, data modeling, interactive dashboards, and report formatting |
| DAX | KPI measures, filter context, comparison baselines, and rate calculations |
| Excel | Data preparation, checking, and summary analysis |
| Analytical communication | Business questions, KPI definitions, written insights, and recommendations |

## Portfolio Focus

My projects follow a practical workflow:
**define the business question → validate the data → analyze with SQL
→ visualize in Power BI → explain findings and limitations**.

## Career Interests

I am seeking **Data Analyst Intern and entry-level analytics
opportunities**, particularly in **banking, financial services,
and business operations**.

I aim to contribute practical business understanding, careful analysis,
and clear communication while continuing to develop my technical skills.

## Featured Project

### Banking Campaign Performance & Contact Strategy

**Domain:** Banking, Marketing Analytics, and Customer Segmentation  
**Tools:** SQL Server, DBeaver, Power BI, DAX  
**Dataset:** UCI Bank Marketing — `bank-additional-full.csv`

A descriptive analytics project examining **41,188 term-deposit marketing
records** from a Portuguese banking institution. The project explores
subscription outcomes, customer segments, contact channels, contact
intensity, previous campaign history, and economic context.

The analysis combines SQL investigation with a **three-page interactive
Power BI report** to identify practical hypotheses for improving
targeting and contact strategies.

#### Project Objectives

- Establish clear performance indicators for term-deposit marketing.
- Identify occupation and age groups with higher subscription rates
  and lower average contact intensity.
- Compare cellular and telephone outcomes after adjusting for
  differences in month and weekday composition.
- Explore contact-count patterns and the trade-offs associated with
  hypothetical contact limits.
- Examine previous campaign outcomes, contact recency, and economic
  conditions to support more informed campaign reviews.

#### My Work

- Imported the source data into SQL Server and checked record counts,
  outcome values, numeric conversions, and special-value handling.
- Preserved unknown categories and treated `pdays = 999` separately
  when analyzing contact recency.
- Used SQL CTEs, conditional logic, aggregations, and window functions
  to investigate five business questions.
- Compared channels within common month-by-weekday groups using
  consistent weights and explicit coverage checks.
- Built contact-limit scenarios to illustrate potential changes in
  contact effort under stated assumptions.
- Created DAX measures for subscription rates, contact intensity,
  comparison baselines, rate gaps, and scenario indicators.
- Developed interactive Power BI visuals and reconciled the main
  dashboard indicators with SQL results.
- Documented findings, interpretation limits, and proposed follow-up
  tests in a separate insights report.

#### Dashboard Pages

1. **Campaign Overview**  
   Overall performance indicators, occupation-by-age segment results,
   and a comparison of contact intensity against subscription rate.

2. **Channel & Contact Strategy**  
   Crude and standardized channel comparisons, subscription rates by
   recorded contact count, and interactive contact-limit scenarios.

3. **History & Economic Context**  
   Previous campaign outcomes, contact-recency groups, and channel
   comparisons against reference rates within the same economic context.

#### Selected Findings

- **Overall performance:** The dataset contains **4,640 subscribed
  records**, representing an overall subscription rate of **11.27%**.
  Average contact intensity was **2.57 contacts per record**.

- **Segment differences:** Retired people aged **65+** had a subscription
  rate of **47.14% across 560 records**, with **1.97 average contacts**.
  Students under 25 recorded **37.83% across 378 records**, with
  **1.89 average contacts**.

- **Channel comparison:** Across **33 comparable month-by-weekday
  groups**, standardized subscription rates were **15.95% for cellular**
  and **8.00% for telephone**. The adjusted gap was **7.95 percentage
  points**, indicating that the examined time composition explained
  little of the observed channel difference.

- **Contact-limit scenario:** A hypothetical three-contact limit
  produced an avoided-contact proxy of **28,044 contacts**, equivalent
  to **26.52% of recorded contacts**. There were **555 subscribed
  records above the limit**; the dataset does not identify when
  those subscriptions occurred.

- **Previous campaign history:** Records with a previous successful
  outcome had a current subscription rate of **65.11% across
  1,373 records**, approximately **5.78 times the overall rate**.

#### Business Recommendations

- Test segment prioritization using both subscription rate and
  contact intensity, alongside the number of eligible records.
- Evaluate channel choices within comparable customer groups and
  time periods.
- Compare alternative contact limits through a prospective trial,
  measuring actual subscriptions and contact effort.
- Investigate previous-success groups as candidates for recontact.
- Review campaign results against their economic-context reference
  before drawing conclusions from the overall average.

#### Analytical Scope

The unit of analysis is a **marketing record**. Unique customers
cannot be confirmed because the dataset does not provide a customer
identifier.

Contact counts are cumulative, and individual call outcomes and
subscription timing are unavailable. Channel and segment differences
are observational associations.

Contact-limit results are scenario estimates. Recommendations are
proposals for further testing; the project does not claim realized
cost savings or a measured increase in subscriptions.

#### Skills Demonstrated

Data validation, SQL analysis, customer segmentation, window functions,
weighted comparisons, scenario analysis, DAX filter context,
interactive dashboard design, and business communication.

**Project materials:** SQL analysis, Power BI report, three-page PDF
dashboard, dashboard screenshots, and detailed insights and recommendations.

[View Project and Supporting Files](./banking-campaign-performance/)

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
