-- =====================================================================
-- Queries.sql - Stage B (PostgreSQL)
-- 8 SELECT: S1-S4 written in TWO forms, S5-S8 in one form
-- 3 DELETE, 3 UPDATE
--
-- Variety:  S1 JOIN / IN              S2 NOT IN / NOT EXISTS
--           S3 DIVISION               S4 INTERSECT (intersection)
--           S5 UNION                  S6 window function (RANK)
--           S7 LEFT JOIN              S8 CASE + HAVING + nested subquery
-- =====================================================================


-- =====================================================================
-- S1: Patients who got SPECIAL medications in 2026 (with ward + count)
-- Form A = JOIN        Form B = IN subquery
-- =====================================================================

-- S1 - Form A
SELECT p.ID, p.FirstName, p.LastName, w.WardType,
       COUNT(*) AS prescriptions_count
FROM PATIENT p
JOIN WARD w          ON p.WardID = w.WardID
JOIN PRESCRIPTION pr ON pr.PatientID = p.ID
JOIN SPECIALMED s    ON s.MedicationCode = pr.MedicationCode
WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
GROUP BY p.ID, p.FirstName, p.LastName, w.WardType
ORDER BY prescriptions_count DESC, p.LastName;

-- S1 - Form B
SELECT p.ID, p.FirstName, p.LastName, w.WardType,
       COUNT(*) AS prescriptions_count
FROM PATIENT p
JOIN WARD w          ON p.WardID = w.WardID
JOIN PRESCRIPTION pr ON pr.PatientID = p.ID
WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
  AND pr.MedicationCode IN (SELECT MedicationCode FROM SPECIALMED)
GROUP BY p.ID, p.FirstName, p.LastName, w.WardType
ORDER BY prescriptions_count DESC, p.LastName;


-- =====================================================================
-- S2: Doctors who wrote prescriptions in March 2026 but NO Emergency
--     prescription in that month
-- Form A = NOT IN      Form B = NOT EXISTS
-- =====================================================================

-- S2 - Form A
SELECT d.DoctorID, d.FirstName, d.LastName, d.Specialty,
       COUNT(*) AS prescriptions_in_march
FROM DOCTOR d
JOIN PRESCRIPTION pr ON pr.DoctorID = d.DoctorID
WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
  AND EXTRACT(MONTH FROM pr.DateIssued) = 3
  AND d.DoctorID NOT IN (SELECT DoctorID
                         FROM PRESCRIPTION
                         WHERE UrgencyStatus = 'Emergency'
                           AND EXTRACT(YEAR FROM DateIssued) = 2026
                           AND EXTRACT(MONTH FROM DateIssued) = 3)
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialty
ORDER BY prescriptions_in_march DESC, d.LastName;

-- S2 - Form B
SELECT d.DoctorID, d.FirstName, d.LastName, d.Specialty,
       COUNT(*) AS prescriptions_in_march
FROM DOCTOR d
JOIN PRESCRIPTION pr ON pr.DoctorID = d.DoctorID
WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
  AND EXTRACT(MONTH FROM pr.DateIssued) = 3
  AND NOT EXISTS (SELECT 1
                  FROM PRESCRIPTION pr2
                  WHERE pr2.DoctorID = d.DoctorID
                    AND pr2.UrgencyStatus = 'Emergency'
                    AND EXTRACT(YEAR FROM pr2.DateIssued) = 2026
                    AND EXTRACT(MONTH FROM pr2.DateIssued) = 3)
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialty
ORDER BY prescriptions_in_march DESC, d.LastName;


-- =====================================================================
-- S3: DIVISION - patients who received prescriptions of EVERY urgency level
--     (Routine, Urgent and Emergency) in 2026
-- Form A = double NOT EXISTS ("there is no urgency level the patient did not get")
-- Form B = GROUP BY + HAVING COUNT(DISTINCT) = number of urgency levels
-- =====================================================================

