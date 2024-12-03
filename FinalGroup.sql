USE Hospitals;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Departments;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE IF NOT EXISTS Departments (
    Dept_ID INT PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    FLOOR INT NOT NULL
    );


# Create the class table
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Employees;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Employees (
    EID INT PRIMARY KEY,
    Name VARCHAR(255),
    Sex VARCHAR(50),
    EmpType VARCHAR(50),
    Phone VARCHAR(15),
    Dept_ID INT,
    Password VARCHAR(255),
    FOREIGN KEY (Dept_ID) REFERENCES Departments(Dept_ID)
);


SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Patients;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Patients (
   PID  VARCHAR(25) PRIMARY KEY,
   Name VARCHAR(25),
   DayOfBirth DATE, 
   Sex ENUM('Male', 'Female'),
   Password VARCHAR(255)
);


SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Appointments;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Appointments (
    Apt_ID INT PRIMARY KEY,
    Start DATE,
    End DATE,
    Type VARCHAR(50),
    PID VARCHAR(25),
    EID INT,
    FOREIGN KEY (PID) REFERENCES Patients(PID),
    FOREIGN KEY (EID) REFERENCES Employees(EID)
);


SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Services;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Services (
    Service_ID INT PRIMARY KEY,
    Service_Name VARCHAR(255), -- but need to have several selections
    Cost DECIMAL(10,2)
);

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Service_Appointment;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Service_Appointment (
    Service_ID INT,
    Apt_ID INT,
    PRIMARY KEY (Service_ID, Apt_ID),
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID),
    FOREIGN KEY (Apt_ID) REFERENCES Appointments(Apt_ID)
);

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Beds;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE Beds (
    Bed_ID INT PRIMARY KEY,
    Room_ID INT,
    Floor INT
);

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Patient_Stay;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE Patient_Stay (
    Bed_ID INT,
    Bill_ID INT PRIMARY KEY,
    PID VARCHAR(25),
    CheckIn DATE,
    CheckOut DATE,
    FOREIGN KEY (Bed_ID) REFERENCES Beds(Bed_ID),
    FOREIGN KEY (PID) REFERENCES Patients(PID)
);

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Billing;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Billing (
    Bill_ID VARCHAR(50),
    Date_Issued DATE,
    Total_Amt DECIMAL(10,2),
    Payment_Status VARCHAR(50),
    Bed_ID INT,
    PID VARCHAR(25),
	PRIMARY KEY (Bed_ID, PID,Bill_ID)   
);


SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Med_Rec;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Med_Rec (
    Med_Rec INT PRIMARY KEY,
    Diagnosis VARCHAR(250),
    Treatments VARCHAR(250),
    Ailment VARCHAR(50),
    medicine VARCHAR(50)
);

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Patient_Rec;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Patient_Rec (
    Rec_ID INT,
    PID VARCHAR(25),
    PRIMARY KEY (Rec_ID, PID)
);