# פרויקט בבסיסי נתונים: מערכת ניהול בית מרקחת בבית חולים
**מגישות:** הודיה אריאל ועטרה שחל

## קישור- https://ai.studio/apps/d51ad7f2-c96a-4964-867f-897af97771a4

## איפיון המערכת - צילומי מסך
להלן צילומי המסך של 4 מסכי המערכת שאופיינו:

### 1. מסך ראשי (Dashboard)
<img width="314" height="383" alt="image" src="https://github.com/user-attachments/assets/508b52e0-500d-4846-8f8d-3a5390931498" />

### 2. מסך ניהול תרופות ומלאי (Medications & Inventory)
<img width="308" height="347" alt="image" src="https://github.com/user-attachments/assets/e4bf7b2e-86fd-4097-a95e-4a5511ed1df9" />

### 3. מסך ניהול מרשמים (Prescriptions)
<img width="307" height="258" alt="image" src="https://github.com/user-attachments/assets/aee21311-4831-4526-b922-3bd6a5f2e277" />

### 4. מסך חלוקה וניפוק (Dispensing)
<img width="311" height="233" alt="image" src="https://github.com/user-attachments/assets/fb8cc37f-a5bd-405d-8af7-501af3a7656b" />




<img width="4512" height="1797" alt="erdplus (1)" src="https://github.com/user-attachments/assets/65b5b212-355f-45c8-b051-0890088220eb" />




## 1. מילון נתונים (Data Dictionary)

### טבלת מחלקות (WARD)
| שם השדה | סוג נתון | מפתח | תיאור השדה |
| :--- | :--- | :--- | :--- |
| `WardID` | INT | PK | מזהה חד-חד ערכי של המחלקה |
| `Floor` | INT | - | מספר הקומה בה נמצאת המחלקה (בין 7- ל-10) |
| `WardType` | VARCHAR(50) | - | סוג המחלקה (למשל: כירורגיה, פנימית) |
| `Capacity` | INT | - | קיבולת המטופלים המקסימלית (גדול מ-0) |
| `HeadNumID` | CHAR(9) | - | תעודת הזהות של מנהל המחלקה |
| `Phone` | VARCHAR(15) | - | מספר טלפון ליצירת קשר עם המחלקה |

### טבלת מטופלים (PATIENT)
| שם השדה | סוג נתון | מפתח | תיאור השדה |
| :--- | :--- | :--- | :--- |
| `ID` | CHAR(9) | PK | תעודת זהות של המטופל |
| `FirstName` | VARCHAR(50) | - | שם פרטי של המטופל |
| `LastName` | VARCHAR(50) | - | שם משפחה של המטופל |
| `DateOfBirth` | DATE | - | תאריך לידה של המטופל |
| `Gender` | VARCHAR(10) | - | מגדר (Male / Female, ברירת מחדל: Female) |
| `Phone` | VARCHAR(15) | - | מספר טלפון אישי |
| `Address` | VARCHAR(100) | - | כתובת מגורים |
| `WardID` | INT | FK | מזהה המחלקה שבה המטופל מאושפז |

### טבלת רופאים (DOCTOR)
| שם השדה | סוג נתון | מפתח | תיאור השדה |
| :--- | :--- | :--- | :--- |
| `DoctorID` | CHAR(9) | PK | תעודת זהות של הרופא |
| `LicenseNum` | VARCHAR(20) | - | מספר רישיון רפואי |
| `FirstName` | VARCHAR(50) | - | שם פרטי של הרופא |
| `LastName` | VARCHAR(50) | - | שם משפחה של הרופא |
| `Specialty` | VARCHAR(50) | - | התמחות רפואית |
| `Phone` | VARCHAR(15) | - | מספר טלפון ליצירת קשר |
| `Email` | VARCHAR(50) | - | כתובת אימייל מקצועית |

