START TRANSACTION;
    CREATE TABLE wine (name VARCHAR(255) NOT NULL);
    INSERT INTO wine VALUES ('MERLOT');
    INSERT INTO wine VALUES ('CARIGNAN');
COMMIT;

/*
SET sql_log_bin=0;
INSERT INTO wine VALUES ('PINOTAGE_1'),('PINOTAGE_2');
SET sql_log_bin=1;
INSERT INTO wine VALUES ('PINOTAGE_3'),('PINOTAGE_4');
#master should contain 6 rows but the one on the slave only 4
*/
