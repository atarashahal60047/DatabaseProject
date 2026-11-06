CREATE TABLE WARD
(
    WardID INT NOT NULL,
    Floor INT NOT NULL CHECK (Floor > -7 AND Floor < 10), 
    WardType VARCHAR(50) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0), 
    HeadNumID CHAR(9) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    PRIMARY KEY (WardID)
);

CREATE TABLE PATIENT
(
  ID CHAR(9) NOT NULL, 
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  DateOfBirth DATE NOT NULL, 
  Gender VARCHAR(10) NOT NULL DEFAULT 'Female' CHECK (Gender IN ('Male', 'Female')),
  Phone VARCHAR(15) NOT NULL,
  Address VARCHAR(100) NOT NULL,
  WardID INT NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (WardID) REFERENCES WARD(WardID)
);

CREATE TABLE DOCTOR
(
  DoctorID CHAR(9) NOT NULL,
  LicenseNum VARCHAR(20) NOT NULL,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  Specialty VARCHAR(50) NOT NULL,
  Phone VARCHAR(15) NOT NULL,
  Email VARCHAR(50) NOT NULL,
  PRIMARY KEY (DoctorID)
);

CREATE TABLE MEDWAREHOUSE
(
  InventoryID INT NOT NULL,
  QuantityInStock INT NOT NULL CHECK (QuantityInStock >= 0),     
  MinimumThreshold INT NOT NULL,
  BatchNumber VARCHAR(50) NOT NULL,
  ExpirationDate DATE NOT NULL, 
  PRIMARY KEY (InventoryID)
);

CREATE TABLE MEDICATION
(
  MedicationCode INT NOT NULL,
  MedName VARCHAR(50) NOT NULL,
  Dosage VARCHAR(50) NOT NULL,
  Form VARCHAR(50) NOT NULL,
  StorageLocation VARCHAR(50) NOT NULL,
  InventoryID INT NOT NULL,
  PRIMARY KEY (MedicationCode),
  FOREIGN KEY (InventoryID) REFERENCES MEDWAREHOUSE(InventoryID)
);

CREATE TABLE DISPENSING
(
  DispenseID INT NOT NULL,
  PharmacistName VARCHAR(50) NOT NULL,
  DispenseDate DATE NOT NULL,  
  QuantityDispensed INT NOT NULL CHECK (QuantityDispensed > 0), -- אילוץ: חייבים לנפק לפחות 1
  DispenseStatus VARCHAR(20) NOT NULL,
  PRIMARY KEY (DispenseID)
);

CREATE TABLE REGULARMED
(
  MedicationCode INT NOT NULL,
  PRIMARY KEY (MedicationCode),
  FOREIGN KEY (MedicationCode) REFERENCES MEDICATION(MedicationCode)
);

CREATE TABLE FRIDGEMED
(
  MedicationCode INT NOT NULL,
  TempRange VARCHAR(20) NOT NULL,
  FridgeID VARCHAR(20) NOT NULL,
  PRIMARY KEY (MedicationCode),
  FOREIGN KEY (MedicationCode) REFERENCES MEDICATION(MedicationCode)
);

CREATE TABLE SPECIALMED
(
  MedicationCode INT NOT NULL,
  SafeCode VARCHAR(50) NOT NULL,
  PRIMARY KEY (MedicationCode),
  FOREIGN KEY (MedicationCode) REFERENCES MEDICATION(MedicationCode)
);

CREATE TABLE PRESCRIPTION
(
  PrescriptionCode INT NOT NULL,
  DateIssued DATE NOT NULL,
  DoseInstructions VARCHAR(255) NOT NULL,
  QuantityRequested INT NOT NULL CHECK (QuantityRequested > 0),
  UrgencyStatus VARCHAR(20) NOT NULL,
  Status VARCHAR(20) NOT NULL,
  PatientID VARCHAR(9) NOT NULL,  
  DoctorID VARCHAR(20) NOT NULL,  
  DispenseID INT,
  MedicationCode INT NOT NULL,
  PRIMARY KEY (PrescriptionCode),
  FOREIGN KEY (PatientID) REFERENCES PATIENT(ID),
  FOREIGN KEY (DoctorID) REFERENCES DOCTOR(DoctorID),
  FOREIGN KEY (DispenseID) REFERENCES DISPENSING(DispenseID),
  FOREIGN KEY (MedicationCode) REFERENCES MEDICATION(MedicationCode)
);

CREATE TABLE DRAWN_FROM
(
  DispenseID INT NOT NULL,
  InventoryID INT NOT NULL,
  PRIMARY KEY (DispenseID, InventoryID),
  FOREIGN KEY (DispenseID) REFERENCES DISPENSING(DispenseID),
  FOREIGN KEY (InventoryID) REFERENCES MEDWAREHOUSE(InventoryID)
);