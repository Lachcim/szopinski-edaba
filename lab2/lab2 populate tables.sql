DELETE FROM Actions;
DELETE FROM Employees;
DELETE FROM Gates;
DELETE FROM Permissions;
DELETE FROM Rooms;
DELETE FROM Schedules;
DELETE FROM Violations;

DECLARE
    TYPE hour_array IS VARRAY(5) OF INTEGER;
    
    work_hours INTEGER;
    work_start_array hour_array := hour_array(0, 0, 0, 0, 0);
    work_end_array hour_array := hour_array(0, 0, 0, 0, 0);
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
/

DECLARE
    TYPE string_array IS VARRAY(10) of VARCHAR(16);

    first_names string_array := string_array('Andrzej',
        'Janusz',
        'Przemo',
        'Mateo',
        'Domino',
        'Duszan',
        'Bartek',
        'Piotrek',
        'Seba',
        'Kamil');
    surnames string_array := string_array('Podolski',
        'Klose',
        'Muller',
        'Tusk',
        'Beckenbauer',
        'Merkel',
        'Strasburger',
        'Kowalski',
        'Nowak',
        'Gortat');
    positions string_array := string_array('Lab staff',
        'Programmer',
        'Security',
        'Supervisor',
        'Tech support',
        'Maintenance',
        'Food service',
        'Researcher',
        'Accountant',
        'Executive');
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Employees
        VALUES (
            i,
            first_names(FLOOR(DBMS_RANDOM.VALUE(1, 11))),
            surnames(FLOOR(DBMS_RANDOM.VALUE(1, 11))),
            positions(FLOOR(DBMS_RANDOM.VALUE(1, 11))),
            FLOOR(DBMS_RANDOM.VALUE(1, 26))
        );
    END LOOP;
END;
