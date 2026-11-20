-- Banking Campaign Performance
-- SQL Server / Transact-SQL
-- Source: UCI Bank Marketing, bank-additional-full.csv (41,188 records).
-- Import the source CSV into dbo.bank_additional_full before running the analysis.
-- Run with a SQL Server client that supports GO batch separators.

IF DB_ID(N'banking_campaign_project') IS NULL
    EXEC(N'CREATE DATABASE banking_campaign_project;');
GO

USE banking_campaign_project;
GO

-- PROJECT OBJECTIVE
-- Analyze segments, channels, contact intensity, previous outcomes, and economic context
-- to propose experiments for improving term-deposit marketing.

-- UNIT OF ANALYSIS AND KPI DEFINITIONS
-- Each row is a source marketing record; no identifier is available to count unique customers.
-- y=yes/no represents the final subscription outcome for the record.
-- Subscription rate: yes outcomes divided by valid yes/no outcomes in the same sample.
-- campaign is the cumulative number of contacts in the current campaign, not a campaign identifier.
-- SUM(campaign) aggregates contacts recorded in the sample; it is not a complete bank-wide contact log.

SELECT COUNT(*) AS total_records
FROM banking_campaign_project.dbo.bank_additional_full;

SELECT TOP (5) *
FROM banking_campaign_project.dbo.bank_additional_full;

SELECT
    ORDINAL_POSITION AS column_order,
    COLUMN_NAME AS column_name,
    DATA_TYPE AS data_type
FROM banking_campaign_project.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'bank_additional_full'
ORDER BY ORDINAL_POSITION;

SELECT
    COUNT(*) AS total_records,

    SUM(
        CASE WHEN [y] = 'yes' THEN 1 ELSE 0 END
    ) AS subscribed_records,

    SUM(
        CASE
            WHEN [y] IN ('yes', 'no') THEN 0
            ELSE 1
        END
    ) AS invalid_outcome_records,

    CAST(
        100.0
        * SUM(CASE WHEN [y] = 'yes' THEN 1 ELSE 0 END)
        / NULLIF(
            SUM(CASE WHEN [y] IN ('yes', 'no') THEN 1 ELSE 0 END),
            0
        )
        AS decimal(6,2)
    ) AS subscription_rate_pct

FROM banking_campaign_project.dbo.bank_additional_full;

-- QUESTION 1. Contact intensity and subscription rates by occupation and age segment.

WITH full_data AS (
    SELECT [job] AS job,

        TRY_CONVERT(int, [age]) AS age,

        TRY_CONVERT(int, [campaign]) AS contacts,

        CASE
            WHEN [y] = 'yes' THEN 1
            WHEN [y] = 'no' THEN 0
        END AS subscribed

    FROM banking_campaign_project.dbo.bank_additional_full
),

grouped_data AS (
    SELECT
        job,
        contacts,
        subscribed,

        CASE
            WHEN age < 25 THEN 'Under 25'
            WHEN age < 35 THEN '25-34'
            WHEN age < 45 THEN '35-44'
            WHEN age < 55 THEN '45-54'
            WHEN age < 65 THEN '55-64'
            ELSE '65+'
        END AS age_group

    FROM full_data

    WHERE age > 0
      AND contacts >= 1
      AND subscribed IS NOT NULL
),

overall AS (
    SELECT
        AVG(1.0 * contacts) AS overall_avg_contacts,

        AVG(1.0 * subscribed) AS overall_subscription_rate

    FROM grouped_data
),

segments AS (
    SELECT
        job,
        age_group,

        COUNT(*) AS total_records,

        SUM(subscribed) AS subscribed_records,

        AVG(1.0 * contacts) AS avg_contacts,

        AVG(1.0 * subscribed) AS subscription_rate

    FROM grouped_data

    GROUP BY
        job,
        age_group
)

