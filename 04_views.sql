CREATE PROCEDURE dbo.usp_GetOverduePayments @AsOfDate DATE AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.FullName, pr.Locality, p.DueDate, p.Amount,
           DATEDIFF(DAY, p.DueDate, @AsOfDate) AS DaysOverdue
    FROM dbo.Payments p
    JOIN dbo.Leases l      ON l.LeaseID = p.LeaseID
    JOIN dbo.Tenants t     ON t.TenantID = l.TenantID
    JOIN dbo.Properties pr ON pr.PropertyID = l.PropertyID
    WHERE p.PaidDate IS NULL AND p.DueDate < @AsOfDate
    ORDER BY DaysOverdue DESC;
END;
GO

CREATE PROCEDURE dbo.usp_AgentPerformance @AgentID INT AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.FullName, COUNT(l.LeaseID) AS TotalLeases,
           SUM(l.MonthlyRent) AS TotalMonthlyRent,
           AVG(l.MonthlyRent) AS AvgMonthlyRent
    FROM dbo.Agents a
    LEFT JOIN dbo.Leases l ON l.AgentID = a.AgentID
    WHERE a.AgentID = @AgentID
    GROUP BY a.FullName;
END;
GO

CREATE TABLE dbo.PaymentAudit (
    AuditID     INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID   INT NOT NULL,
    OldPaidDate DATE NULL,
    NewPaidDate DATE NULL,
    ChangedAt   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ChangedBy   NVARCHAR(128) NOT NULL DEFAULT SUSER_SNAME()
);
GO

CREATE TRIGGER dbo.trg_Payments_AuditPaidDate
ON dbo.Payments AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(PaidDate)
        INSERT INTO dbo.PaymentAudit (PaymentID, OldPaidDate, NewPaidDate)
        SELECT d.PaymentID, d.PaidDate, i.PaidDate
        FROM deleted d
        JOIN inserted i ON i.PaymentID = d.PaymentID
        WHERE ISNULL(d.PaidDate, '1900-01-01') <> ISNULL(i.PaidDate, '1900-01-01');
END;
GO

CREATE FUNCTION dbo.fn_TenantPaymentHistory (@TenantID INT)
RETURNS TABLE AS
RETURN (
    SELECT p.PaymentID, l.LeaseID, p.DueDate, p.PaidDate, p.Amount,
           CASE WHEN p.PaidDate IS NULL THEN 'Unpaid'
                WHEN p.PaidDate > p.DueDate THEN 'Late'
                ELSE 'On time' END AS PaymentStatus
    FROM dbo.Payments p
    JOIN dbo.Leases l ON l.LeaseID = p.LeaseID
    WHERE l.TenantID = @TenantID
);
GO


EXEC dbo.usp_MonthlyRevenue @Year = 2026;
EXEC dbo.usp_GetOverduePayments @AsOfDate = '2026-10-21';
EXEC dbo.usp_AgentPerformance @AgentID = 1;
SELECT * FROM dbo.fn_TenantPaymentHistory(5);

-- trigger test: mark one unpaid payment as paid, then check the audit log
UPDATE TOP (1) dbo.Payments SET PaidDate = CAST(GETDATE() AS DATE) WHERE PaidDate IS NULL;
SELECT * FROM dbo.PaymentAudit;


CREATE PROCEDURE dbo.usp_MonthlyRevenue @Year INT AS
BEGIN
    SET NOCOUNT ON;
    SELECT MONTH(PaidDate) AS [Month], SUM(Amount) AS Revenue
    FROM dbo.Payments
    WHERE PaidDate IS NOT NULL AND YEAR(PaidDate) = @Year
    GROUP BY MONTH(PaidDate)
    ORDER BY [Month];
END;
GO

CREATE PROCEDURE dbo.usp_CreateLease
    @PropertyID INT, @TenantID INT, @AgentID INT, @StartDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @Rent DECIMAL(10,2) =
            (SELECT MonthlyRent FROM dbo.Properties WHERE PropertyID = @PropertyID);
        INSERT INTO dbo.Leases (PropertyID, TenantID, AgentID, StartDate, EndDate, MonthlyRent)
        VALUES (@PropertyID, @TenantID, @AgentID, @StartDate, DATEADD(MONTH, 11, @StartDate), @Rent);
        UPDATE dbo.Properties SET Status = 'Leased' WHERE PropertyID = @PropertyID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO




EXEC dbo.usp_MonthlyRevenue @Year = 2026;

-- creates one test lease: property 1, tenant 1, agent 1
EXEC dbo.usp_CreateLease @PropertyID = 1, @TenantID = 1, @AgentID = 1, @StartDate = '2026-11-01';
SELECT TOP 1 * FROM dbo.Leases ORDER BY LeaseID DESC;