-- S3 - Form A
SELECT p.ID, p.FirstName, p.LastName, w.WardType
FROM PATIENT p
JOIN WARD w ON w.WardID = p.WardID
WHERE NOT EXISTS (
        SELECT 1
        FROM (SELECT DISTINCT UrgencyStatus FROM PRESCRIPTION) u
        WHERE NOT EXISTS (
                SELECT 1
                FROM PRESCRIPTION pr
                WHERE pr.PatientID = p.ID
                  AND pr.UrgencyStatus = u.UrgencyStatus
                  AND EXTRACT(YEAR FROM pr.DateIssued) = 2026))
ORDER BY w.WardType, p.LastName;

-- S3 - Form B
SELECT p.ID, p.FirstName, p.LastName, w.WardType
FROM PATIENT p
JOIN WARD w          ON w.WardID = p.WardID
JOIN PRESCRIPTION pr ON pr.PatientID = p.ID
WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
GROUP BY p.ID, p.FirstName, p.LastName, w.WardType
HAVING COUNT(DISTINCT pr.UrgencyStatus) =
       (SELECT COUNT(DISTINCT UrgencyStatus) FROM PRESCRIPTION)
ORDER BY w.WardType, p.LastName;


-- =====================================================================
-- S4: INTERSECT - patients who got BOTH a refrigerated medication AND a
--     special medication in the first half of 2026
-- Form A = INTERSECT        Form B = two IN subqueries
-- =====================================================================

-- S4 - Form A
SELECT p.ID, p.FirstName, p.LastName, p.Phone
FROM PATIENT p
JOIN PRESCRIPTION pr ON pr.PatientID = p.ID
JOIN FRIDGEMED f     ON f.MedicationCode = pr.MedicationCode
WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
  AND EXTRACT(MONTH FROM pr.DateIssued) <= 6
INTERSECT
SELECT p.ID, p.FirstName, p.LastName, p.Phone
FROM PATIENT p
JOIN PRESCRIPTION pr ON pr.PatientID = p.ID
JOIN SPECIALMED s    ON s.MedicationCode = pr.MedicationCode
WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
  AND EXTRACT(MONTH FROM pr.DateIssued) <= 6
ORDER BY LastName, FirstName;

-- S4 - Form B
SELECT p.ID, p.FirstName, p.LastName, p.Phone
FROM PATIENT p
WHERE p.ID IN (SELECT pr.PatientID
               FROM PRESCRIPTION pr
               JOIN FRIDGEMED f ON f.MedicationCode = pr.MedicationCode
               WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
                 AND EXTRACT(MONTH FROM pr.DateIssued) <= 6)
  AND p.ID IN (SELECT pr.PatientID
               FROM PRESCRIPTION pr
               JOIN SPECIALMED s ON s.MedicationCode = pr.MedicationCode
               WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
                 AND EXTRACT(MONTH FROM pr.DateIssued) <= 6)
ORDER BY p.LastName, p.FirstName;


-- =====================================================================
-- S5: UNION - one alert list for the warehouse: medications with LOW STOCK
--     together with medications EXPIRING in the first half of 2027
--     (alert_type says why the medication is in the list)
-- =====================================================================
SELECT 'Low stock' AS alert_type, m.MedName, m.Dosage,
       w.QuantityInStock, w.ExpirationDate
FROM MEDICATION m
JOIN MEDWAREHOUSE w ON w.InventoryID = m.InventoryID
WHERE w.QuantityInStock < w.MinimumThreshold
UNION
SELECT 'Expiring soon' AS alert_type, m.MedName, m.Dosage,
       w.QuantityInStock, w.ExpirationDate
FROM MEDICATION m
JOIN MEDWAREHOUSE w ON w.InventoryID = m.InventoryID
WHERE EXTRACT(YEAR FROM w.ExpirationDate) = 2027
  AND EXTRACT(MONTH FROM w.ExpirationDate) <= 6
ORDER BY alert_type, ExpirationDate, MedName;


-- =====================================================================
-- S6: WINDOW FUNCTION - the top 3 doctors (by number of prescriptions in
--     2026) inside each specialty
-- =====================================================================
SELECT t.Specialty, t.rank_in_specialty, t.DoctorID,
       t.FirstName, t.LastName, t.prescriptions_count