### טבלת מחסן תרופות (MEDWAREHOUSE)
| שם השדה | סוג נתון | מפתח | תיאור השדה |
| :--- | :--- | :--- | :--- |
| `InventoryID` | INT | PK | מזהה פריט במלאי |
| `QuantityInStock` | INT | - | כמות במלאי (חייב להיות גדול או שווה ל-0) |
| `MinimumThreshold` | INT | - | רף מינימלי להתראה על חוסר במלאי |
| `BatchNumber` | VARCHAR(50) | - | מספר אצווה (Batch) של התרופה |
| `ExpirationDate` | DATE | - | תאריך תפוגה של התרופה |

### טבלת תרופות (MEDICATION)
| שם השדה | סוג נתון | מפתח | תיאור השדה |
| :--- | :--- | :--- | :--- |
| `MedicationCode` | INT | PK | קוד תרופה ייחודי |
| `MedName` | VARCHAR(50) | - | שם התרופה |
| `Dosage` | VARCHAR(50) | - | מינון מומלץ |
| `Form` | VARCHAR(50) | - | צורת מתן התרופה (כדור, סירופ וכו') |
| `StorageLocation` | VARCHAR(50) | - | מיקום אחסון במרפאה |
| `InventoryID` | INT | FK | קישור למלאי במחסן התרופות |

### טבלת ניפוק תרופות (DISPENSING)
| שם השדה | סוג נתון | מפתח | תיאור השדה |
| :--- | :--- | :--- | :--- |
| `DispenseID` | INT | PK | מזהה פעולת ניפוק |
| `PharmacistName` | VARCHAR(50) | - | שם הרוקח המנפק |
| `DispenseDate` | DATE | - | תאריך הניפוק |
| `QuantityDispensed` | INT | - | כמות שנופקה (חייב להיות גדול מ-0) |
| `DispenseStatus` | VARCHAR(20) | - | סטטוס הניפוק (למשל: בוצע, ממתין) |

### טבלאות ירושה של תרופות (REGULARMED, FRIDGEMED, SPECIALMED)
* **`REGULARMED`**: מכילה תרופות רגילות (`MedicationCode` משמש כ-PK וכ-FK לטבלת `MEDICATION`).
* **`FRIDGEMED`**: מכילה תרופות הדורשות קירור, כולל טווח טמפרטורות (`TempRange`) ומזהה מקרר (`FridgeID`).
* **`SPECIALMED`**: מכילה תרופות מיוחדות/מפוקחות, כולל קוד כספת (`SafeCode`).

### טבלת מרשמים (PRESCRIPTION)
| שם השדה | סוג נתון | מפתח | תיאור השדה |
| :--- | :--- | :--- | :--- |
| `PrescriptionCode` | INT | PK | קוד מרשם ייחודי |
| `DateIssued` | DATE | - | תאריך הנפקת המרשם |
| `DoseInstructions` | VARCHAR(255) | - | הוראות מינון למטופל |
| `QuantityRequested` | INT | - | כמות מבוקשת במרשם (גדול מ-0) |
| `UrgencyStatus` | VARCHAR(20) | - | רמת דחיפות |
| `Status` | VARCHAR(20) | - | סטטוס המרשם |
| `PatientID` | VARCHAR(9) | FK | מזהה המטופל המקבל |
| `DoctorID` | VARCHAR(20) | FK | מזהה הרופא הרושם |
| `DispenseID` | INT | FK | מזהה ניפוק קשור (אופציונלי) |
| `MedicationCode` | INT | FK | קוד התרופה במרשם |

### טבלת קשר מניפוק למלאי (DRAWN_FROM)
| שם השדה | סוג נתון | מפתח | תיאור השדה |
| :--- | :--- | :--- | :--- |
| `DispenseID` | INT | PK/FK | מזהה פעולת הניפוק |
| `InventoryID` | INT | PK/FK | מזהה פריט המלאי ממנו נלקחה התרופה |