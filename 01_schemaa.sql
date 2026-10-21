CREATE TABLE dbo.Agents (
    AgentID   INT IDENTITY(1,1) PRIMARY KEY,
    FullName  NVARCHAR(100) NOT NULL,
    Email     NVARCHAR(150) NOT NULL UNIQUE,
    HireDate  DATE NOT NULL
);

CREATE TABLE dbo.Properties (
    PropertyID   INT IDENTITY(1,1) PRIMARY KEY,
    Locality     NVARCHAR(80) NOT NULL,
    PropertyType NVARCHAR(20) NOT NULL
        CHECK (PropertyType IN ('Apartment','Villa','Office','Shop')),
    AreaSqFt     INT NOT NULL CHECK (AreaSqFt > 0),
    MonthlyRent  DECIMAL(10,2) NOT NULL CHECK (MonthlyRent > 0),
    Status       NVARCHAR(15) NOT NULL DEFAULT 'Available'
        CHECK (Status IN ('Available','Leased','Maintenance'))
);

CREATE TABLE dbo.Tenants (
    TenantID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Phone    NVARCHAR(15) NULL,
    Email    NVARCHAR(150) NULL
);

CREATE TABLE dbo.Leases (
    LeaseID     INT IDENTITY(1,1) PRIMARY KEY,
    PropertyID  INT NOT NULL REFERENCES dbo.Properties(PropertyID),
    TenantID    INT NOT NULL REFERENCES dbo.Tenants(TenantID),
    AgentID     INT NOT NULL REFERENCES dbo.Agents(AgentID),
    StartDate   DATE NOT NULL,
    EndDate     DATE NOT NULL,
    MonthlyRent DECIMAL(10,2) NOT NULL,
    CHECK (EndDate > StartDate)
);

CREATE TABLE dbo.Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    LeaseID   INT NOT NULL REFERENCES dbo.Leases(LeaseID),
    DueDate   DATE NOT NULL,
    PaidDate  DATE NULL,
    Amount    DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.MaintenanceRequests (
    RequestID    INT IDENTITY(1,1) PRIMARY KEY,
    PropertyID   INT NOT NULL REFERENCES dbo.Properties(PropertyID),
    Category     NVARCHAR(20) NOT NULL,
    RaisedDate   DATE NOT NULL,
    ResolvedDate DATE NULL,
    Cost         DECIMAL(10,2) NOT NULL
);