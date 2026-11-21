IF DB_ID(N'consumer_loan_risk') IS NULL
    CREATE DATABASE consumer_loan_risk;
GO

USE consumer_loan_risk;
GO

SELECT DB_NAME() AS CurrentDatabase;

CREATE TABLE consumer_loan_risk.dbo.pos_cash_balance (
    SK_ID_PREV              INT NULL,
    SK_ID_CURR              INT NULL,
    MONTHS_BALANCE          INT NULL,
    CNT_INSTALMENT          DECIMAL(12,2) NULL,
    CNT_INSTALMENT_FUTURE   DECIMAL(12,2) NULL,
    NAME_CONTRACT_STATUS   NVARCHAR(50) NULL,
    SK_DPD                 INT NULL,
    SK_DPD_DEF             INT NULL
);

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH AS TextLength,
    NUMERIC_PRECISION AS NumericPrecision,
    NUMERIC_SCALE AS NumericScale
FROM consumer_loan_risk.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'pos_cash_balance'
ORDER BY ORDINAL_POSITION;

SELECT
    COUNT_BIG(*) AS TotalRows,
    COUNT_BIG(SK_ID_PREV) AS RowsWithLoanID
FROM consumer_loan_risk.dbo.pos_cash_balance;

EXEC consumer_loan_risk.sys.sp_rename
    @objname = N'dbo.pos_cash_balance',
    @newname = N'pos_cash_balance_import_backup',
    @objtype = N'OBJECT';

CREATE TABLE consumer_loan_risk.dbo.pos_cash_balance_raw (
    SK_ID_PREV              NVARCHAR(100) NULL,
    SK_ID_CURR              NVARCHAR(100) NULL,
    MONTHS_BALANCE          NVARCHAR(100) NULL,
    CNT_INSTALMENT          NVARCHAR(100) NULL,
    CNT_INSTALMENT_FUTURE   NVARCHAR(100) NULL,
    NAME_CONTRACT_STATUS   NVARCHAR(100) NULL,
    SK_DPD                 NVARCHAR(100) NULL,
    SK_DPD_DEF             NVARCHAR(100) NULL
);

SELECT
    COUNT_BIG(*) AS TotalRows,
    COUNT_BIG(
        TRY_CONVERT(
            INT,
            NULLIF(LTRIM(RTRIM(SK_ID_PREV)), N'')
        )
    ) AS RowsWithValidLoanID
FROM consumer_loan_risk.dbo.pos_cash_balance_raw;

WITH checked AS (
    SELECT
        NULLIF(LTRIM(RTRIM(CNT_INSTALMENT)), N'')
            AS Instalment,
        NULLIF(LTRIM(RTRIM(CNT_INSTALMENT_FUTURE)), N'')
            AS FutureInstalment
    FROM consumer_loan_risk.dbo.pos_cash_balance_raw
)
SELECT
    COUNT_BIG(CASE
        WHEN Instalment IS NULL THEN 1
    END) AS MissingInstalment,

    COUNT_BIG(CASE
        WHEN FutureInstalment IS NULL THEN 1
    END) AS MissingFutureInstalment,

    COUNT_BIG(CASE
        WHEN Instalment IS NOT NULL
         AND TRY_CONVERT(DECIMAL(12,2), Instalment) IS NULL
        THEN 1
    END) AS InvalidInstalment,

    COUNT_BIG(CASE
        WHEN FutureInstalment IS NOT NULL
         AND TRY_CONVERT(DECIMAL(12,2), FutureInstalment) IS NULL
        THEN 1
    END) AS InvalidFutureInstalment
FROM checked;

