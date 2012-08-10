CREATE DATABASE example_db;
USE example_db;
CREATE TABLE testme (a INT);
INSERT INTO testme VALUES (1);


#FLUSH TABLES WITH READ LOCK;


#SET sql_log_bin=0;
#INSERT INTO testme VALUES (2),(3);
#SET sql_log_bin=1;
#INSERT INTO testme VALUES (4),(5);
#master should contain 5 rows but the one on the slave only 3
