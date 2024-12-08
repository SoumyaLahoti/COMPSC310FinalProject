-- Query 1: The hospital need sto downsize, fire 10% of all staff from the most populated departments. 

WITH StaffCount AS (
    SELECT
        e.Dept_ID,
        d.Name AS DName,
        COUNT(*) AS Total_Staff,
        COUNT(CASE WHEN e.EmpType = 'Doctor' THEN 1 END) AS Docs,
        COUNT(CASE WHEN e.EmpType = 'Nurse' THEN 1 END) AS Nurs
    FROM
        Employees e
    JOIN
        Department d ON e.Dept_ID = d.Dept_ID
    GROUP BY
        e.Dept_ID, d.Name
),
TooManyPpl AS(
    SELECT
        e.Employee_ID,
        e.Name AS EName,
        e.EmpType,
        d.Name AS DName,
        ROW_NUMBER() OVER (PARTITION BY e.Dept_ID, e.EmpType ORDER BY e.Employee_ID) AS RN -- this works maybe pls work, fdoes ot work
    FROM
        Employees e
    JOIN
        HsptlPpl sc ON e.Dept_ID = sc.Dept_ID
    WHERE
        sc.Docs >= 1 AND sc.Nurs >= 1
)
SELECT
    EName,
    DName
FROM 
    StaffToFire
WHERE
    RN <= 0.1 * (SELECT COUNT(*) FROM Employees);
    
SELECT EName, DName
FROM TooManyPpl
WHERE EmpType = 'Doctor';

SELECT EName, DName
FROM TooManyPpl
WHERE EmpType = 'Nurse';

SELECT EName, DName
FROM TooManyPpl;

-- Query 2: Harmonize the Employee Table by popping 'Dr.' and then creating a new column prefix where we have (Dr., Ms., Mr.) 
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE Employees ADD COLUMN Suffix VARCHAR(5);
UPDATE Employees
SET 
    Suffix = 'Dr.',
    Name = SUBSTRING(Name, 5) -- Removes "Dr. " from the start of the name
WHERE EmpType = 'Doctor' AND Name LIKE 'Dr.%';

UPDATE Employees
SET 
    Suffix = 'Mr.'
WHERE EmpType = 'nurse' AND Sex = 'Male';

UPDATE Employees
SET 
    Suffix = 'Ms.'
WHERE EmpType = 'nurse' AND Sex = 'Female';
SELECT * from Employees;

-- Query 3: All work done before 9 am and after 5 pm, even work that started before 5pm but ended after 5pm is charged at a rate of 1.2x the service charge overtime.

CREATE VIEW extrawork AS
SELECT
    sa.PID,
    sa.Service_ID,
    s.Service_Name,
    s.Type,
    s.Cost AS Normal_Cost,
    CASE
        WHEN HOUR(sa.Start_Time) < 9
          OR HOUR(sa.Start_Time) >= 17
          OR (HOUR(sa.Start_Time) = 16 AND MINUTE(sa.Start_Time) > 0) -- 16:01 to 16:59, all services last an hour but spilling into overtime is still chargeable.
        THEN s.Cost * 1.2
        ELSE s.Cost
    END AS Final_Cost,
    sa.Start_Time
FROM
    Services_Availed sa
JOIN
    Services s ON sa.Service_ID = s.Service_ID;

-- Query 4: The hospital has grown, we have too many patients that the Primary key Patient_ID does not have space (P001 can only accommodate 999 elements till P999)
-- When we get to this point on the 1000th one, create a TRIGGER so that the primary key format is changes to S0001/E0001 so we can now accommodate 9999 elements in a table uniquely.
-- TRIGGER will also change every relevant table. This is too complicated to do. Alternatvely we can just contnue on as S1000, S1001, and S001, S999 instead of S0001. We will change the primary key constraints otherwise.

-- Query 5: Duration should autofill when we select service. All services last 1 hour.