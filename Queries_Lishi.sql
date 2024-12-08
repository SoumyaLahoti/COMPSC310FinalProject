-- create database Hospitals;
-- Checking In a Patient(coco)
USE Hospitals;

-- CALL GetAvailableBeds('double', '2012-01-01 13:00:00');
-- CALL GetAvailableBeds('Single', '2024-01-10 13:00:00');
-- Checking In a Patient(coco)




DELIMITER //
DROP PROCEDURE IF EXISTS GetAvailableBeds;
CREATE PROCEDURE GetAvailableBeds(
    IN preferred_bed_type VARCHAR(10),
    IN check_in_time DATETIME
)
BEGIN
    -- Step 1: Create Bed Types dynamically
    CREATE TEMPORARY TABLE Temp_Bed_Types AS
 SELECT 
  b.Bed_ID,
  b.Room_ID,
  CASE 
   WHEN COUNT(b.Bed_ID) = 1 THEN 'single'
   WHEN COUNT(b.Bed_ID) = 2 THEN 'double'
  END AS Bed_Type
 FROM Beds b
 GROUP BY b.Room_ID;
    
    -- Step 2: Create Active Patient Stay dynamically (with CheckOut is NULL)
    CREATE TEMPORARY TABLE Temp_Active_Patient_Stay AS
    SELECT Bed_ID
    FROM Patient_Stay
    WHERE CheckOut IS NULL;
    -- Step 3: Filter Available Beds by Preferred Type and Check if Bed is available
    SELECT b.Bed_ID, b.Room_ID, b.Bed_Type
    FROM Temp_Bed_Types b
    LEFT JOIN Temp_Active_Patient_Stay aps ON b.Bed_ID = aps.Bed_ID
    WHERE aps.Bed_ID IS NULL  -- Bed is not currently occupied
      AND b.Bed_Type = preferred_bed_type
      AND NOT EXISTS (
          -- Check if there's any overlap with existing patient stay for the desired bed type
          SELECT 1 
          FROM Patient_Stay ps
          WHERE ps.Bed_ID = b.Bed_ID
          AND ps.CheckOut IS NULL
          AND (
              ps.CheckIn <= check_in_time AND (ps.CheckOut IS NULL OR ps.CheckOut >= check_in_time)
          )
      );

    -- Drop temporary tables to clean up
    DROP TEMPORARY TABLE IF EXISTS Temp_Bed_Types;
    DROP TEMPORARY TABLE IF EXISTS Temp_Active_Patient_Stay;
END //

DELIMITER ;

-- CALL GetAvailableBeds('single', '2024-12-05 14:00:00');


-- Patient Search(coco) 

DELIMITER //
DROP PROCEDURE IF EXISTS SearchPatients;
CREATE PROCEDURE SearchPatients(
    IN search_pid VARCHAR(4), 
    IN search_dob DATE,
    IN search_first_name VARCHAR(25), 
    IN search_last_name VARCHAR(25)
)
BEGIN
    SELECT *
    FROM Patients
    WHERE 
        (search_pid IS NULL OR PID = search_pid) AND
        (search_dob IS NULL OR DayOfBirth = search_dob) AND
        (search_first_name IS NULL OR Name LIKE CONCAT('%', search_first_name, '%')) AND
        (search_last_name IS NULL OR Name LIKE CONCAT('%', search_last_name, '%'));
END //

DELIMITER ;

-- CALL SearchPatients('P12345', NULL, NULL, NULL);
-- CALL SearchPatients('P12345', '2000-01-01', NULL, NULL);
-- CALL SearchPatients(NULL, NULL, NULL, NULL);


DELIMITER //








-- SHOW PROCEDURE STATUS LIKE 'GetBillingInfo';
--  CALL GetBillingInfo('P003', '2024-01-01 08:00:00');
 -- SELECT * FROM Services_Availed;




DELIMITER //

-- Drop procedure if it exists
DROP PROCEDURE IF EXISTS GetBillingInfo;

-- Create the procedure
CREATE PROCEDURE GetBillingInfo(
    IN input_PID VARCHAR(4),
    IN input_CheckIn DATETIME
)
BEGIN
    SELECT 
        ps.Bill_ID, 
        ps.PID, 
        ps.CheckIn AS CheckIn_DateTime,
        sa.Start AS Start_Service,
        sa.End AS End_Service,
        s.Service_Name,
        -- Calculate the cost based on Service_ID
        CASE 
            WHEN sa.Service_ID IN ('S017', 'S019') THEN 
            -- reference: https://dev.mysql.com/doc/refman/8.4/en/date-and-time-functions.html
                s.Cost * TIMESTAMPDIFF(SECOND, sa.Start, sa.End) / 3600 -- Cost adjusted by duration in hours
            ELSE 
                s.Cost
        END AS Adjusted_Cost,
        e.Name AS Employee_Name,
        p.Name AS Patient_Name
    FROM 
        Services_Availed sa
    NATURAL JOIN Patient_Stay ps
    NATURAL JOIN Services s
    LEFT JOIN Employees e ON sa.EID = e.EID
    LEFT JOIN Patients p ON ps.PID = p.PID
    WHERE 
        ps.PID = input_PID
        AND ps.CheckIn = input_CheckIn
 -- https://dev.mysql.com/doc/refman/8.4/en/flow-control-functions.html       
        AND (sa.Start BETWEEN ps.CheckIn AND IFNULL(ps.CheckOut, CURRENT_TIMESTAMP)) 
        AND (sa.End BETWEEN ps.CheckIn AND IFNULL(ps.CheckOut, CURRENT_TIMESTAMP));
END //





 CALL GetBillingInfo('P125', '2024-12-01 10:00:00');

-- Occupied Time for Employees(Coco)

DROP TRIGGER IF EXISTS AfterCheckOutUpdate;
DELIMITER //

CREATE TRIGGER AfterCheckOutUpdate
AFTER UPDATE ON Patient_Stay
FOR EACH ROW
BEGIN
    -- Check if the CheckOut date has been updated and is not NULL
    IF OLD.CheckOut IS NULL AND NEW.CheckOut IS NOT NULL THEN
        -- Insert the bed cost service for 'S017' (single) and 'S019' (shared)
        INSERT INTO Services_Availed (PID, Service_ID, Start, End, EID)
        SELECT 
            OLD.PID, 
            CASE 
                WHEN (SELECT COUNT(*) FROM Beds WHERE Room_ID = (SELECT Room_ID FROM Beds WHERE Bed_ID = OLD.Bed_ID)) = 1 THEN 'S017' -- Single bed
                ELSE 'S019' -- Shared bed
            END AS Service_ID,
            OLD.CheckIn AS Start, 
            NEW.CheckOut AS End,
            (SELECT EID FROM Employees WHERE Employee_Role = 'Nurse' LIMIT 1) AS EID -- Assuming 'Nurse' role for EID, adjust based on your business logic
        FROM Patient_Stay
        WHERE PID = OLD.PID AND Bed_ID = OLD.Bed_ID;
    END IF;
END //

DELIMITER ;

-- INSERT INTO Patient_Stay (PID, Bill_ID, Bed_ID, CheckIn, CheckOut)
-- VALUES ('P001', '66002','B001', '2024-12-01 10:00:00', NULL); -- Assuming B001 is an available bed