SELECT
    s.job,
    s.age_group,
    s.total_records,
    s.subscribed_records,

    CAST(
        100.0 * s.subscription_rate
        AS decimal(6,2)
    ) AS subscription_rate_pct,

    CAST(
        s.avg_contacts
        AS decimal(6,2)
    ) AS avg_contacts,

    CAST(
        100.0 * o.overall_subscription_rate
        AS decimal(6,2)
    ) AS overall_rate_pct,

    CAST(
        o.overall_avg_contacts
        AS decimal(6,2)
    ) AS overall_avg_contacts,

    CASE
        WHEN s.total_records < 200
            THEN N'Small sample; interpret with caution'

        WHEN s.subscription_rate > o.overall_subscription_rate
         AND s.avg_contacts < o.overall_avg_contacts
            THEN N'High rate, low contact intensity'

        WHEN s.subscription_rate < o.overall_subscription_rate
         AND s.avg_contacts > o.overall_avg_contacts
            THEN N'High contact intensity, low rate'

        ELSE N'Other segments'

    END AS review_group

FROM segments s

CROSS JOIN overall o

ORDER BY
    review_group,
    s.subscription_rate DESC,
    s.total_records DESC;
   
-- QUESTION 2. Channel comparison after standardizing month-by-weekday composition.

WITH full_data AS (
    SELECT
        [month] AS contact_month,
        [day_of_week] AS contact_day,
        [contact] AS contact_type,

        CASE
            WHEN [y] = 'yes' THEN 1
            WHEN [y] = 'no' THEN 0
        END AS subscribed

    FROM banking_campaign_project.dbo.bank_additional_full

    WHERE [y] IN ('yes', 'no')
      AND [contact] IN ('cellular', 'telephone')
      AND [month] IS NOT NULL
      AND [day_of_week] IS NOT NULL
),

time_groups AS (
    SELECT
        contact_month,
        contact_day,

        COUNT(*) AS total_records,

        SUM(
            CASE WHEN contact_type = 'cellular'
                 THEN 1 ELSE 0 END
        ) AS cellular_records,

        SUM(
            CASE WHEN contact_type = 'telephone'
                 THEN 1 ELSE 0 END
        ) AS telephone_records,

        SUM(
            CASE WHEN contact_type = 'cellular'
                 THEN subscribed ELSE 0 END
        ) AS cellular_subscribed,

        SUM(
            CASE WHEN contact_type = 'telephone'
                 THEN subscribed ELSE 0 END
        ) AS telephone_subscribed

    FROM full_data

    GROUP BY
        contact_month,
        contact_day
),

comparable_groups AS (
    SELECT *

    FROM time_groups

    WHERE cellular_records >= 30
      AND telephone_records >= 30
),

results AS (
    SELECT
        COUNT(*) AS included_time_groups,

        SUM(cellular_records) AS cellular_records,
        SUM(telephone_records) AS telephone_records,

        1.0 * SUM(cellular_subscribed)
        / NULLIF(SUM(cellular_records), 0)
            AS cellular_crude_rate,

        1.0 * SUM(telephone_subscribed)
        / NULLIF(SUM(telephone_records), 0)
            AS telephone_crude_rate,

        SUM(
            1.0 * total_records
            * cellular_subscribed
            / NULLIF(cellular_records, 0)
        )
        / NULLIF(SUM(total_records), 0)
            AS cellular_standardized_rate,

        SUM(
            1.0 * total_records
            * telephone_subscribed
            / NULLIF(telephone_records, 0)
        )
        / NULLIF(SUM(total_records), 0)
            AS telephone_standardized_rate

    FROM comparable_groups
)

