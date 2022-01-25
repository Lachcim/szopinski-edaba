-- EDABA LAB 3
-- MICHAŁ SZOPIŃSKI 300182
-- FILE 2 OF 2
-- This file contains code for testing triggers.

-- IMPORTANT: This test suite assumes that entity ID's start at 1.
-- Drop all entities and repopulate tables if needed.

SET SERVEROUTPUT ON;

-- Simulate employee committing violation
BEGIN dbms_output.put_line('Employee 1 before committing violation:'); END;
/
SELECT * FROM Employees WHERE EmployeeID = 1;
SELECT * FROM Permissions WHERE Employee = 1;

INSERT INTO Violations VALUES (NULL, 1, CURRENT_DATE, 1, 1, 1);
BEGIN dbms_output.put_line('Employee 1 after committing violation:'); END;
/
SELECT * FROM Employees WHERE EmployeeID = 1;
SELECT * FROM Permissions WHERE Employee = 1;

-- Simulate employee being hired as security
UPDATE Employees
SET Position='Security', Schedule=1
WHERE EmployeeID = 1;

BEGIN dbms_output.put_line('Employee 1 after being re-hired as security:'); END;
/
SELECT * FROM Employees WHERE EmployeeID = 1;
SELECT * FROM Permissions WHERE Employee = 1;

-- Simulate new female employee
DELETE FROM Actions WHERE Employee = 2;
DELETE FROM Violations WHERE Employee = 2;
DELETE FROM Permissions WHERE Employee = 2;
DELETE FROM Employees WHERE EmployeeID = 2;

INSERT INTO Employees
VALUES (
    2,
    'Nadieżda',
    'Krupska',
    'Cleaning service',
    1
);

BEGIN dbms_output.put_line('Employee 2 after insertion into table:'); END;
/
SELECT * FROM Employees WHERE EmployeeID = 2;