SELECT
    TRY_CONVERT(INT,
        NULLIF(LTRIM(RTRIM(SK_ID_PREV)), N''))
        AS SK_ID_PREV,

    TRY_CONVERT(INT,
        NULLIF(LTRIM(RTRIM(SK_ID_CURR)), N''))
        AS SK_ID_CURR,

    TRY_CONVERT(INT,
        NULLIF(LTRIM(RTRIM(MONTHS_BALANCE)), N''))
        AS MONTHS_BALANCE,

    TRY_CONVERT(DECIMAL(12,2),
        NULLIF(LTRIM(RTRIM(CNT_INSTALMENT)), N''))
        AS CNT_INSTALMENT,

    TRY_CONVERT(DECIMAL(12,2),
        NULLIF(LTRIM(RTRIM(CNT_INSTALMENT_FUTURE)), N''))
        AS CNT_INSTALMENT_FUTURE,

    NULLIF(LTRIM(RTRIM(NAME_CONTRACT_STATUS)), N'')
        AS NAME_CONTRACT_STATUS,

    TRY_CONVERT(INT,
        NULLIF(LTRIM(RTRIM(SK_DPD)), N''))
        AS SK_DPD,

    TRY_CONVERT(INT,
        NULLIF(LTRIM(RTRIM(SK_DPD_DEF)), N''))
        AS SK_DPD_DEF

INTO consumer_loan_risk.dbo.pos_cash_balance
FROM consumer_loan_risk.dbo.pos_cash_balance_raw;

SELECT
    COUNT_BIG(*) AS TotalRows,

    COUNT_BIG(CASE
        WHEN SK_ID_CURR IS NULL THEN 1
    END) AS MissingClientID,

    COUNT_BIG(CASE
        WHEN MONTHS_BALANCE IS NULL THEN 1
    END) AS MissingMonth,

    COUNT_BIG(CASE
        WHEN SK_DPD IS NULL THEN 1
    END) AS MissingDPD,

    COUNT_BIG(CASE
        WHEN SK_DPD_DEF IS NULL THEN 1
    END) AS MissingDPDDef

FROM consumer_loan_risk.dbo.pos_cash_balance;

SELECT
    COUNT_BIG(*) AS DuplicateGroups,
    COALESCE(SUM(RecordsInGroup - 1), 0) AS ExtraRows
FROM (
    SELECT
        SK_ID_PREV,
        MONTHS_BALANCE,
        COUNT_BIG(*) AS RecordsInGroup
    FROM consumer_loan_risk.dbo.pos_cash_balance
    GROUP BY SK_ID_PREV, MONTHS_BALANCE
    HAVING COUNT_BIG(*) > 1
) AS duplicates;

CREATE UNIQUE CLUSTERED INDEX CIX_pos_cash_balance_LoanMonth
ON consumer_loan_risk.dbo.pos_cash_balance (
    SK_ID_PREV,
    MONTHS_BALANCE
);

WITH latest_observation AS (
    SELECT
        SK_ID_PREV,
        NAME_CONTRACT_STATUS,
        SK_DPD,
        ROW_NUMBER() OVER (
            PARTITION BY SK_ID_PREV
            ORDER BY MONTHS_BALANCE DESC
        ) AS rn
    FROM consumer_loan_risk.dbo.pos_cash_balance
)
SELECT
    NAME_CONTRACT_STATUS AS ContractStatus,
    COUNT_BIG(*) AS LoanCount,
    COUNT_BIG(CASE
        WHEN SK_DPD > 0 THEN 1
    END) AS OverdueLoans
FROM latest_observation
WHERE rn = 1
GROUP BY NAME_CONTRACT_STATUS
ORDER BY LoanCount DESC;

-- Q1. DPD distribution among latest-observed Active loans

WITH latest_observation AS (
    SELECT
        NAME_CONTRACT_STATUS,
        SK_DPD,
        ROW_NUMBER() OVER (
            PARTITION BY SK_ID_PREV
            ORDER BY MONTHS_BALANCE DESC
        ) AS rn
    FROM consumer_loan_risk.dbo.pos_cash_balance
),
bucketed AS (
    SELECT
        CASE
            WHEN SK_DPD IS NULL OR SK_DPD < 0 THEN 'Unknown'
            WHEN SK_DPD = 0 THEN '0 DPD'
            WHEN SK_DPD <= 30 THEN '1-30 DPD'
            WHEN SK_DPD <= 60 THEN '31-60 DPD'
            WHEN SK_DPD <= 90 THEN '61-90 DPD'
            ELSE '91+ DPD'
        END AS DPDGroup
    FROM latest_observation
    WHERE rn = 1
      AND NAME_CONTRACT_STATUS = N'Active'
)
SELECT
    DPDGroup,
    COUNT_BIG(*) AS LoanCount,
    CAST(
        100.0 * COUNT_BIG(*)
        / SUM(COUNT_BIG(*)) OVER ()
        AS DECIMAL(6,2)
    ) AS LoanSharePct
