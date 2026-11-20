# Banking Campaign Performance
## Detailed Insights and Recommendations

## 1. Project Context

This project explores subscription outcomes in a historical term-deposit marketing dataset from a Portuguese banking institution. The goal is to identify useful segmentation and contact-strategy hypotheses for future testing.

The source is UCI Bank Marketing, specifically bank-additional-full.csv, with 41,188 records covering 2008-2010.

The unit of analysis is a marketing record. Unique customers cannot be confirmed because no customer identifier is available.

| Overall metric | Value |
|---|---:|
| Marketing records | 41,188 |
| Subscribed records | 4,640 |
| Subscription rate | 11.27% |
| Total recorded contacts | 105,754 |
| Average contacts per record | 2.57 |
| Recorded contacts per subscription | 22.79 |

Recorded contacts per subscription is total recorded contacts divided by subscribed records. It is a portfolio-level resource-intensity ratio, not the average contact count among subscribed records.

## 2. Question 1: Occupation and Age Segments

**Question:** Which occupation and age groups show higher subscription rates with lower contact intensity?

### Findings

Selected segments illustrate the differences from the overall subscription rate of 11.27% and average contact count of 2.57.

| Occupation | Age group | Records | Subscribed | Subscription rate | Average contacts |
|---|---|---:|---:|---:|---:|
| retired | 65+ | 560 | 264 | 47.14% | 1.97 |
| student | Under 25 | 378 | 143 | 37.83% | 1.89 |
| admin. | 55-64 | 633 | 108 | 17.06% | 2.49 |
| admin. | 35-44 | 3,433 | 360 | 10.49% | 2.77 |
| blue-collar | 45-54 | 2,225 | 147 | 6.61% | 2.58 |

These are illustrative segments rather than an exhaustive ranking. Each listed segment has at least 200 records.

Retired people aged 65+ and students under 25 stand out for their higher observed subscription rates and lower average contact counts. Admin. records aged 55-64 also outperform the overall reference on both measures.

In contrast, admin. records aged 35-44 show more contacts and a lower subscription rate than the overall sample. Blue-collar records aged 45-54 have a lower rate, while their average contact count is only slightly above the overall reference.

### Recommendation

Include the three higher-rate, lower-intensity segments in a prioritization trial. For lower-rate segments, review messaging, contact timing, and follow-up rules before increasing the number of contacts.

These findings support testable targeting hypotheses. Differences in needs, previous outcomes, and economic context may also contribute to the observed results.

## 3. Question 2: Contact Channels and Time Composition

**Question:** Does the cellular-minus-telephone rate gap persist after adjusting for month and weekday composition?

### Method

The comparison retains month-by-weekday groups with at least 30 records for each channel. This produces 33 eligible groups containing 39,475 records, or 95.84% of the full sample.

Within those groups, channel rates are standardized using the same weights, based on the pooled record count of both channels in each time group.

### Findings

| Channel | Comparable records | Within-channel coverage | Crude rate | Standardized rate |
|---|---:|---:|---:|---:|
| cellular | 24,664 | 94.34% | 12.78% | 15.95% |
| telephone | 14,811 | 98.45% | 4.80% | 8.00% |

The cellular-minus-telephone gap changes from 7.98 percentage points before standardization to 7.95 percentage points afterward, a reduction of approximately 0.03 percentage points.

Adjusting for this time composition leaves most of the observed gap unchanged. Month-by-weekday composition therefore does not explain most of the gap under this comparison.

### Recommendation

Consider cellular as a candidate priority channel in a limited trial. Compare similar customer segments over comparable time groups, and monitor both subscription rate and recorded contacts per subscription.

This adjustment only addresses month-by-weekday composition. Differences in customer characteristics, previous contact history, or economic conditions may remain. The result does not establish a causal channel effect.

## 4. Question 3: Contact Counts and Contact-Limit Scenarios

**Question:** How does subscription rate vary across recorded contact counts, and what trade-offs appear under hypothetical limits?

### Observed pattern

| Recorded contacts | Records | Subscribed | Subscription rate |
|---:|---:|---:|---:|
| 1 | 17,642 | 2,300 | 13.04% |
| 3 | 5,341 | 574 | 10.75% |
| 5 | 1,599 | 120 | 7.50% |
| 10 | 225 | 12 | 5.33% |

Subscription rates generally decline across groups with higher recorded contact counts, although some contact-count groups fluctuate.

These are comparisons between groups of records. The dataset does not report subscription outcomes after each individual call, so it cannot identify the incremental effect of the third, fourth, or any subsequent contact.

### Scenario results

The avoided-contact proxy sums max(campaign - contact limit, 0) across eligible records. Assumed subscription losses apply a selected loss share to subscribed records observed above the contact limit.

| Hypothetical limit | Avoided contacts: proxy | Share of recorded contacts | Subscribed records above limit | Assumed lost subscriptions at 25% |
|---:|---:|---:|---:|---:|
| 3 contacts | 28,044 | 26.52% | 555 | 138.75 |
| 5 contacts | 15,425 | 14.59% | 186 | 46.50 |

For a three-contact limit, the avoided-contact proxy equals 26.52% of total recorded contacts. There are 555 subscribed records above that limit, but the contact at which those subscriptions occurred is unknown. Applying an assumed loss share of 25% gives an estimate of 138.75.

Fractional loss estimates represent expected values under the chosen assumption. These figures are not measured savings or subscription losses from an implemented policy.

### Recommendation

Compare three- and five-contact limits in a controlled operational trial, with segment-specific follow-up rules. Monitor actual contacts, actual subscriptions, subscription rate, and recorded contacts per subscription.

