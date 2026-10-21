# Property Rental Management Database (SQL Server)

A T-SQL database for a real-estate rental company. It tracks agents, properties, tenants, leases, rent payments and maintenance requests, and includes analytical queries, views, stored procedures, a trigger, a function and an indexing performance test.

**Note:** all data is **synthetic**, generated with a T-SQL script for practice. It is not real customer data.

## Tech

SQL Server 2022 Developer Edition, T-SQL, SQL Server Management Studio (SSMS)

## Database design

7 tables with primary keys, foreign keys, `CHECK` constraints, `UNIQUE` and `DEFAULT` rules.

| Table | Purpose | Rows |
|---|---|---|
| Agents | Rental agents | 10 |
| Properties | Apartments, villas, offices, shops across 8 Pune localities | 500 |
| Tenants | Tenant details | 800 |
| Leases | Lease agreements linking property, tenant and agent | 5,000 |
| Payments | Monthly rent due and paid dates | 55,000 |
| MaintenanceRequests | Repair requests and costs | 3,000 |
| PaymentAudit | Audit log filled by a trigger | - |

## What is included

| Object | Count | Details |
|---|---|---|
| Analytical queries | 8 | Joins, `GROUP BY`/`HAVING`, CTEs, subqueries, window functions (`LAG`, `RANK`) |
| Views | 2 | `vw_OverduePayments`, `vw_MonthlyRevenue` |
| Stored procedures | 4 | `usp_MonthlyRevenue`, `usp_CreateLease` (transaction with `TRY/CATCH` and rollback), `usp_GetOverduePayments`, `usp_AgentPerformance` |
| Trigger | 1 | `trg_Payments_AuditPaidDate` logs every change to `Payments.PaidDate` |
| Table-valued function | 1 | `fn_TenantPaymentHistory` returns a tenant's payments with On time / Late / Unpaid status |
| Index | 1 | Covering nonclustered index `IX_Payments_DueDate` |

## Index performance test

Query tested (payments due in the first half of 2025):

```sql
SELECT PaidDate, SUM(Amount) AS Total
FROM dbo.Payments
WHERE DueDate BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY PaidDate;
```

Index added:

```sql
CREATE NONCLUSTERED INDEX IX_Payments_DueDate
ON dbo.Payments (DueDate) INCLUDE (PaidDate, Amount);
```

| | Logical reads (table `Payments`) |
|---|---|
| Before index | 219 |
| After covering index | 35 |

Logical reads dropped by about **84%**. Measured with `SET STATISTICS IO ON`.

**Before the index:**

![Before index](indexing/before_messages.png)

**After the index:**

![After index](indexing/after_messages.png)

Elapsed time was only a few milliseconds in both runs because the table is small, so logical reads is the metric used here.

## Results from the synthetic data

- 5,498 unpaid payments flagged as overdue by `vw_OverduePayments`
- The generated leases run for 11 months from 2023-2025 start dates, so most have expired. Occupancy and revenue trends reflect this and are not realistic business patterns.

## Repository structure

```
property-rental-sql-server/
├── README.md
├── 01_schema.sql
├── 02_sample_data.sql
├── 03_queries.sql
├── 04_views.sql
├── 05_stored_procedures.sql
├── 06_trigger_function.sql
├── 07_index_test.sql
└── indexing/
    ├── before_messages.png
    └── after_messages.png
```

## How to run

1. Install SQL Server Developer Edition and SSMS.
2. Create the database: `CREATE DATABASE RealEstateDB;`
3. Run the scripts in order, from `01_schema.sql` to `07_index_test.sql`, with `RealEstateDB` selected.

## Planned next

- SSRS paginated report for monthly revenue
- Python (Pandas) analysis connected to the database
- Power BI dashboard on top of the views

## Author

Arpita Kadtane, Pune, Maharashtra