FROM bucketed
GROUP BY DPDGroup
ORDER BY CASE DPDGroup
    WHEN '0 DPD' THEN 0
    WHEN '1-30 DPD' THEN 1
    WHEN '31-60 DPD' THEN 2
    WHEN '61-90 DPD' THEN 3
    WHEN '91+ DPD' THEN 4
    ELSE 5
END;

CREATE TABLE consumer_loan_risk.dbo.previous_application_raw (
    SK_ID_PREV                    NVARCHAR(100) NULL,
    SK_ID_CURR                    NVARCHAR(100) NULL,
    NAME_CONTRACT_TYPE            NVARCHAR(100) NULL,
    AMT_ANNUITY                   NVARCHAR(100) NULL,
    AMT_APPLICATION               NVARCHAR(100) NULL,
    AMT_CREDIT                    NVARCHAR(100) NULL,
    AMT_DOWN_PAYMENT              NVARCHAR(100) NULL,
    AMT_GOODS_PRICE               NVARCHAR(100) NULL,
    WEEKDAY_APPR_PROCESS_START    NVARCHAR(100) NULL,
    HOUR_APPR_PROCESS_START       NVARCHAR(100) NULL,
    FLAG_LAST_APPL_PER_CONTRACT   NVARCHAR(100) NULL,
    NFLAG_LAST_APPL_IN_DAY        NVARCHAR(100) NULL,
    RATE_DOWN_PAYMENT             NVARCHAR(100) NULL,
    RATE_INTEREST_PRIMARY         NVARCHAR(100) NULL,
    RATE_INTEREST_PRIVILEGED      NVARCHAR(100) NULL,
    NAME_CASH_LOAN_PURPOSE        NVARCHAR(100) NULL,
    NAME_CONTRACT_STATUS          NVARCHAR(100) NULL,
    DAYS_DECISION                 NVARCHAR(100) NULL,
    NAME_PAYMENT_TYPE             NVARCHAR(100) NULL,
    CODE_REJECT_REASON            NVARCHAR(100) NULL,
    NAME_TYPE_SUITE               NVARCHAR(100) NULL,
    NAME_CLIENT_TYPE              NVARCHAR(100) NULL,
    NAME_GOODS_CATEGORY           NVARCHAR(100) NULL,
    NAME_PORTFOLIO                NVARCHAR(100) NULL,
    NAME_PRODUCT_TYPE             NVARCHAR(100) NULL,
    CHANNEL_TYPE                  NVARCHAR(100) NULL,
    SELLERPLACE_AREA              NVARCHAR(100) NULL,
    NAME_SELLER_INDUSTRY           NVARCHAR(100) NULL,
    CNT_PAYMENT                   NVARCHAR(100) NULL,
    NAME_YIELD_GROUP              NVARCHAR(100) NULL,
    PRODUCT_COMBINATION           NVARCHAR(100) NULL,
    DAYS_FIRST_DRAWING            NVARCHAR(100) NULL,
    DAYS_FIRST_DUE                NVARCHAR(100) NULL,
    DAYS_LAST_DUE_1ST_VERSION      NVARCHAR(100) NULL,
    DAYS_LAST_DUE                 NVARCHAR(100) NULL,
    DAYS_TERMINATION              NVARCHAR(100) NULL,
    NFLAG_INSURED_ON_APPROVAL     NVARCHAR(100) NULL
);

-- Q2 preparation: validate input data before joining

