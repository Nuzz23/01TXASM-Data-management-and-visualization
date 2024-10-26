--  NOTE:
--  for this laboratory the schema and data are the same of L01


--   Consider the year 2003. Separately for phone rate and month, analyze the (i) average daily income
--   and the (ii) average income for number of calls. 

SELECT P.PHONERATETYPE, T.DATEMONTH,
	SUM(F.PRICE)/COUNT(DISTINCT T.DAYDATE) AVG_INCOME,
	SUM(F.PRICE)/SUM(F.NUMBEROFCALLS) AVG_CALLS
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE F.ID_TIME=T.ID_TIME AND F.ID_PHONERATE=P.ID_PHONERATE AND T.DATEYEAR='2003'
GROUP BY P.PHONERATETYPE, T.DATEMONTH
ORDER BY T.DATEMONTH, P.PHONERATETYPE


--  Select the daily number of calls for each caller region and the daily number of calls   for each
--  caller province.

SELECT L.PROVINCE, L.REGION,
   SUM(F.NUMBEROFCALLS)/COUNT(DISTINCT T.DAYDATE) AS AVG_CALLS_PROVINCE,
   SUM(SUM(F.NUMBEROFCALLS)) OVER (PARTITION BY L.REGION) / COUNT(DISTINCT T.DAYDATE) AS AVG_CALLS_REGION 
FROM FACTS F, LOCATION L, TIMEDIM T
WHERE F.ID_TIME=T.ID_TIME AND L.ID_LOCATION=F.ID_LOCATION_CALLER
GROUP BY L.PROVINCE, L.REGION
ORDER BY L.PROVINCE, L.REGION


--   Consider the year 2003. Separately for phone rate and month, analyze the (i) total income, (ii)
--   the percentage of income with respect to the total revenue considering all the phone rates, (iii)
--   the percentage of income with respect to the total revenue considering all the months.

SELECT T.DATEMONTH, P.PHONERATETYPE,
    SUM(F.PRICE) TOT_INCOME,
	100*SUM(F.PRICE)/SUM(SUM(F.PRICE)) OVER (PARTITION BY T.DATEMONTH) PERCENTAGE_PHONE_RATE,
    100*SUM(F.PRICE)/SUM(SUM(F.PRICE)) OVER (PARTITION BY P.PHONERATETYPE) PERCENTAGE_MONTH
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE F.ID_TIME=T.ID_TIME AND P.ID_PHONERATE=F.ID_PHONERATE AND T.DATEYEAR='2003'
GROUP BY T.DATEMONTH, P.PHONERATETYPE
ORDER BY T.DATEMONTH, P.PHONERATETYPE


--   For each caller province, analyze (i) the total number of calls and (ii) the percentage of number
--   of calls with respect to the total number of calls considering the corresponding region.

SELECT L.PROVINCE, L.REGION,
	SUM(F.NUMBEROFCALLS) TOT_CALLS_PROVINCE,
    100*SUM(F.NUMBEROFCALLS)/SUM(SUM(F.NUMBEROFCALLS)) OVER (PARTITION BY L.REGION) CALLS_BY_REGION
FROM FACTS F, LOCATION L
WHERE F.ID_LOCATION_CALLER=L.ID_LOCATION
GROUP BY L.PROVINCE, L.REGION
ORDER BY L.PROVINCE, L.REGION


--   For each receiver region, select the monthly number of calls and the cumulative monthly number of
--   calls from the beginning of the year.

SELECT L.REGION, T.DATEMONTH, T.DATEYEAR,
    SUM(F.NUMBEROFCALLS) MONTHLY_CALLS,
    SUM(SUM(F.NUMBEROFCALLS)) OVER (PARTITION BY L.REGION, 
                                    T.DATEYEAR ORDER BY T.DATEMONTH 
                                    ROWS UNBOUNDED PRECEDING) CUMULATIVE_CALLS
FROM FACTS F, LOCATION L, TIMEDIM T
WHERE F.ID_LOCATION_RECEIVER=L.ID_LOCATION AND T.ID_TIME=F.ID_TIME
GROUP BY T.DATEMONTH, T.DATEYEAR, L.REGION
ORDER BY L.REGION, T.DATEYEAR, T.DATEYEAR