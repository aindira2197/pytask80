CREATE TABLE Backup_History (
    id INT PRIMARY KEY,
    backup_type VARCHAR(255),
    backup_date DATE,
    backup_time TIME,
    database_name VARCHAR(255),
    table_name VARCHAR(255),
    row_count INT
);

CREATE TABLE Database_Information (
    id INT PRIMARY KEY,
    database_name VARCHAR(255),
    database_size DECIMAL(10, 2),
    database_creation_date DATE
);

CREATE TABLE Tables_Information (
    id INT PRIMARY KEY,
    table_name VARCHAR(255),
    row_count INT,
    database_id INT,
    FOREIGN KEY (database_id) REFERENCES Database_Information(id)
);

CREATE PROCEDURE Create_Backup()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE db_name VARCHAR(255);
    DECLARE tb_name VARCHAR(255);
    DECLARE db_cursor CURSOR FOR SELECT database_name FROM Database_Information;
    DECLARE tb_cursor CURSOR FOR SELECT table_name FROM Tables_Information;

    OPEN db_cursor;

    read_loop: LOOP
        FETCH db_cursor INTO db_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET @sql = CONCAT('SELECT * INTO BACKUP_', db_name, ' FROM ', db_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        OPEN tb_cursor;
        read_loop2: LOOP
            FETCH tb_cursor INTO tb_name;
            IF done THEN
                LEAVE read_loop2;
            END IF;

            SET @sql = CONCAT('INSERT INTO Backup_History (backup_type, backup_date, backup_time, database_name, table_name, row_count) 
                VALUES (\'Full\', CURDATE(), CURTIME(), \'', db_name, '\', \'', tb_name, '\', (SELECT COUNT(*) FROM ', db_name, '.' , tb_name, '))');
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END LOOP;
        CLOSE tb_cursor;
    END LOOP;
    CLOSE db_cursor;
END;

CREATE TRIGGER Backup_Trigger
AFTER UPDATE ON Database_Information
FOR EACH ROW
BEGIN
    CALL Create_Backup();
END;

CREATE TRIGGER Backup_Trigger2
AFTER INSERT ON Tables_Information
FOR EACH ROW
BEGIN
    CALL Create_Backup();
END;

INSERT INTO Database_Information (id, database_name, database_size, database_creation_date)
VALUES (1, 'my_database', 10.5, '2020-01-01'),
       (2, 'my_database2', 20.3, '2020-02-01');

INSERT INTO Tables_Information (id, table_name, row_count, database_id)
VALUES (1, 'my_table', 100, 1),
       (2, 'my_table2', 200, 1);

CALL Create_Backup(); 

SELECT * FROM Backup_History; 

SELECT * FROM Database_Information; 

SELECT * FROM Tables_Information;