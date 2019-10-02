--
-- Importera från Excel till Tabell
-- By Elena Perers for course databas.
-- 2019-02-26
--

--
-- LOAD DATA INFILE
--

--
-- Insert into kurs
--

DELETE FROM produktlager;
DELETE FROM produktkategori;
DELETE FROM lager;
DELETE FROM kund;
DELETE FROM produkt;
DELETE FROM kategori;

LOAD DATA LOCAL INFILE 'kategori.csv'
INTO TABLE kategori
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
;

SELECT * FROM kategori;

LOAD DATA LOCAL INFILE 'produkt.csv'
INTO TABLE produkt
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
(produktkod, pris, produktnamn, bildlank, beskrivning)
;

SELECT * FROM produkt;



LOAD DATA LOCAL INFILE 'kund.csv'
INTO TABLE kund
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
;

SELECT * FROM kund;




LOAD DATA LOCAL INFILE 'lager.csv'
INTO TABLE lager
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
(hyllnummer)
;

SELECT * FROM lager;



LOAD DATA LOCAL INFILE 'produktkategori.csv'
INTO TABLE produktkategori
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
(produktkod, kategorinamn)
;

SELECT * FROM produktkategori;



LOAD DATA LOCAL INFILE 'produktlager.csv'
INTO TABLE produktlager
CHARSET utf8
FIELDS
    TERMINATED BY ','
    ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
(hyllnummer, produktkod, antal_produkter)
;

SELECT * FROM produktlager;



SELECT * FROM log;
