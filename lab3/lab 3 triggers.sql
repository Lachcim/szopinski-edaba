-- EDABA LAB 3
-- MICHAŁ SZOPIŃSKI 300182
-- FILE 1 OF 2
-- This file contains the trigger creation code.

-- Fire employees who commited a violation (aside from working overtime)
CREATE OR REPLACE TRIGGER Fire_violators
    AFTER INSERT
    ON Violations
    FOR EACH ROW
    WHEN (NEW.ViolationType <> 3)
BEGIN
    UPDATE Employees
    SET Position = 'Guest', Schedule = NULL
    WHERE EmployeeID = :NEW.Employee;

    DELETE FROM Permissions
    WHERE Employee = :NEW.Employee;
END;
/

-- Make sure new security employees have access to all rooms
CREATE OR REPLACE TRIGGER Security_permissions
    AFTER INSERT OR UPDATE OF Position
    ON EMPLOYEES
    FOR EACH ROW
    WHEN (NEW.Position = 'Security')
BEGIN
    INSERT INTO Permissions
    SELECT
        NULL,
        ADD_MONTHS(CURRENT_DATE, 12),
        :NEW.EmployeeID,
        RoomID
    FROM Rooms
    WHERE NOT EXISTS (
        SELECT * FROM Permissions
        WHERE Employee = :NEW.EmployeeID AND Room = RoomID
    );
END;
/

-- Move all newly hired women to IT (to promote equity and women in tech)
CREATE OR REPLACE TRIGGER Promote_equity
    BEFORE INSERT
    ON EMPLOYEES
    FOR EACH ROW
    WHEN (NEW.GivenName LIKE '%a')
BEGIN
    :NEW.Position := 'Programmer';
END;
