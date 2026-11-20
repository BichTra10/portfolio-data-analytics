# Banking Campaign Performance

**SQL Server | Power BI | DAX**

## Project Overview

This project analyzes bank marketing records to identify promising customer segments, compare contact channels, and explore contact intensity, previous campaign outcomes, and economic context.

The analysis uses the UCI Bank Marketing dataset from a Portuguese banking institution, covering 2008–2010.

## Business Questions

1. Which occupation and age groups show higher subscription rates with lower contact intensity?
2. Does the subscription rate gap between cellular and telephone persist after adjusting for month and weekday composition?
3. How does subscription rate vary across recorded contact counts, and what trade-offs appear in hypothetical contact-limit scenarios?
4. How are previous campaign outcomes and contact recency associated with current subscriptions?
5. How do channel and contact-intensity results compare within the same economic context?

## Overall Results

| Metric | Value |
|---|---:|
| Marketing records | 41,188 |
| Subscribed records | 4,640 |
| Subscription rate | 11.27% |
| Average contacts per record | 2.57 |
| Recorded contacts per subscription | 22.79 |

Recorded contacts per subscription is calculated as total recorded contacts divided by subscribed records. It is a portfolio-level ratio, rather than the average contact count among subscribed records.

## Dashboard Pages

| Page | Focus |
|---|---|
| Campaign Overview | Overall KPIs, occupation and age segments, and contact intensity |
| Channel & Contact Strategy | Channel comparison, time standardization, and contact-limit scenarios |
| History & Economic Context | Previous outcomes, contact recency, and within-context comparisons |

## Key Findings

### 1. Customer Segments

The retired 65+ segment recorded a 47.14% subscription rate with 1.97 average contacts across 560 records.

Students under 25 recorded a 37.83% subscription rate with 1.89 average contacts across 378 records.

These segments are candidates for prioritization trials, subject to validation in a new campaign.

### 2. Contact Channels

Across 33 comparable month-by-weekday groups, the cellular-minus-telephone subscription rate gap changed from 7.98 percentage points before standardization to 7.95 percentage points afterward.

Adjusting for this time composition left most of the observed gap unchanged.

### 3. Contact Intensity

Subscription rates generally declined across groups with higher recorded contact counts, with some fluctuations.

A hypothetical three-contact limit produced a proxy of 28,044 avoided contacts. Assuming a 25% loss among subscriptions observed above that limit produced an estimated loss of 138.75 subscriptions.

These figures are scenario estimates, rather than measured operational outcomes.

### 4. Previous Campaign Outcomes

Records with a successful previous campaign outcome showed a 65.11% current subscription rate, equivalent to 5.78 times the overall rate.

Previous success is therefore a useful characteristic to examine in recontact prioritization trials.

### 5. Economic Context

In the context of Euribor at least 4, nonnegative employment variation, and consumer confidence at least -40, cellular records with two to three contacts achieved a 5.94% subscription rate.

This was 1.99 percentage points above the 3.95% rate for the same economic context.

## Methods

- Data quality checks and KPI validation.
- Occupation and age segmentation.
- Channel standardization using common month-by-weekday weights.
- Parameter-based contact-limit scenarios.
- Previous-outcome and recency comparisons.
- Channel and contact-count comparisons within economic groups.

## Limitations

- The unit of analysis is a marketing record. Unique customers cannot be confirmed without customer identifiers.
- Observed associations do not establish causality.
- The dataset does not provide subscription outcomes after each individual call.
- Contact-limit results depend on proxies and explicit loss assumptions.
- Economic bins and sample-size thresholds are exploratory conventions.
- Historical findings require further validation before operational use.

## Data Source

[UCI Machine Learning Repository — Bank Marketing](https://archive.ics.uci.edu/dataset/222/bank+marketing)

Dataset version: bank-additional-full.csv, containing 41,188 records.
