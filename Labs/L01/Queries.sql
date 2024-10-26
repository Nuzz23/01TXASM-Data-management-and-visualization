--  Select the yearly income for each phone rate, the total income for each phone rate, 
--  the total yearly income and the total income

SELECT P.PHONERATETYPE, T.DATEYEAR,
    SUM(F.PRICE) YEARLY_INCOME_BY_PHONERATE,
    SUM(SUM(F.PRICE)) OVER (PARTITION BY P.PHONERATETYPE) TOTAL_INCOME_BY_PHONERATE,
    SUM(SUM(F.PRICE)) OVER (PARTITION BY T.DATEYEAR) AS YEARLY_INCOME,
    SUM(SUM(F.PRICE)) OVER () TOTAL_INCOME 
FROM FACTS F, PHONERATE P, TIMEDIM T
WHERE F.ID_PHONERATE=P.ID_PHONERATE AND T.ID_TIME=F.ID_TIME
GROUP BY P.ID_PHONERATE, P.PHONERATETYPE, T.DATEYEAR


--  Select the monthly number of calls and the monthly income. Associate the RANK() to each month
--  according to its income (1 for the month with the highest income, 2 for the second, etc., the last
--  month is the one with the least income). 

SELECT T.DATEMONTH, T.DATEYEAR,
    SUM(F.PRICE) MONTHLY_REVENUES,
    SUM(NUMBEROFCALLS) MONTHLY_CALLS,
    RANK() OVER (ORDER BY SUM(F.PRICE) DESC) RANKING
FROM TIMEDIM T, FACTS F
WHERE F.ID_TIME=T.ID_TIME
GROUP BY T.DATEMONTH, T.DATEYEAR
ORDER BY T.DATEYEAR, T.DATEMONTH


--  For each month in 2003, select the total number of calls. Associate the RANK() to each month
--  according to its total number of calls (1 for the month with the highest number of calls, 2 for the
--  second, etc., the last month is the one with the least number of calls).

SELECT T.DATEMONTH,
    SUM(F.NUMBEROFCALLS) TOTAL_CALLS,
    RANK() OVER (ORDER BY SUM(F.NUMBEROFCALLS) DESC) RANKING
FROM FACTS F, TIMEDIM T
WHERE F.ID_TIME=T.ID_TIME AND T.DATEYEAR='2003'
GROUP BY T.DATEMONTH
ORDER BY RANKING, T.DATEMONTH


-- For each day in July 2003, select the total income and the average income over the last 3 days
SELECT T.DAYDATE,
    SUM(F.PRICE) INCOME_BY_DAY,
    AVG(SUM(F.PRICE)) OVER (ORDER BY T.DAYDATE 
                            ROWS 2 PRECEDING) AVG_3_DAY_BEFORE
FROM FACTS F, TIMEDIM T
WHERE F.ID_TIME=T.ID_TIME AND T.DATEMONTH='07-2003'
GROUP BY T.DAYDATE
ORDER BY T.DAYDATE


-- Select the monthly income and the cumulative monthly income from the beginning of the year. 
SELECT T.DATEMONTH,
    SUM(F.PRICE) MONTHLY_INCOME,
    SUM(SUM(F.PRICE)) OVER (PARTITION BY T.DATEYEAR 
                            ORDER BY T.DATEMONTH 
                            ROWS UNBOUNDED PRECEDING) CUMULATIVE_MONTHLY_INCOME
FROM FACTS F, TIMEDIM T
WHERE F.ID_TIME=T.ID_TIME
GROUP BY T.DATEMONTH, T.DATEYEAR
ORDER BY T.DATEYEAR, T.DATEMONTH