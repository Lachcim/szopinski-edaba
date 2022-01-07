-- EDABA LAB 2
-- MICHAŁ SZOPIŃSKI 300182
-- FILE 1 OF 1
-- This file contains the table population code.

DELETE FROM Violations;
DELETE FROM Actions;
DELETE FROM Employees;
DELETE FROM Gates;
DELETE FROM Permissions;
DELETE FROM Rooms;
DELETE FROM Schedules;

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
            NULL,
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

    min_schedule INTEGER;
    max_schedule INTEGER;
BEGIN
    SELECT MIN(ScheduleId), MAX(ScheduleID)
    INTO min_schedule, max_schedule
    FROM Schedules;
    
    FOR i IN 1..100 LOOP
        INSERT INTO Employees
        VALUES (
            NULL,
            first_names(FLOOR(DBMS_RANDOM.VALUE(1, 11))),
            surnames(FLOOR(DBMS_RANDOM.VALUE(1, 11))),
            positions(FLOOR(DBMS_RANDOM.VALUE(1, 11))),
            FLOOR(DBMS_RANDOM.VALUE(min_schedule, max_schedule + 1))
        );
    END LOOP;
END;
/

DECLARE
    TYPE string_array IS VARRAY(10) of VARCHAR(32);

    room_desc string_array := string_array('Electronics lab',
        'Conference room',
        'Computer lab',
        'Office',
        'Kitchen',
        'Security room',
        'Storage room',
        'Restroom',
        'Stairwell',
        'Corridor');
    
    rooms_on_floor INTEGER;
    corridor_id INTEGER;
    prev_corridor_id INTEGER;
    branch_room_id INTEGER;
BEGIN
    INSERT INTO Rooms
    VALUES (NULL, 'Outside', 'Outside')
    RETURNING RoomId INTO corridor_id;

    FOR current_floor IN 1..9 LOOP
        prev_corridor_id := corridor_id;
        
        INSERT INTO Rooms
        VALUES (
            NULL,
            current_floor * 1000,
            'Corridor on floor ' || current_floor
        )
        RETURNING RoomId INTO corridor_id;

        IF current_floor = 1 THEN
            INSERT INTO Gates
            VALUES (
                NULL,
                'Main entrance',
                prev_corridor_id,
                corridor_id
            );
        ELSE
            INSERT INTO Gates
            VALUES (
                NULL,
                'Passage from corridor on floor ' || (current_floor - 1) || ' to floor ' || current_floor,
                prev_corridor_id,
                corridor_id
            );
        END IF;

        rooms_on_floor := FLOOR(DBMS_RANDOM.VALUE(1, 11));

        FOR room_number IN 1..rooms_on_floor LOOP
            INSERT INTO Rooms
            VALUES (
                NULL,
                current_floor * 1000 + room_number,
                room_desc(FLOOR(DBMS_RANDOM.VALUE(1, 11))) || ' on floor ' || current_floor
            )
            RETURNING RoomId INTO branch_room_id;

            INSERT INTO Gates
            VALUES (
                NULL,
                'Entrance to room ' || (current_floor * 1000 + room_number),
                corridor_id,
                branch_room_id
            );
        END LOOP;
    END LOOP;
END;
/

DECLARE
    min_employee INTEGER;
    max_employee INTEGER;

    employee_floor INTEGER;
    expiry_date DATE;
BEGIN
    SELECT MIN(EmployeeId), MAX(EmployeeId)
    INTO min_employee, max_employee
    FROM Employees;

    FOR employee_id IN min_employee..max_employee LOOP
        employee_floor := FLOOR(DBMS_RANDOM.VALUE(1, 10));
        expiry_date := ADD_MONTHS(CURRENT_DATE, FLOOR(DBMS_RANDOM.VALUE(1, 13)));

        INSERT INTO Permissions
        SELECT
            NULL,
            expiry_date,
            employee_id,
            RoomId
        FROM Rooms
        WHERE
            MOD(TO_NUMBER(RoomNumber DEFAULT 0 ON CONVERSION ERROR), 1000) = 0
            OR FLOOR(TO_NUMBER(RoomNumber DEFAULT 0 ON CONVERSION ERROR) / 1000) = employee_floor;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE simulate_employee (
    employee_id IN INTEGER,
    activity_date IN DATE,
    current_room IN OUT INTEGER
)
AS
    next_room INTEGER;
    next_room_gate INTEGER;