SELECT
    included_time_groups,
    cellular_records,
    telephone_records,

    CAST(
        100.0 * cellular_records
        / NULLIF(
            (SELECT COUNT(*)
             FROM full_data
             WHERE contact_type = 'cellular'),
            0
        )
        AS decimal(6,2)
    ) AS cellular_coverage_pct,

    CAST(
        100.0 * telephone_records
        / NULLIF(
            (SELECT COUNT(*)
             FROM full_data
             WHERE contact_type = 'telephone'),
            0
        )
        AS decimal(6,2)
    ) AS telephone_coverage_pct,

    CAST(
        100.0 * cellular_crude_rate
        AS decimal(6,2)
    ) AS cellular_crude_rate_pct,

    CAST(
        100.0 * telephone_crude_rate
        AS decimal(6,2)
    ) AS telephone_crude_rate_pct,

    CAST(
        100.0 * (
            cellular_crude_rate - telephone_crude_rate
        )
        AS decimal(6,2)
    ) AS crude_gap_pp,

    CAST(
        100.0 * cellular_standardized_rate
        AS decimal(6,2)
    ) AS cellular_standardized_rate_pct,

    CAST(
        100.0 * telephone_standardized_rate
        AS decimal(6,2)
    ) AS telephone_standardized_rate_pct,

    CAST(
        100.0 * (
            cellular_standardized_rate
            - telephone_standardized_rate
        )
        AS decimal(6,2)
    ) AS standardized_gap_pp

FROM results;

-- QUESTION 3. Hypothetical contact-limit scenarios.
-- These are scenario estimates, not measured outcomes of an implemented policy.
-- The data does not identify the contact at which subscription occurred.
-- Loss shares of 25%, 50%, and 100% are assumptions applied to subscriptions above the limit.

WITH full_data AS (
    SELECT
        TRY_CONVERT(int, [campaign]) AS contacts,

        CASE
            WHEN [y] = 'yes' THEN 1
            WHEN [y] = 'no' THEN 0
        END AS subscribed

    FROM banking_campaign_project.dbo.bank_additional_full
),

valid_data AS (
    SELECT *

    FROM full_data

    WHERE contacts >= 1
      AND subscribed IS NOT NULL
),

call_limits AS (
    SELECT 1 AS max_contacts
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
    UNION ALL SELECT 7
    UNION ALL SELECT 8
    UNION ALL SELECT 9
    UNION ALL SELECT 10
),

scenarios AS (
    SELECT
        l.max_contacts,

        COUNT(*) AS total_records,

        SUM(d.contacts) AS recorded_contacts,

        SUM(
            CASE WHEN d.contacts = l.max_contacts
                 THEN 1 ELSE 0 END
        ) AS records_at_exact_count,

        SUM(
            CASE WHEN d.contacts = l.max_contacts
                 THEN d.subscribed ELSE 0 END
        ) AS subscribed_at_exact_count,

        SUM(
            CASE
                WHEN d.contacts > l.max_contacts
                    THEN d.contacts - l.max_contacts
                ELSE 0
            END
        ) AS contacts_avoided_proxy,

        SUM(
            CASE WHEN d.contacts > l.max_contacts
                 THEN 1 ELSE 0 END
        ) AS records_above_limit,

        SUM(
            CASE WHEN d.contacts > l.max_contacts
                 THEN d.subscribed ELSE 0 END
        ) AS observed_subscribers_above_limit

    FROM valid_data d

    CROSS JOIN call_limits l

    GROUP BY l.max_contacts
),

rates AS (
    SELECT
        *,

        1.0 * subscribed_at_exact_count
        / NULLIF(records_at_exact_count, 0)
            AS exact_count_group_rate

    FROM scenarios
)

SELECT
    max_contacts,

    records_at_exact_count,
    subscribed_at_exact_count,

    CAST(
        100.0 * exact_count_group_rate
        AS decimal(6,2)
    ) AS exact_count_group_rate_pct,

    CAST(
        100.0 * (
            exact_count_group_rate
            - LAG(exact_count_group_rate)
              OVER (ORDER BY max_contacts)
        )
        AS decimal(6,2)
    ) AS rate_change_vs_previous_group_pp,

    recorded_contacts,

    contacts_avoided_proxy,

    CAST(
        100.0 * contacts_avoided_proxy
        / NULLIF(recorded_contacts, 0)
        AS decimal(6,2)
    ) AS contacts_avoided_proxy_pct,

    records_above_limit,

    observed_subscribers_above_limit,

    CAST(
        0.25 * observed_subscribers_above_limit
        AS decimal(12,2)
    ) AS assumed_lost_if_25pct_at_risk,

    CAST(
        0.50 * observed_subscribers_above_limit
        AS decimal(12,2)
    ) AS assumed_lost_if_50pct_at_risk,

    observed_subscribers_above_limit
        AS assumed_lost_if_100pct_at_risk