Call-level outcomes and subscription timing are needed before selecting a suitable limit. The current analysis does not establish that three contacts is optimal.

## 5. Question 4: Previous Campaign Outcomes and Recency

**Question:** Are previous outcomes and contact recency useful characteristics for recontact prioritization?

### Findings

| Previous outcome | Records | Current subscribed records | Current subscription rate | Lift vs. overall rate |
|---|---:|---:|---:|---:|
| success | 1,373 | 894 | 65.11% | 5.78 |
| failure | 4,252 | 605 | 14.23% | 1.26 |
| nonexistent | 35,563 | 3,141 | 8.83% | 0.78 |

Records with previous success have a 65.11% current subscription rate, equivalent to 5.78 times the overall rate of 11.27%.

Within the previous-success group, records with pdays between 0 and 7 total 1,127 records, with a 66.46% subscription rate.

Previous success is a useful characteristic to investigate in recontact trials. Existing demand and the bank's selection of whom to contact may also contribute to this association.

### Handling pdays

There are 1,515 records with valid, nonnegative pdays values other than 999. Their average is 6.01 days.

The special value pdays = 999 is retained as a separate category and excluded from the average-day calculation. Both poutcome and pdays should be considered together: 4,110 records in the failure group also contain pdays = 999.

### Recommendation

Prioritize the previous-success group for a recontact trial and track outcomes jointly by previous outcome and recency group.

The 0-7 day group should be investigated further before adopting it as a fixed recontact schedule. These grouped historical results do not identify an optimal waiting period.

## 6. Question 5: Strategies Within Economic Context

**Question:** How do channels and contact-count groups compare within the same economic context?

### Method

Economic groups use three exploratory dimensions:

- Three-month Euribor: below 2; 2 to below 4; 4 or above.
- Employment variation: negative; nonnegative.
- Consumer confidence: below -40; -40 or above.

Each economic group is then broken down by channel and contact count: 1, 2-3, 4-5, or 6+.

The same-context reference preserves the economic-group filters while removing channel, campaign-count, and contact-group filters. Other active filters, if any, remain in place.

### Example findings

In the group with Euribor at least 4, nonnegative employment variation, and consumer confidence at least -40, there are 12,938 records with a pooled subscription rate of 3.95%.

| Group within this context | Records | Subscription rate | Context reference | Gap |
|---|---:|---:|---:|---:|
| cellular: all contact-count groups | 5,028 | 5.15% | 3.95% | +1.20 pp |
| telephone: all contact-count groups | 7,910 | 3.19% | 3.95% | -0.76 pp |
| cellular: 2-3 contacts | 1,901 | 5.94% | 3.95% | +1.99 pp |

The cellular 2-3 contact group is a subset of the cellular row. The three rows should not be added together.

A group can have a rate below the overall dataset rate of 11.27% while still outperforming its own economic-context reference. This illustrates why the context reference is useful when comparing strategies descriptively.

The Euribor 2-to-below-4 group has only 14 records across the full dataset. Recommendations based on that group require particular caution.

### Recommendation

Review channel and contact-intensity results against their own economic-context reference, alongside sample size and contact intensity.

The bins are project conventions rather than validated economic thresholds. These comparisons do not isolate the individual causal effects of interest rates, employment, confidence, or contact strategy.

## 7. Suggested Priorities and Measurement

| Proposed trial | Analytical basis | Measures to track |
|---|---|---|
| Segment prioritization | Selected occupation-age groups show higher rates and lower contact intensity | Records, subscriptions, subscription rate, average contacts |
| Cellular prioritization | The channel gap persists after time-composition standardization | Rates and contacts per subscription in comparable groups |
| Three- vs. five-contact limits | Scenarios illustrate a resource/subscription trade-off | Actual contacts, actual subscriptions, call-level outcomes |
| Previous-success recontact | Previous success is associated with a 65.11% current rate | Rates and record counts by previous outcome and recency |
| Context-aware monitoring | Strategies can differ relative to their local reference rate | Group rate, context rate, gap in percentage points, sample size |

These are proposed trials. The project has not measured a production increase in subscriptions or a realized cost saving.

## 8. Limitations

1. Historical data from one Portuguese institution may not generalize to a current market or product.
2. Marketing records cannot be treated as confirmed unique customers. Twelve fully identical extra rows are retained because there is insufficient evidence to identify them as import errors.
3. Campaign counts are cumulative record-level counts rather than a call-by-call event log.
4. Contact-limit scenarios use proxies and assumed subscription losses.
5. Time standardization and economic grouping address the stated comparison dimensions; they do not establish causality.
6. The thresholds of 200 records for the segment scatter, 30 records per channel per time group, and 100 records for economic-group sample-size cautions are descriptive project conventions, not statistical significance tests.
7. Full calendar dates are unavailable at the record level, limiting annual time-series, cohort, and detailed scheduling analyses.
8. Call duration is only known after the call and is not used as a pre-call targeting signal in these recommendations.

## 9. Data and Project References

- [UCI Bank Marketing](https://archive.ics.uci.edu/dataset/222/bank+marketing)
- Source dataset: bank-additional-full.csv, 41,188 records.
- [SQL analysis](analysis.sql)
- [Dashboard PDF](Banking_Campaign_Performance.pdf)
- [Power BI dashboard](Banking_Campaign_Performance.pbix)
- [Project overview](README.md)

Figures were recomputed from the source data and reconciled with the checked SQL results and dashboard KPIs. The PDF provides an overview; detailed Matrix rows may extend beyond the visible scroll area.