WITH checked AS (
    SELECT
        TRY_CONVERT(INT,
            NULLIF(LTRIM(RTRIM(SK_ID_PREV)), N'')) AS PrevID,
        TRY_CONVERT(INT,
            NULLIF(LTRIM(RTRIM(SK_ID_CURR)), N'')) AS CurrID,
        NULLIF(LTRIM(RTRIM(NAME_CONTRACT_TYPE)), N'') AS Product,
        NULLIF(LTRIM(RTRIM(CHANNEL_TYPE)), N'') AS Channel
    FROM consumer_loan_risk.dbo.previous_application_raw
)
SELECT
    COUNT_BIG(*) AS TotalRows,
    COUNT_BIG(DISTINCT PrevID) AS DistinctPrevIDs,
    COUNT_BIG(CASE
        WHEN PrevID IS NULL OR PrevID <= 0 THEN 1
    END) AS InvalidPrevIDs,
    COUNT_BIG(CASE
        WHEN CurrID IS NULL OR CurrID <= 0 THEN 1
    END) AS InvalidCurrIDs,
    COUNT_BIG(CASE
        WHEN Product IS NULL THEN 1
    END) AS MissingProduct,
    COUNT_BIG(CASE
        WHEN Channel IS NULL THEN 1
    END) AS MissingChannel
FROM checked;

-- Q2. Delinquency by product and origination channel
-- Population: loans whose latest observed status is Active

WITH latest_observation AS (
    SELECT
        SK_ID_PREV,
        SK_ID_CURR,
        NAME_CONTRACT_STATUS,
        SK_DPD,
        ROW_NUMBER() OVER (
            PARTITION BY SK_ID_PREV
            ORDER BY MONTHS_BALANCE DESC
        ) AS rn
    FROM consumer_loan_risk.dbo.pos_cash_balance
),
previous_clean AS (
    SELECT
        TRY_CONVERT(INT,
            NULLIF(LTRIM(RTRIM(SK_ID_PREV)), N'')) AS PrevID,
        TRY_CONVERT(INT,
            NULLIF(LTRIM(RTRIM(SK_ID_CURR)), N'')) AS CurrID,
        NULLIF(LTRIM(RTRIM(NAME_CONTRACT_TYPE)), N'') AS Product,
        NULLIF(LTRIM(RTRIM(CHANNEL_TYPE)), N'') AS Channel
    FROM consumer_loan_risk.dbo.previous_application_raw
),
analysis_base AS (
    SELECT
        CASE
            WHEN p.PrevID IS NULL THEN N'Unmatched'
            ELSE COALESCE(p.Product, N'Missing product')
        END AS Product,
        CASE
            WHEN p.PrevID IS NULL THEN N'Unmatched'
            ELSE COALESCE(p.Channel, N'Missing channel')
        END AS Channel,
        l.SK_DPD
    FROM latest_observation AS l
    LEFT JOIN previous_clean AS p
        ON l.SK_ID_PREV = p.PrevID
       AND l.SK_ID_CURR = p.CurrID
    WHERE l.rn = 1
      AND l.NAME_CONTRACT_STATUS = N'Active'
)
SELECT
    Product,
    Channel,
    COUNT_BIG(*) AS LoanCount,
    COUNT_BIG(CASE
        WHEN SK_DPD > 0 THEN 1
    END) AS OverdueLoans,
    CAST(
        100.0 * COUNT_BIG(CASE
            WHEN SK_DPD > 0 THEN 1
        END) / COUNT_BIG(*)
        AS DECIMAL(6,2)
    ) AS OverdueRatePct,
    COUNT_BIG(CASE
        WHEN SK_DPD >= 91 THEN 1
    END) AS DPD91PlusLoans
FROM analysis_base
GROUP BY Product, Channel
ORDER BY LoanCount DESC, Product, Channel;

-- Q2: diagnose unmatched loans

WITH latest_observation AS (
    SELECT
        SK_ID_PREV,
        SK_ID_CURR,
        NAME_CONTRACT_STATUS,
        SK_DPD,
        ROW_NUMBER() OVER (
            PARTITION BY SK_ID_PREV
            ORDER BY MONTHS_BALANCE DESC
        ) AS rn
    FROM consumer_loan_risk.dbo.pos_cash_balance
),
previous_keys AS (
    SELECT
        TRY_CONVERT(INT,
            NULLIF(LTRIM(RTRIM(SK_ID_PREV)), N'')) AS PrevID,
        TRY_CONVERT(INT,
            NULLIF(LTRIM(RTRIM(SK_ID_CURR)), N'')) AS CurrID
    FROM consumer_loan_risk.dbo.previous_application_raw
),
link_check AS (
    SELECT
        l.SK_DPD,
        CASE
            WHEN p.PrevID IS NULL
                THEN N'Missing previous application'
            WHEN p.CurrID IS NULL OR p.CurrID <> l.SK_ID_CURR
                THEN N'Current ID mismatch'
            ELSE N'Matched'
        END AS MatchStatus
    FROM latest_observation AS l
    LEFT JOIN previous_keys AS p
        ON l.SK_ID_PREV = p.PrevID
    WHERE l.rn = 1
      AND l.NAME_CONTRACT_STATUS = N'Active'
)
SELECT
    MatchStatus,
    COUNT_BIG(*) AS LoanCount,
    COUNT_BIG(CASE
        WHEN SK_DPD > 0 THEN 1
    END) AS OverdueLoans,
    COUNT_BIG(CASE
        WHEN SK_DPD >= 91 THEN 1
    END) AS DPD91PlusLoans,
    (
        SELECT COUNT_BIG(*)
        FROM consumer_loan_risk.dbo.previous_application_raw
    ) AS ImportedPreviousRows
