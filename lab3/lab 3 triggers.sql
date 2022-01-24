-- EDABA LAB 3
-- MICHAŁ SZOPIŃSKI 300182
-- This file contains the trigger creation code.

-- Fire employees who commited a violation (aside from working overtime)
CREATE OR REPLACE TRIGGER Fire_violators
    AFTER INSERT
    ON Violations
    FOR EACH ROW
    WHEN (NEW.ViolationType <> 3)
BEGIN
    UPDATE Employees
    SET Position = 'Unemployed', Schedule = NULL
    WHERE EmployeeID = :NEW.Employee;

    DELETE FROM Permissions
    WHERE Employee = :NEW.Employee;
END;
