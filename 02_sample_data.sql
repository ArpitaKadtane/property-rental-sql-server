SELECT TOP (5000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS i
INTO dbo.Nums
FROM sys.all_objects a CROSS JOIN sys.all_objects b;

INSERT INTO dbo.Agents (FullName, Email, HireDate)
SELECT CONCAT('Agent ', i), CONCAT('agent', i, '@example.com'),
       DATEADD(DAY, i * 40, '2019-01-01')
FROM dbo.Nums WHERE i <= 10;

INSERT INTO dbo.Properties (Locality, PropertyType, AreaSqFt, MonthlyRent)
SELECT CHOOSE(i % 8 + 1,'Baner','Balewadi','Hinjewadi','Kothrud',
                        'Wakad','Viman Nagar','Aundh','Hadapsar'),
       CHOOSE(i % 4 + 1,'Apartment','Villa','Office','Shop'),
       400 + (i * 37) % 2600,
       8000 + ((i * 911) % 92000)
FROM dbo.Nums WHERE i <= 500;

INSERT INTO dbo.Tenants (FullName, Phone, Email)
SELECT CONCAT('Tenant ', i), CONCAT('90000', RIGHT(CONCAT('00000', i), 5)),
       CONCAT('tenant', i, '@example.com')
FROM dbo.Nums WHERE i <= 800;

INSERT INTO dbo.Leases (PropertyID, TenantID, AgentID, StartDate, EndDate, MonthlyRent)
SELECT p.PropertyID,
       1 + (n.i * 7) % 800,
       1 + n.i % 10,
       DATEADD(DAY, (n.i * 7) % 1000, '2023-01-01'),
       DATEADD(MONTH, 11, DATEADD(DAY, (n.i * 7) % 1000, '2023-01-01')),
       p.MonthlyRent
FROM dbo.Nums n
JOIN dbo.Properties p ON p.PropertyID = 1 + (n.i % 500);

;WITH m AS (SELECT i - 1 AS k FROM dbo.Nums WHERE i <= 11)
INSERT INTO dbo.Payments (LeaseID, DueDate, PaidDate, Amount)
SELECT l.LeaseID, d.DueDate,
       CASE WHEN (l.LeaseID + m.k) % 10 = 0 THEN NULL
            WHEN (l.LeaseID + m.k) % 10 IN (1,2)
                 THEN DATEADD(DAY, 5 + l.LeaseID % 10, d.DueDate)
            ELSE d.DueDate END,
       l.MonthlyRent
FROM dbo.Leases l
CROSS JOIN m
CROSS APPLY (SELECT DATEADD(MONTH, m.k, l.StartDate) AS DueDate) d
WHERE d.DueDate <= CAST(GETDATE() AS DATE);

INSERT INTO dbo.MaintenanceRequests (PropertyID, Category, RaisedDate, ResolvedDate, Cost)
SELECT 1 + i % 500,
       CHOOSE(i % 4 + 1,'Plumbing','Electrical','Painting','Other'),
       DATEADD(DAY, (i * 3) % 1000, '2023-01-01'),
       DATEADD(DAY, (i * 3) % 1000 + 1 + i % 20, '2023-01-01'),
       500 + (i * 37) % 15000
FROM dbo.Nums WHERE i <= 3000;

UPDATE dbo.Properties SET Status = 'Leased'
WHERE PropertyID IN (SELECT PropertyID FROM dbo.Leases WHERE EndDate >= GETDATE());

DROP TABLE dbo.Nums;


SELECT 'Agents' AS TableName, COUNT(*) AS Rows FROM dbo.Agents
UNION ALL SELECT 'Properties', COUNT(*) FROM dbo.Properties
UNION ALL SELECT 'Tenants', COUNT(*) FROM dbo.Tenants
UNION ALL SELECT 'Leases', COUNT(*) FROM dbo.Leases
UNION ALL SELECT 'Payments', COUNT(*) FROM dbo.Payments
UNION ALL SELECT 'MaintenanceRequests', COUNT(*) FROM dbo.MaintenanceRequests;