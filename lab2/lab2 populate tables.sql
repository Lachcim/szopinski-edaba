DELETE FROM Actions;
DELETE FROM Employees;
DELETE FROM Gates;
DELETE FROM Permissions;
DELETE FROM Rooms;
DELETE FROM Schedules;
DELETE FROM Violations;

DECLARE
    TYPE HOUR_ARRAY IS VARRAY(5) OF INTEGER;
    
    work_hours INTEGER;
    work_start_array HOUR_ARRAY := HOUR_ARRAY(0, 0, 0, 0, 0);
    work_end_array HOUR_ARRAY := HOUR_ARRAY(0, 0, 0, 0, 0);
BEGIN
    FOR i IN 1..25 LOOP
        work_hours := FLOOR(DBMS_RANDOM.VALUE(6, 9));

        FOR j IN 1..5 LOOP
            work_start_array(j) := FLOOR(DBMS_RANDOM.VALUE(12, 21)) * 30;
            work_end_array(j) := work_start_array(j) + work_hours * 60;
        END LOOP;
        
        INSERT INTO Schedules
        VALUES (
            i,
            work_start_array(1),
            work_end_array(1),
            work_start_array(2),
            work_end_array(2),
            work_start_array(3),
            work_end_array(3),
            work_start_array(4),
            work_end_array(4),
            work_start_array(5),
            work_end_array(5),
            0, 0, 0, 0
        );
    END LOOP;
END;
