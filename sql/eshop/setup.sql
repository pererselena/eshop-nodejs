--
-- Skapa databas för eshop.
-- By Elena Perers for course databas.
-- 2019-02-21
-- 

--
-- CREATE DATABASE skolan;
-- 
 
CREATE DATABASE IF NOT EXISTS eshop;
USE eshop;
SHOW DATABASES LIKE "%eshop%";

-- 
-- Skapa en användare user med lösenorder pass
-- 

CREATE USER IF NOT EXISTS 'user'@'%'
    IDENTIFIED WITH mysql_native_password BY 'pass'
;


--
-- Ge användaren alla rättigheter på en specifk databas.
-- 

GRANT ALL PRIVILEGES
    ON eshop.*
    TO 'user'@'%'
;

SHOW GRANTS FOR 'user'@'%';
SET GLOBAL local_infile = 1;
