-- Q1: Rent collected per month
SELECT YEAR(PaidDate) AS Yr, MONTH(PaidDate) AS Mth, SUM(Amount) AS Collected
FROM dbo.Payments
WHERE PaidDate IS NOT NULL
GROUP BY YEAR(PaidDate), MONTH(PaidDate)
ORDER BY Yr, Mth;

-- Q2: Overdue payments with tenant and days overdue
SELECT t.FullName, pr.Locality, p.DueDate, p.Amount,
       DATEDIFF(DAY, p.DueDate, GETDATE()) AS DaysOverdue
FROM dbo.Payments p
JOIN dbo.Leases l      ON l.LeaseID = p.LeaseID
JOIN dbo.Tenants t     ON t.TenantID = l.TenantID
JOIN dbo.Properties pr ON pr.PropertyID = l.PropertyID
WHERE p.PaidDate IS NULL AND p.DueDate < CAST(GETDATE() AS DATE)
ORDER BY DaysOverdue DESC;

-- Q3: Top 5 agents by total lease value
SELECT TOP 5 a.FullName, COUNT(*) AS Leases,
       SUM(l.MonthlyRent * DATEDIFF(MONTH, l.StartDate, l.EndDate)) AS TotalLeaseValue
FROM dbo.Leases l
JOIN dbo.Agents a ON a.AgentID = l.AgentID
GROUP BY a.FullName
ORDER BY TotalLeaseValue DESC;

-- Q4: Occupancy rate per locality
SELECT Locality, COUNT(*) AS TotalProperties,
       SUM(CASE WHEN Status = 'Leased' THEN 1 ELSE 0 END) AS LeasedProperties,
       CAST(100.0 * SUM(CASE WHEN Status = 'Leased' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS OccupancyPct
FROM dbo.Properties
GROUP BY Locality
ORDER BY OccupancyPct DESC;

-- Q5: Tenants who paid late more than 3 times
SELECT t.TenantID, t.FullName, COUNT(*) AS LatePayments
FROM dbo.Payments p
JOIN dbo.Leases l  ON l.LeaseID = p.LeaseID
JOIN dbo.Tenants t ON t.TenantID = l.TenantID
WHERE p.PaidDate > p.DueDate
GROUP BY t.TenantID, t.FullName
HAVING COUNT(*) > 3
ORDER BY LatePayments DESC;

-- Q6: Month-over-month revenue change (window function)
WITH m AS (
    SELECT DATEFROMPARTS(YEAR(PaidDate), MONTH(PaidDate), 1) AS MonthStart,
           SUM(Amount) AS Revenue
    FROM dbo.Payments
    WHERE PaidDate IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(PaidDate), MONTH(PaidDate), 1)
)
SELECT MonthStart, Revenue,
       LAG(Revenue) OVER (ORDER BY MonthStart) AS PrevRevenue,
       CAST(100.0 * (Revenue - LAG(Revenue) OVER (ORDER BY MonthStart))
            / NULLIF(LAG(Revenue) OVER (ORDER BY MonthStart), 0) AS DECIMAL(6,2)) AS PctChange
FROM m
ORDER BY MonthStart;

-- Q7: Properties with maintenance cost above the average (CTE + subquery)
WITH c AS (
    SELECT PropertyID, SUM(Cost) AS TotalCost
    FROM dbo.MaintenanceRequests
    GROUP BY PropertyID
)
SELECT p.PropertyID, p.Locality, p.PropertyType, c.TotalCost
FROM c
JOIN dbo.Properties p ON p.PropertyID = c.PropertyID
WHERE c.TotalCost > (SELECT AVG(TotalCost) FROM c)
ORDER BY c.TotalCost DESC;

-- Q8: Rank properties by revenue within each locality
SELECT p.Locality, p.PropertyID, SUM(pay.Amount) AS Revenue,
       RANK() OVER (PARTITION BY p.Locality ORDER BY SUM(pay.Amount) DESC) AS RankInLocality
FROM dbo.Payments pay
JOIN dbo.Leases l      ON l.LeaseID = pay.LeaseID
JOIN dbo.Properties p  ON p.PropertyID = l.PropertyID
WHERE pay.PaidDate IS NOT NULL
GROUP BY p.Locality, p.PropertyID
ORDER BY p.Locality, RankInLocality;



SELECT TOP 10 * FROM dbo.vw_OverduePayments ORDER BY DaysOverdue DESC;
SELECT * FROM dbo.vw_MonthlyRevenue ORDER BY Yr, Mth;

