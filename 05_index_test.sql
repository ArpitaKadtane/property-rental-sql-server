SELECT * FROM dbo.PaymentAudit;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;


CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);
GO

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;

SELECT COUNT(*) AS OverdueCount FROM dbo.vw_OverduePayments;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;



CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);
GO

SET STATISTICS IO ON;

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;


SELECT Locality, COUNT(*) AS TotalProperties,
       SUM(CASE WHEN Status = 'Leased' THEN 1 ELSE 0 END) AS LeasedProperties,
       CAST(100.0 * SUM(CASE WHEN Status = 'Leased' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS OccupancyPct
FROM dbo.Properties
GROUP BY Locality
ORDER BY OccupancyPct DESC;

SELECT * FROM dbo.PaymentAudit;

DROP INDEX IX_Payments_DueDate ON dbo.Payments;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;


CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);
GO

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;

DROP INDEX IX_Payments_DueDate ON dbo.Payments;

SET STATISTICS IO ON;

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;


CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);


CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);
GO

SET STATISTICS IO ON;

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;


SET STATISTICS IO ON;

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;

DROP INDEX IX_Payments_DueDate ON dbo.Payments;

CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);

SET STATISTICS IO ON;

SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;

CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);

CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);