FROM rates

ORDER BY max_contacts;

-- QUESTION 4. Previous campaign outcomes and contact recency.

WITH full_data AS (
    SELECT
        [poutcome] AS previous_outcome,

        TRY_CONVERT(int, [pdays]) AS pdays,

        TRY_CONVERT(int, [previous]) AS previous_contacts,

        TRY_CONVERT(int, [campaign]) AS current_contacts,

        CASE
            WHEN [y] = 'yes' THEN 1
            WHEN [y] = 'no' THEN 0
        END AS subscribed

    FROM banking_campaign_project.dbo.bank_additional_full
),

grouped_data AS (
    SELECT
        *,

        CASE
            WHEN pdays IS NULL OR pdays < 0
                THEN 'Unknown'

            WHEN pdays = 999
                THEN 'pdays_999'

            WHEN pdays <= 7
                THEN '0-7 days'

            WHEN pdays <= 14
                THEN '8-14 days'

            WHEN pdays <= 30
                THEN '15-30 days'

            ELSE '31+ days'

        END AS recency_group

    FROM full_data

    WHERE subscribed IS NOT NULL
),

overall AS (
    SELECT
        AVG(1.0 * subscribed) AS overall_rate

    FROM grouped_data
),

segments AS (
    SELECT
        previous_outcome,
        recency_group,

        COUNT(*) AS total_records,

        SUM(subscribed) AS subscribed_records,

        AVG(1.0 * subscribed) AS subscription_rate,

        AVG(
            CASE
                WHEN pdays <> 999 AND pdays >= 0
                    THEN 1.0 * pdays
            END
        ) AS avg_valid_pdays,

        AVG(
            1.0 * previous_contacts
        ) AS avg_previous_contacts,

        AVG(
            1.0 * current_contacts
        ) AS avg_current_contacts

    FROM grouped_data

    GROUP BY
        previous_outcome,
        recency_group
)

SELECT
    s.previous_outcome,
    s.recency_group,
    s.total_records,
    s.subscribed_records,

    CAST(
        100.0 * s.subscription_rate
        AS decimal(6,2)
    ) AS subscription_rate_pct,

    CAST(
        s.subscription_rate
        / NULLIF(o.overall_rate, 0)
        AS decimal(8,2)
    ) AS relative_rate_to_overall,

    CAST(
        s.avg_valid_pdays
        AS decimal(8,2)
    ) AS avg_valid_pdays,

    CAST(
        s.avg_previous_contacts
        AS decimal(8,2)
    ) AS avg_previous_contacts,

    CAST(
        s.avg_current_contacts
        AS decimal(8,2)
    ) AS avg_current_contacts,

    CASE
        WHEN s.total_records < 100
            THEN N'Small sample; interpret with caution'

        WHEN s.previous_outcome = 'success'
         AND s.subscription_rate > o.overall_rate
            THEN N'Candidate for a recontact trial'

        ELSE N'Further review needed'

    END AS review_note

FROM segments s

CROSS JOIN overall o

ORDER BY
    s.previous_outcome,
    s.recency_group;

-- QUESTION 5. Contact strategies within economic-context groups.
-- Use emp.var.rate to define employment-variation groups.

-- These are descriptive comparisons; they do not establish causal effects of strategy or economic conditions.

