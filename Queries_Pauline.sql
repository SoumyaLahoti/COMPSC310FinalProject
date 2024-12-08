show tables;
 
 -- Create Billing Trigger
 /*
 This trigger occurs after the CheckOut date is updated in PatientStay.
 This is equivalent to the patient checking out, at which point we need to generate a bill in the Bills Table.
 Check_Out time is updated in Patient_Stay. 
 Bill_ID is created through auto increment. 
 Date_Issued is the current time. 
 Total_Amt is the most complicated step, which is calculated through adding up all services used by this patient 
 between CheckIn time and CheckOut time (from Services_Availed). 
 Payment_Status is set to unpaid (as it would be updated to paid at a later date when the patient pays the bill). 

 */
DELIMITER $$

CREATE TRIGGER after_patient_checkout
AFTER UPDATE ON Patient_Stay
FOR EACH ROW
BEGIN
    DECLARE total_amount DECIMAL(10, 0);

    -- Check if CheckOut time was updated from NULL to a non-NULL value
    IF OLD.CheckOut IS NULL AND NEW.CheckOut IS NOT NULL THEN
        
        -- Calculate the total cost of services availed during the stay
        SELECT COALESCE(SUM(Services.Cost), 0)
        INTO total_amount
        FROM Services_Availed
        JOIN Services ON Services_Availed.Service_ID = Services.Service_ID
        WHERE Services_Availed.PID = NEW.PID
          AND Services_Availed.Start >= NEW.CheckIn
          AND Services_Availed.End <= NEW.CheckOut;

        -- Insert the new billing record (Bill_ID auto-generated)
        INSERT INTO Billing (Date_Issued, Total_Amt, Payment_Status, Bed_ID, PID)
        VALUES (NOW(), total_amount, 'Unpaid', NEW.Bed_ID, NEW.PID);
    END IF;
END$$

DELIMITER ;


 
 
 -- Patient Page
  -- Show the values for a specific patient in the patient table.
DELIMITER $$

CREATE PROCEDURE GetPatientDetails(IN patient_id VARCHAR(10))
BEGIN
    SELECT * FROM patients
    WHERE Patient_ID = patient_id;
END $$

DELIMITER ;
  
  -- Update/change the value for any attribute.
DELIMITER $$

CREATE PROCEDURE UpdatePatientAttribute(IN patient_id VARCHAR(10), IN attribute_name VARCHAR(50), IN new_value VARCHAR(255))
BEGIN
    SET @sql_query = CONCAT('UPDATE patients SET ', attribute_name, ' = "', new_value, '" WHERE Patient_ID = "', patient_id, '"');
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;
  
  
  -- Show all bills for a specific patient.
DELIMITER $$

CREATE PROCEDURE GetBillsForPatient(IN patient_id VARCHAR(10))
BEGIN
    SELECT * FROM bills
    WHERE Patient_ID = patient_id;
END $$

DELIMITER ;
  
  -- Show all medical records for a specific patient
DELIMITER $$

CREATE PROCEDURE GetMedicalRecordsForPatient(IN patient_id VARCHAR(10))
BEGIN
    SELECT * FROM medical_records
    WHERE Patient_ID = patient_id;
END $$

DELIMITER ;
 
 -- Permitted
DELIMITER $$

CREATE PROCEDURE Permitted(IN particular_serviceID VARCHAR(10))
BEGIN
    SELECT EmployeeName
    FROM Employ_Serv
    WHERE ServiceID = particular_serviceID;
END$$

DELIMITER ;
 
 
 -- Filter Employees based on sex, dept, emp_type
 DELIMITER $$

CREATE PROCEDURE FilterEmployees(
    IN input_sex VARCHAR(50),      -- Optional parameter for sex
    IN input_dept VARCHAR(4),      -- Optional parameter for department
    IN input_type ENUM('Doctor', 'Nurse') -- Optional parameter for employee type
)
BEGIN
    -- Filter based on non-null input criteria
    SELECT *
    FROM Employees
    WHERE (input_sex IS NULL OR Sex = input_sex)
      AND (input_dept IS NULL OR Dept_ID = input_dept)
      AND (input_type IS NULL OR EmpType = input_type);
END$$

DELIMITER ;
 
 
 
 -- Add to Services_Availed
 DELIMITER $$

CREATE PROCEDURE AddServiceAvailed(
    IN input_PID VARCHAR(4),
    IN input_EID VARCHAR(4),
    IN input_Service_ID VARCHAR(4),
    IN input_Start_Time DATETIME,
    IN input_duration INT   -- Duration in minutes (optional)
)
BEGIN
    DECLARE end_time_value DATETIME;

    -- Calculate end time if duration is provided, otherwise set it to NULL
    IF input_duration IS NOT NULL THEN
        SET end_time_value = DATE_ADD(input_Start_Time, INTERVAL input_duration MINUTE);
    ELSE
        SET end_time_value = NULL;
    END IF;

    -- Insert the new record into Services_Availed
    INSERT INTO Services_Availed (Start, End, PID, EID, Service_ID)
    VALUES (input_Start_Time, end_time_value, input_PID, input_EID, input_Service_ID);
END$$

DELIMITER ;
 
 
 