FROM (SELECT d.Specialty, d.DoctorID, d.FirstName, d.LastName,
             COUNT(*) AS prescriptions_count,
             RANK() OVER (PARTITION BY d.Specialty
                          ORDER BY COUNT(*) DESC) AS rank_in_specialty
      FROM DOCTOR d
      JOIN PRESCRIPTION pr ON pr.DoctorID = d.DoctorID
      WHERE EXTRACT(YEAR FROM pr.DateIssued) = 2026
      GROUP BY d.Specialty, d.DoctorID, d.FirstName, d.LastName) t
WHERE t.rank_in_specialty <= 3
ORDER BY t.Specialty, t.rank_in_specialty, t.LastName;


-- =====================================================================
-- S7: LEFT JOIN - every ward (even wards with no emergencies): number of
--     patients and number of Emergency prescriptions issued in days 1-15 of March 2026
-- =====================================================================
SELECT w.WardID, w.WardType, w.Floor,
       COUNT(DISTINCT p.ID)         AS patients_count,
       COUNT(pr.PrescriptionCode)   AS emergency_prescriptions
FROM WARD w
LEFT JOIN PATIENT p       ON p.WardID = w.WardID
LEFT JOIN PRESCRIPTION pr ON pr.PatientID = p.ID
                         AND pr.UrgencyStatus = 'Emergency'
                         AND EXTRACT(YEAR FROM pr.DateIssued) = 2026
                         AND EXTRACT(MONTH FROM pr.DateIssued) = 3
                         AND EXTRACT(DAY FROM pr.DateIssued) <= 15
GROUP BY w.WardID, w.WardType, w.Floor
ORDER BY emergency_prescriptions DESC, w.WardType;