FROM link_check
GROUP BY MatchStatus
ORDER BY LoanCount DESC;

-- Q3. Consecutive-month DPD transitions from Active loans

WITH monthly AS (
    SELECT
        SK_ID_PREV,
        SK_ID_CURR,
        MONTHS_BALANCE,
        NAME_CONTRACT_STATUS,
        CASE
            WHEN SK_DPD IS NULL OR SK_DPD < 0 THEN 'Unknown'
            WHEN SK_DPD = 0 THEN '0 DPD'
            WHEN SK_DPD <= 30 THEN '1-30 DPD'
            WHEN SK_DPD <= 60 THEN '31-60 DPD'
            WHEN SK_DPD <= 90 THEN '61-90 DPD'
            ELSE '91+ DPD'
        END AS DPDGroup
    FROM consumer_loan_risk.dbo.pos_cash_balance
),
sequenced AS (
    SELECT
        *,
        LEAD(MONTHS_BALANCE) OVER (
            PARTITION BY SK_ID_PREV ORDER BY MONTHS_BALANCE
        ) AS NextMonth,
        LEAD(SK_ID_CURR) OVER (
            PARTITION BY SK_ID_PREV ORDER BY MONTHS_BALANCE
        ) AS NextCurrID,
        LEAD(NAME_CONTRACT_STATUS) OVER (
            PARTITION BY SK_ID_PREV ORDER BY MONTHS_BALANCE
        ) AS NextStatus,
        LEAD(DPDGroup) OVER (
            PARTITION BY SK_ID_PREV ORDER BY MONTHS_BALANCE
        ) AS NextDPDGroup
    FROM monthly
),
flows AS (
    SELECT
        DPDGroup AS FromDPD,
        CASE
            WHEN NextMonth IS NULL
              OR NextMonth <> MONTHS_BALANCE + 1
                THEN 'No next-month observation'
            WHEN NextCurrID IS NULL OR NextCurrID <> SK_ID_CURR
                THEN 'Current ID mismatch'
            WHEN NextStatus = N'Completed'
                THEN 'Completed'
            WHEN NextStatus = N'Active'
                THEN NextDPDGroup
            ELSE 'Other status'
        END AS ToState,
        CASE
            WHEN NextMonth = MONTHS_BALANCE + 1
             AND NextCurrID = SK_ID_CURR
                THEN 1
            ELSE 0
        END AS HasNextMonth
    FROM sequenced
    WHERE NAME_CONTRACT_STATUS = N'Active'
),
counts AS (
    SELECT
        FromDPD,
        ToState,
        HasNextMonth,
        COUNT_BIG(*) AS LoanMonthPairs
    FROM flows
    GROUP BY FromDPD, ToState, HasNextMonth
)
SELECT
    FromDPD,
    ToState,
    LoanMonthPairs,
    CASE
        WHEN HasNextMonth = 1 THEN
            CAST(
                100.0 * LoanMonthPairs
                / NULLIF(
                    SUM(CASE
                        WHEN HasNextMonth = 1 THEN LoanMonthPairs
                        ELSE 0
                    END) OVER (PARTITION BY FromDPD),
                    0
                )
                AS DECIMAL(6,2)
            )
    END AS ObservedTransitionPct
FROM counts
ORDER BY FromDPD, ToState;

