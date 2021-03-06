-- EDABA LAB 2
-- MICHAŁ SZOPIŃSKI 300182
-- FILE 2 OF 2
-- This file contains the queries.

-- Track employee location over time
SELECT
    Employees.GivenName || ' ' || Employees.Surname AS "Employee",
    TO_CHAR(ActionDate, 'YYYY-MM-DD HH24:MI:SS') AS "Action date",
    Rooms.RoomNumber || ' (' || Rooms.Description || ')' AS "Source",
    DestRooms.RoomNumber || ' (' || DestRooms.Description || ')' AS "Destination"
FROM Actions
JOIN Employees ON Employees.EmployeeID = Actions.Employee
JOIN Rooms ON Rooms.RoomId = Actions.Room
JOIN Gates ON Gates.GateID = Actions.Gate
JOIN Rooms DestRooms ON DestRooms.RoomId = COALESCE(NULLIF(Gates.RoomA, Actions.Room), NULLIF(Gates.RoomB, Actions.Room))
WHERE ActionType = 1
ORDER BY Employee, ActionDate;

-- Find most commonly visited rooms
SELECT
    Destination,
    COUNT(Destination) AS "Visit count"
FROM (
    SELECT
        DestRooms.RoomNumber || ' (' || DestRooms.Description || ')' AS Destination
    FROM Actions
    JOIN Gates ON Gates.GateID = Actions.Gate
    JOIN Rooms DestRooms ON DestRooms.RoomId = COALESCE(NULLIF(Gates.RoomA, Actions.Room), NULLIF(Gates.RoomB, Actions.Room))
)
GROUP BY Destination
ORDER BY "Visit count" DESC;

-- Generate a table of rooms and their neighbors
SELECT
    Rooms.RoomNumber as "Room number",
    Neighbors.RoomNumber AS Neighbor
FROM Rooms
LEFT JOIN Gates ON Gates.RoomA = RoomID OR Gates.RoomB = RoomID
JOIN Rooms Neighbors ON (Neighbors.RoomID = Gates.RoomA OR Neighbors.RoomID = Gates.RoomB) AND Neighbors.RoomID <> Rooms.RoomID;

-- View all employees permitted to enter rooms on floor 9 (except for the corridor)
SELECT DISTINCT
    Employees.GivenName || ' ' || Employees.Surname || ' (' || Employees.EmployeeID || ')' AS "Employee",
    FloorPermissions.Expires
FROM Employees
JOIN (
    SELECT
        Permissions.Employee,
        Permissions.PermissionID,
        Permissions.Expires,
        Rooms.RoomNumber
    FROM Permissions
    JOIN Rooms ON Rooms.RoomId = Permissions.Room
) FloorPermissions ON
    FloorPermissions.Employee = Employees.EmployeeID
    AND FloorPermissions.RoomNumber LIKE '9___'
    AND FloorPermissions.RoomNumber <> '9000';

-- Find which positions commit most violations
WITH violators AS (
    SELECT
        Employees.Position
    FROM Violations
    JOIN Employees ON Employees.EmployeeID = Violations.Employee
)
SELECT
    Position,
    COUNT(Position) AS "Violation count",
    COUNT(Position) / (SELECT COUNT(Position) from violators) * 100 AS Percentage
FROM violators
GROUP BY Position
ORDER BY "Violation count" DESC;