-- =====================================================================
-- S8: CASE + HAVING + nested subquery - pharmacists with a monthly number of
--     dispensings above the average pharmacist-month in 2026, with the
--     percentage of completed dispensings
-- =====================================================================
SELECT d.PharmacistName,
       EXTRACT(MONTH FROM d.DispenseDate) AS month_number,
       COUNT(*)                           AS total_dispensings,
       SUM(CASE WHEN d.DispenseStatus = 'Completed' THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN d.DispenseStatus = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
       ROUND(100.0 * SUM(CASE WHEN d.DispenseStatus = 'Completed' THEN 1 ELSE 0 END)
             / COUNT(*), 1)               AS completion_percent
FROM DISPENSING d
WHERE EXTRACT(YEAR FROM d.DispenseDate) = 2026
GROUP BY d.PharmacistName, EXTRACT(MONTH FROM d.DispenseDate)
HAVING COUNT(*) > (SELECT COUNT(*) * 1.0 /
                          COUNT(DISTINCT (PharmacistName, EXTRACT(MONTH FROM DispenseDate)))
                   FROM DISPENSING
                   WHERE EXTRACT(YEAR FROM DispenseDate) = 2026)
ORDER BY month_number, completion_percent DESC;



-- =====================================================================
-- S9 (BONUS): Warehouse FORECAST - for every warehouse batch, will it RUN OUT
--     soon, or will it EXPIRE before it is used?
--   Step 1 (usage):    how much of each batch was requested in the LAST 3 MONTHS
--                      -> average monthly usage = total / 3
--   Step 2 (forecast): how many months the current stock will last at that
--                      rate, and how many months remain until the expiration date
--   Step 3 (final):    CASE compares the two numbers and gives a risk status
-- Batches with no prescriptions in the last 3 months have no usage rate,
-- so they are not part of the forecast.
-- Screen: "Warehouse" / "Smart inventory forecast"
-- =====================================================================
WITH usage AS (
    SELECT m.InventoryID,
           COUNT(DISTINCT m.MedicationCode) AS medications_count,
           SUM(pr.QuantityRequested)        AS requested_last_3_months
    FROM MEDICATION m
    JOIN PRESCRIPTION pr ON pr.MedicationCode = m.MedicationCode
    WHERE pr.DateIssued >= CURRENT_DATE - INTERVAL '3 months'
      AND pr.DateIssued <= CURRENT_DATE
    GROUP BY m.InventoryID
),
forecast AS (
    SELECT w.InventoryID, w.BatchNumber, w.QuantityInStock, w.ExpirationDate,
           u.medications_count,
           ROUND(u.requested_last_3_months / 3.0, 1)                       AS avg_monthly_usage,
           ROUND(w.QuantityInStock / (u.requested_last_3_months / 3.0), 1) AS months_of_stock_left,
           ROUND((w.ExpirationDate - CURRENT_DATE) / 30.0, 1)              AS months_until_expiry
    FROM MEDWAREHOUSE w
    JOIN usage u ON u.InventoryID = w.InventoryID
)
SELECT InventoryID, BatchNumber, medications_count, QuantityInStock,
       avg_monthly_usage, months_of_stock_left, months_until_expiry,
       CASE
           WHEN months_until_expiry < 0                      THEN 'Already expired'
           WHEN months_of_stock_left < 1                     THEN 'Will run out within a month'
           WHEN months_of_stock_left > months_until_expiry   THEN 'Will expire before it is used'
           ELSE 'OK'
       END AS risk_status
FROM forecast
ORDER BY risk_status, months_of_stock_left;


-- =====================================================================
-- DELETE queries  (run D1 before D3)
-- =====================================================================

-- D1: Delete DRAWN_FROM rows of cancelled dispensings from Jan-Mar 2026
DELETE FROM DRAWN_FROM
WHERE DispenseID IN (SELECT DispenseID
                     FROM DISPENSING
                     WHERE DispenseStatus = 'Cancelled'
                       AND EXTRACT(YEAR FROM DispenseDate) = 2026
                       AND EXTRACT(MONTH FROM DispenseDate) <= 3);

-- D2: Delete cancelled prescriptions of regular medications that were never
--     dispensed, issued in Jan-Feb 2026
DELETE FROM PRESCRIPTION
WHERE Status = 'Cancelled'
  AND DispenseID IS NULL
  AND EXTRACT(YEAR FROM DateIssued) = 2026
  AND EXTRACT(MONTH FROM DateIssued) <= 2
  AND MedicationCode IN (SELECT MedicationCode FROM REGULARMED);

-- D3: Delete cancelled 2026 dispensings that no prescription and no
--     DRAWN_FROM row refers to (so no foreign key error)
DELETE FROM DISPENSING
WHERE DispenseStatus = 'Cancelled'
  AND EXTRACT(YEAR FROM DispenseDate) = 2026
  AND DispenseID NOT IN (SELECT DispenseID FROM PRESCRIPTION
                         WHERE DispenseID IS NOT NULL)
  AND DispenseID NOT IN (SELECT DispenseID FROM DRAWN_FROM);


-- =====================================================================
-- UPDATE queries
-- =====================================================================

-- U1: Cancel 'Pending' prescriptions of regular medications issued Jan-Apr 2026
UPDATE PRESCRIPTION
SET Status = 'Cancelled'
WHERE Status = 'Pending'
  AND EXTRACT(YEAR FROM DateIssued) = 2026
  AND EXTRACT(MONTH FROM DateIssued) <= 4
  AND MedicationCode IN (SELECT MedicationCode FROM REGULARMED);

-- U2: Raise the minimum threshold by 20% for warehouse batches of special
--     medications that expire in 2027
UPDATE MEDWAREHOUSE
SET MinimumThreshold = ROUND(MinimumThreshold * 1.2)
WHERE EXTRACT(YEAR FROM ExpirationDate) = 2027
  AND InventoryID IN (SELECT m.InventoryID
                      FROM MEDICATION m
                      JOIN SPECIALMED s ON s.MedicationCode = m.MedicationCode);

-- U3: Mark 'Completed' January 2026 dispensings as 'Partially Dispensed'
--     when less was dispensed than the prescriptions requested
UPDATE DISPENSING
SET DispenseStatus = 'Partially Dispensed'
WHERE DispenseStatus = 'Completed'
  AND EXTRACT(YEAR FROM DispenseDate) = 2026
  AND EXTRACT(MONTH FROM DispenseDate) = 1
  AND QuantityDispensed < (SELECT SUM(pr.QuantityRequested)
                           FROM PRESCRIPTION pr
                           WHERE pr.DispenseID = DISPENSING.DispenseID);
