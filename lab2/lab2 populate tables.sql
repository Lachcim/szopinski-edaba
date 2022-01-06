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
    FROM Schedules
    ORDER BY DBMS_RANDOM.VALUE;
    
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
    
    total_floors INTEGER := FLOOR(DBMS_RANDOM.VALUE(1, 10));
    rooms_on_floor INTEGER;
    corridor_id INTEGER;
    prev_corridor_id INTEGER;
    branch_room_id INTEGER;
BEGIN
    INSERT INTO Rooms
    VALUES (NULL, 'Outside', 'Outside')
    RETURNING RoomId INTO corridor_id;

    FOR current_floor IN 1..total_floors LOOP
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