BEGIN
    SELECT Neighbor, GateId
    INTO next_room, next_room_gate
    FROM (
        SELECT Neighbor, GateId
        FROM (
            SELECT COALESCE(NULLIF(RoomA, current_room), NULLIF(RoomB, current_room)) AS Neighbor, GateId
            FROM Gates
            WHERE RoomA = current_room OR RoomB = current_room
        )
        WHERE
            Neighbor IN (
                SELECT Room
                FROM Permissions
                WHERE Employee = employee_id
            )
        ORDER BY DBMS_RANDOM.RANDOM    
    )
    WHERE
        ROWNUM = 1;

    INSERT INTO Actions
    VALUES (
        NULL,
        0,
        activity_date,
        employee_id,
        current_room,
        next_room_gate
    );
    INSERT INTO Actions
    VALUES (
        NULL,
        1,
        activity_date + 0.0007,
        employee_id,
        current_room,
        next_room_gate
    );
    
    current_room := next_room;
END;
/

CREATE OR REPLACE PROCEDURE simulate_naughty_employee (
    employee_id IN INTEGER,
    activity_date IN DATE,
    current_room IN OUT INTEGER
)
AS
    next_room INTEGER;
    next_room_gate INTEGER;
    allowed_to_enter INTEGER;
BEGIN
    SELECT Neighbor, GateId
    INTO next_room, next_room_gate
    FROM (
        SELECT Neighbor, GateId
        FROM (
            SELECT COALESCE(NULLIF(RoomA, current_room), NULLIF(RoomB, current_room)) AS Neighbor, GateId
            FROM Gates
            WHERE RoomA = current_room OR RoomB = current_room
        )
        ORDER BY DBMS_RANDOM.RANDOM    
    )
    WHERE
        ROWNUM = 1;

    SELECT COUNT(PermissionID)
    INTO allowed_to_enter
    FROM Permissions
    WHERE employee = employee_id AND room = next_room;

    IF allowed_to_enter > 0 THEN
        INSERT INTO Actions
        VALUES (
            NULL,
            0,
            activity_date,
            employee_id,
            current_room,
            next_room_gate
        );
        INSERT INTO Actions
        VALUES (
            NULL,
            1,
            activity_date + 0.0007,
            employee_id,
            current_room,
            next_room_gate
        );
        
        current_room := next_room;
    ELSE
        INSERT INTO Violations
        VALUES (
            NULL,
            1,
            activity_date,
            employee_id,
            next_room,
            next_room_gate
        );
    END IF;
END;
/

DECLARE
    min_employee INTEGER;
    max_employee INTEGER;

    activity_date DATE;
    end_date DATE;
    current_room INTEGER;
BEGIN
    SELECT MIN(EmployeeId), MAX(EmployeeId)
    INTO min_employee, max_employee
    FROM Employees;

    FOR employee_id IN min_employee..max_employee LOOP
        activity_date := TRUNC(CURRENT_DATE) + DBMS_RANDOM.VALUE(0.41666, 0.42);
        end_date := TRUNC(CURRENT_DATE) + DBMS_RANDOM.VALUE(0.46, 0.5);

        SELECT RoomId
        INTO current_room
        FROM Rooms
        WHERE RoomNumber = 'Outside';

        WHILE activity_date < end_date LOOP
            IF DBMS_RANDOM.VALUE() < 0.95 THEN
                simulate_employee(employee_id, activity_date, current_room);
            ELSE
                simulate_naughty_employee(employee_id, activity_date, current_room);
            END IF;

            activity_date := activity_date + DBMS_RANDOM.VALUE(0.0014, 0.0104);
        END LOOP;
    END LOOP;
END;