-- Q4. How often do delinquent Active loan observations
-- return to 0 DPD in the following month?
-- Cure: next status is Active and next DPD equals zero.
-- Completed is reported separately.

WITH sequenced AS (
    SELECT
        SK_ID_CURR,
        MONTHS_BALANCE,
        NAME_CONTRACT_STATUS,
        SK_DPD,
        LEAD(MONTHS_BALANCE) OVER (
            PARTITION BY SK_ID_PREV ORDER BY MONTHS_BALANCE
        ) AS NextMonth,
        LEAD(SK_ID_CURR) OVER (
            PARTITION BY SK_ID_PREV ORDER BY MONTHS_BALANCE
        ) AS NextCurrID,
        LEAD(NAME_CONTRACT_STATUS) OVER (
            PARTITION BY SK_ID_PREV ORDER BY MONTHS_BALANCE
        ) AS NextStatus,
        LEAD(SK_DPD) OVER (
            PARTITION BY SK_ID_PREV ORDER BY MONTHS_BALANCE
        ) AS NextDPD
    FROM consumer_loan_risk.dbo.pos_cash_balance
),
eligible AS (
    SELECT
        CASE
            WHEN SK_DPD <= 30 THEN '1-30 DPD'
            WHEN SK_DPD <= 60 THEN '31-60 DPD'
            WHEN SK_DPD <= 90 THEN '61-90 DPD'
            ELSE '91+ DPD'
        END AS DPDGroup,
        NextStatus,
        NextDPD
    FROM sequenced
    WHERE NAME_CONTRACT_STATUS = N'Active'
      AND SK_DPD > 0
      AND NextMonth = MONTHS_BALANCE + 1
      AND NextCurrID = SK_ID_CURR
),
counts AS (
    SELECT
        DPDGroup,
        COUNT_BIG(*) AS ObservedPairs,
        COUNT_BIG(CASE
            WHEN NextStatus = N'Active' AND NextDPD = 0
            THEN 1
        END) AS CuredPairs,
        COUNT_BIG(CASE
            WHEN NextStatus = N'Completed'
            THEN 1
        END) AS CompletedPairs
    FROM eligible
    GROUP BY DPDGroup
)
SELECT
    DPDGroup,
    ObservedPairs,
    CuredPairs,
    CAST(
        100.0 * CuredPairs / NULLIF(ObservedPairs, 0)
        AS DECIMAL(6,2)
    ) AS CureRatePct,
    CompletedPairs,
    CAST(
        100.0 * CompletedPairs / NULLIF(ObservedPairs, 0)
        AS DECIMAL(6,2)
    ) AS CompletedRatePct
FROM counts
ORDER BY CASE DPDGroup
    WHEN '1-30 DPD' THEN 1
    WHEN '31-60 DPD' THEN 2
    WHEN '61-90 DPD' THEN 3
    ELSE 4
END;

-- Create a staging table for application profiles.

CREATE TABLE consumer_loan_risk.dbo.application_profile_raw (
    SK_ID_CURR       NVARCHAR(100) NULL,
    AMT_INCOME_TOTAL NVARCHAR(100) NULL,
    NAME_INCOME_TYPE NVARCHAR(100) NULL,
    OCCUPATION_TYPE  NVARCHAR(100) NULL
);

SELECT COUNT_BIG(*) AS TotalRows
FROM consumer_loan_risk.dbo.application_profile_raw;

-- Q5. How does latest-observed Active loan delinquency
-- vary by applicants' income and occupation?
-- Part A: Income bands using current application attributes.

