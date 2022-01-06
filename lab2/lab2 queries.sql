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