WITH full_data AS (
    SELECT
        [contact] AS contact_type,

        TRY_CONVERT(int, [campaign]) AS contacts,

        TRY_CONVERT(
            decimal(12,4), [euribor3m]
        ) AS euribor,

        TRY_CONVERT(
            decimal(12,4), [emp.var.rate]
        ) AS employment_variation,

        TRY_CONVERT(
            decimal(12,4), [cons.conf.idx]
        ) AS consumer_confidence,
        CASE
            WHEN [y] = 'yes' THEN 1
            WHEN [y] = 'no' THEN 0
        END AS subscribed

    FROM banking_campaign_project.dbo.bank_additional_full
),

grouped_data AS (
    SELECT
        *,

        CASE
            WHEN euribor < 2
                THEN 'Euribor below 2'

            WHEN euribor < 4
                THEN 'Euribor 2 to below 4'

            ELSE 'Euribor 4+'

        END AS interest_regime,

        CASE
            WHEN employment_variation < 0
                THEN 'Employment declining'

            ELSE 'Employment nonnegative'

        END AS employment_regime,

        CASE
            WHEN consumer_confidence < -40
                THEN 'Confidence below -40'

            ELSE 'Confidence -40 or above'

        END AS confidence_regime,

        CASE
            WHEN contacts = 1 THEN '1'
            WHEN contacts <= 3 THEN '2-3'
            WHEN contacts <= 5 THEN '4-5'
            ELSE '6+'
        END AS contact_group

    FROM full_data

    WHERE subscribed IS NOT NULL
      AND contacts >= 1
      AND contact_type IN ('cellular', 'telephone')
      AND euribor IS NOT NULL
      AND employment_variation IS NOT NULL
      AND consumer_confidence IS NOT NULL
),

strategy_groups AS (
    SELECT
        interest_regime,
        employment_regime,
        confidence_regime,
        contact_type,
        contact_group,

        COUNT(*) AS total_records,

        SUM(subscribed) AS subscribed_records,

        AVG(1.0 * contacts) AS avg_contacts,

        AVG(euribor) AS avg_euribor,

        AVG(
            employment_variation
        ) AS avg_employment_variation,

        AVG(
            consumer_confidence
        ) AS avg_consumer_confidence

    FROM grouped_data

    GROUP BY
        interest_regime,
        employment_regime,
        confidence_regime,
        contact_type,
        contact_group
),

economic_totals AS (
    SELECT
        *,

        SUM(total_records) OVER (
            PARTITION BY
                interest_regime,
                employment_regime,
                confidence_regime
        ) AS economic_group_records,

        SUM(subscribed_records) OVER (
            PARTITION BY
                interest_regime,
                employment_regime,
                confidence_regime
        ) AS economic_group_subscribed

    FROM strategy_groups
)

SELECT
    interest_regime,
    employment_regime,
    confidence_regime,
    contact_type,
    contact_group,

    total_records,
    subscribed_records,

    CAST(
        100.0 * subscribed_records
        / NULLIF(total_records, 0)
        AS decimal(6,2)
    ) AS strategy_group_rate_pct,

    economic_group_records,

    CAST(
        100.0 * economic_group_subscribed
        / NULLIF(economic_group_records, 0)
        AS decimal(6,2)
    ) AS economic_group_rate_pct,

    CAST(
        100.0 * (
            1.0 * subscribed_records
            / NULLIF(total_records, 0)

            - 1.0 * economic_group_subscribed
            / NULLIF(economic_group_records, 0)
        )
        AS decimal(6,2)
    ) AS gap_to_same_economy_pp,

    CAST(
        avg_contacts AS decimal(8,2)
    ) AS avg_contacts,

    CAST(
        avg_euribor AS decimal(8,3)
    ) AS avg_euribor,

    CAST(
        avg_employment_variation AS decimal(8,3)
    ) AS avg_employment_variation,

    CAST(
        avg_consumer_confidence AS decimal(8,3)
    ) AS avg_consumer_confidence,
    CASE
        WHEN total_records < 100
            THEN N'Small sample; interpret with caution'

        ELSE N'Compare within the same context'

    END AS review_note

FROM economic_totals

ORDER BY
    interest_regime,
    employment_regime,
    confidence_regime,
    contact_type,
    contact_group;