WITH latest_observation AS (
    SELECT
        SK_ID_CURR,
        NAME_CONTRACT_STATUS,
        SK_DPD,
        ROW_NUMBER() OVER (
            PARTITION BY SK_ID_PREV
            ORDER BY MONTHS_BALANCE DESC
        ) AS rn
    FROM consumer_loan_risk.dbo.pos_cash_balance
),
application_profile AS (
    SELECT
        TRY_CONVERT(
            INT,
            NULLIF(LTRIM(RTRIM(SK_ID_CURR)), N'')
        ) AS SK_ID_CURR,
        TRY_CONVERT(
            DECIMAL(19,2),
            NULLIF(LTRIM(RTRIM(AMT_INCOME_TOTAL)), N'')
        ) AS IncomeAmount
    FROM consumer_loan_risk.dbo.application_profile_raw
),
bucketed AS (
    SELECT
        l.SK_DPD,
        CASE
            WHEN p.SK_ID_CURR IS NULL
                THEN 'Unmatched application profile'
            WHEN p.IncomeAmount IS NULL OR p.IncomeAmount <= 0
                THEN 'Missing / invalid income'
            WHEN p.IncomeAmount < 100000
                THEN 'Below 100,000'
            WHEN p.IncomeAmount < 200000
                THEN '100,000 to below 200,000'
            WHEN p.IncomeAmount < 300000
                THEN '200,000 to below 300,000'
            ELSE '300,000 and above'
        END AS IncomeBand
    FROM latest_observation AS l
    LEFT JOIN application_profile AS p
        ON l.SK_ID_CURR = p.SK_ID_CURR
    WHERE l.rn = 1
      AND l.NAME_CONTRACT_STATUS = N'Active'
)
SELECT
    IncomeBand,
    COUNT_BIG(*) AS LoanCount,
    COUNT_BIG(CASE
        WHEN SK_DPD > 0 THEN 1
    END) AS OverdueLoans,
    CAST(
        100.0 * COUNT_BIG(CASE
            WHEN SK_DPD > 0 THEN 1
        END) / NULLIF(COUNT_BIG(*), 0)
        AS DECIMAL(6,2)
    ) AS OverdueRatePct,
    COUNT_BIG(CASE
        WHEN SK_DPD >= 91 THEN 1
    END) AS DPD91PlusLoans
FROM bucketed
GROUP BY IncomeBand
ORDER BY CASE IncomeBand
    WHEN 'Below 100,000' THEN 1
    WHEN '100,000 to below 200,000' THEN 2
    WHEN '200,000 to below 300,000' THEN 3
    WHEN '300,000 and above' THEN 4
    WHEN 'Missing / invalid income' THEN 5
    ELSE 6
END;

-- Q5. How does latest-observed Active loan delinquency
-- vary by applicants' income and occupation?
-- Part B: Occupation using current application attributes.

WITH latest_observation AS (
    SELECT
        SK_ID_CURR,
        NAME_CONTRACT_STATUS,
        SK_DPD,
        ROW_NUMBER() OVER (
            PARTITION BY SK_ID_PREV
            ORDER BY MONTHS_BALANCE DESC
        ) AS rn
    FROM consumer_loan_risk.dbo.pos_cash_balance
),
application_profile AS (
    SELECT
        TRY_CONVERT(
            INT,
            NULLIF(LTRIM(RTRIM(SK_ID_CURR)), N'')
        ) AS SK_ID_CURR,
        NULLIF(
            LTRIM(RTRIM(OCCUPATION_TYPE)), N''
        ) AS OccupationType
    FROM consumer_loan_risk.dbo.application_profile_raw
),
profiled AS (
    SELECT
        l.SK_DPD,
        CASE
            WHEN p.SK_ID_CURR IS NULL
                THEN 'Unmatched application profile'
            WHEN p.OccupationType IS NULL
                THEN 'Unknown occupation'
            ELSE p.OccupationType
        END AS Occupation
    FROM latest_observation AS l
    LEFT JOIN application_profile AS p
        ON l.SK_ID_CURR = p.SK_ID_CURR
    WHERE l.rn = 1
      AND l.NAME_CONTRACT_STATUS = N'Active'
)
SELECT
    Occupation,
    COUNT_BIG(*) AS LoanCount,
    COUNT_BIG(CASE
        WHEN SK_DPD > 0 THEN 1
    END) AS OverdueLoans,
    CAST(
        100.0 * COUNT_BIG(CASE
            WHEN SK_DPD > 0 THEN 1
        END) / NULLIF(COUNT_BIG(*), 0)
        AS DECIMAL(6,2)
    ) AS OverdueRatePct,
    COUNT_BIG(CASE
        WHEN SK_DPD >= 91 THEN 1
    END) AS DPD91PlusLoans
FROM profiled
GROUP BY Occupation
ORDER BY LoanCount DESC, Occupation;
