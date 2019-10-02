--
-- Create scheme for database eshop.
-- By Elena Perers for course databas.
-- 2019-02-20
--

--
-- Drop tables in order to avoid FK constraint
--

DROP TABLE IF EXISTS plocklista;
DROP TABLE IF EXISTS kundfaktura;
DROP TABLE IF EXISTS faktura;
DROP TABLE IF EXISTS produktorder;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS produktlager;
DROP TABLE IF EXISTS lager;
DROP TABLE IF EXISTS produktkategori;
DROP TABLE IF EXISTS produkt;
DROP TABLE IF EXISTS kategori;
DROP TABLE IF EXISTS kund;


--
-- Create table: kategori
--


CREATE TABLE kategori
(
    kategorinamn VARCHAR(20) NOT NULL,


    PRIMARY KEY (kategorinamn)
);

SELECT * FROM kategori;

--
-- Create table: produkt
--

CREATE TABLE produkt
(
    produktkod INT(10) NOT NULL,
    pris DEC(6,2),
    produktnamn VARCHAR(50) NOT NULL,
    bildlank VARCHAR(1000),
    beskrivning VARCHAR(2000) NOT NULL,


    PRIMARY KEY (produktkod),
    KEY `index_pris` (pris),
    KEY `index_produktnamn` (produktnamn)
);

SELECT * FROM produkt;


--
-- Create table: produktkategori
--


CREATE TABLE produktkategori
(
    produktkod INT(10) NOT NULL,
    kategorinamn VARCHAR(20) NOT NULL,



    PRIMARY KEY (produktkod, kategorinamn),
    FOREIGN KEY (produktkod) REFERENCES produkt(produktkod),
    FOREIGN KEY (kategorinamn) REFERENCES kategori(kategorinamn)
);

SELECT * FROM produktkategori;


--
-- Create table: kund
--

CREATE TABLE kund
(
    kundnummer INT(10) NOT NULL AUTO_INCREMENT,
    fornamn VARCHAR(15) NOT NULL,
    efternamn VARCHAR(20) NOT NULL,
    adress VARCHAR(40) NOT NULL,
    postnummer INT(5) NOT NULL,
    ort VARCHAR(40) NOT NULL,
    land VARCHAR(40) NOT NULL,
    telefon INT(10) NOT NULL,

    PRIMARY KEY (kundnummer),
    KEY `index_fornamn` (fornamn),
    KEY `index_efternamn` (efternamn)
);

SELECT * FROM kund; 



--
-- Create table: orders
--


CREATE TABLE orders
(
    ordernummer INT(10) NOT NULL AUTO_INCREMENT,
    kundnummer INT(10),
    produktkod INT(10),
    pris DEC(6,2),
    antal INT(50),
    status_kod INT,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted TIMESTAMP NULL DEFAULT NULL,
    ordered TIMESTAMP NULL DEFAULT NULL,
    sent TIMESTAMP NULL DEFAULT NULL,



    PRIMARY KEY (ordernummer),
    FOREIGN KEY (kundnummer) REFERENCES kund(kundnummer),
    FOREIGN KEY (produktkod) REFERENCES produkt(produktkod),
    FOREIGN KEY (pris) REFERENCES produkt(pris)
);

SELECT * FROM orders;


--
-- Create table: produktorder
--


CREATE TABLE produktorder
(
    produktkod INT(10) NOT NULL,
	ordernummer INT(10) NOT NULL AUTO_INCREMENT,
    antal INT(50) NOT NULL,



    PRIMARY KEY (produktkod, ordernummer),
    FOREIGN KEY (produktkod) REFERENCES produkt(produktkod),
	FOREIGN KEY (ordernummer) REFERENCES orders(ordernummer)
);

SELECT * FROM produktorder;




--
-- Create table: faktura
--


CREATE TABLE faktura
(
    fakturanummer INT(10) NOT NULL AUTO_INCREMENT,
    ordernummer INT(10) NOT NULL,
    kundnummer INT(10) NOT NULL,
	faktura_status VARCHAR(20),
    total_pris DEC(12,2) NOT NULL,
    payed_date TIMESTAMP NULL DEFAULT NULL,


    PRIMARY KEY (fakturanummer),
    FOREIGN KEY (ordernummer) REFERENCES orders(ordernummer),
    FOREIGN KEY (kundnummer) REFERENCES kund(kundnummer)
);

SELECT * FROM faktura;

--
-- Create table: kundfaktura
--


CREATE TABLE kundfaktura
(
    kundnummer INT(10) NOT NULL,
    fakturanummer INT(10) NOT NULL,



    PRIMARY KEY (kundnummer, fakturanummer),
    FOREIGN KEY (kundnummer) REFERENCES kund(kundnummer),
    FOREIGN KEY (fakturanummer) REFERENCES faktura(fakturanummer)
);

SELECT * FROM kundfaktura;

--
-- Create table: lager
--


CREATE TABLE lager
(
    hyllnummer VARCHAR(10) NOT NULL,


    PRIMARY KEY (hyllnummer)
);

SELECT * FROM lager;


--
-- Create table: produktlager
--


CREATE TABLE produktlager
(
    hyllnummer VARCHAR(10) NOT NULL,
    produktkod INT(10) NOT NULL,
    antal_produkter INT(100),



    PRIMARY KEY (hyllnummer, produktkod),
    FOREIGN KEY (hyllnummer) REFERENCES lager(hyllnummer),
    FOREIGN KEY (produktkod) REFERENCES produkt(produktkod),
    KEY `index_antal_produkter` (antal_produkter)
);

SELECT * FROM produktlager;




--
-- Create table: plocklista
--


CREATE TABLE plocklista
(
    ordernummer INT(10) NOT NULL,
    hyllnummer VARCHAR(10) NOT NULL,
    produktkod INT(10) NOT NULL,


    PRIMARY KEY (ordernummer),
    FOREIGN KEY (ordernummer) REFERENCES orders(ordernummer),
    FOREIGN KEY (hyllnummer) REFERENCES lager(hyllnummer),
    FOREIGN KEY (produktkod) REFERENCES produkt(produktkod)
);

SELECT * FROM plocklista;



--
-- Log table
--


DROP TABLE IF EXISTS log;
CREATE TABLE log
(
    id INTEGER AUTO_INCREMENT,
    tidstampel TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    handelse VARCHAR(1000),
    
    PRIMARY KEY (id)
);

SELECT * FROM log;

--
-- Trigger for logging inserting produkt
--
DROP TRIGGER IF EXISTS log_produkt_insert;

DELIMITER ;;
CREATE TRIGGER log_produkt_insert
AFTER INSERT
ON produkt FOR EACH ROW
    INSERT INTO log (handelse)
        VALUES (CONCAT("Ny produkt lades till med produktkod ", NEW.produktkod));
;;
DELIMITER ;

--
-- Trigger for logging updating produkt
--
DROP TRIGGER IF EXISTS log_produkt_update;

DELIMITER ;;
CREATE TRIGGER log_produkt_update
AFTER UPDATE
ON produkt FOR EACH ROW
    INSERT INTO log (handelse)
        VALUES (CONCAT("Detaljer om produktkod ", NEW.produktkod, " uppdaterades."));
;;
DELIMITER ;

--
-- Trigger for logging delete produkt
--
DROP TRIGGER IF EXISTS log_produkt_delete;

DELIMITER ;;
CREATE TRIGGER log_produkt_delete
AFTER DELETE
ON produkt FOR EACH ROW
    INSERT INTO log (handelse)
        VALUES (CONCAT("Produkten med produktkod ", OLD.produktkod, " raderades."));
;;
DELIMITER ;        
        




--
-- Create procedure for select * from ketegori
--


DROP PROCEDURE IF EXISTS show_category;
DELIMITER ;;
CREATE PROCEDURE show_category()
BEGIN
    SELECT * FROM kategori;
END
;;
DELIMITER ;

CALL show_category(); 

--
-- Create procedure for select * from produkt
-- 


DROP PROCEDURE IF EXISTS show_produkt;
DELIMITER ;;
CREATE PROCEDURE show_produkt()
BEGIN
    SELECT 
		p.*, 
		pl.antal,
		pk.kategori
	FROM 
        produkt AS p
    LEFT OUTER JOIN
        (
        SELECT produktkod,
           SUM(antal_produkter) AS antal
        FROM produktlager
        GROUP BY produktkod
        ) AS pl
    ON p.produktkod = pl.produktkod

    LEFT OUTER JOIN
        (
        SELECT produktkod,
        GROUP_CONCAT(kategorinamn) AS kategori
        FROM produktkategori
        GROUP BY produktkod
        ) AS pk
    ON p.produktkod = pk.produktkod ;
END
;;
DELIMITER ;

CALL show_produkt(); 



--
-- Create procedure for insert into produkt
--


DROP PROCEDURE IF EXISTS create_product;
DELIMITER ;;
CREATE PROCEDURE create_product(
    c_produktkod INT(10),
    c_pris DEC(6,2),
    c_produktnamn VARCHAR(50),
    c_bildlank VARCHAR(1000),
    c_beskrivning VARCHAR(2000)
)
BEGIN
    INSERT INTO produkt (produktkod, produktnamn, beskrivning, bildlank, pris)  
		VALUES (c_produktkod, c_produktnamn, c_beskrivning, c_bildlank, c_pris)
	;
END
;;
DELIMITER ;




DROP PROCEDURE IF EXISTS get_product;
DELIMITER ;;
CREATE PROCEDURE get_product(c_produktkod INT(10))
BEGIN
    SELECT * FROM produkt 
		WHERE produktkod LIKE c_produktkod;
END
;;
DELIMITER ;



DROP PROCEDURE IF EXISTS update_product;
DELIMITER ;;
CREATE PROCEDURE update_product(
    c_produktkod INT(10),
    c_pris DEC(6,2),
    c_produktnamn VARCHAR(50),
    c_bildlank VARCHAR(1000),
    c_beskrivning VARCHAR(2000)
)
BEGIN
    UPDATE produkt SET
			`produktnamn` = c_produktnamn,
			`beskrivning` = c_beskrivning,
			`beskrivning` = c_beskrivning,
			`bildlank` = c_bildlank,
			`pris` = c_pris
        WHERE
			`produktkod` = c_produktkod;
END
;;
DELIMITER ;





DROP PROCEDURE IF EXISTS delete_product;
DELIMITER ;;
CREATE PROCEDURE delete_product(c_produktkod INT(10))
BEGIN
    DELETE FROM produkt        
		WHERE 
			`produktkod` = c_produktkod
            ;
END
;;
DELIMITER ;


-- 
-- Create procedure for logHistory
-- 


DROP PROCEDURE IF EXISTS get_history;
DELIMITER ;;
CREATE PROCEDURE get_history(num_rows INT(10))
BEGIN
    SELECT * FROM log        
    ORDER BY tidstampel DESC
	LIMIT num_rows
	;
END
;;
DELIMITER ;


-- 
-- Create procedure for lager
-- 


DROP PROCEDURE IF EXISTS get_shelf;
DELIMITER ;;
CREATE PROCEDURE get_shelf()
BEGIN
    SELECT * FROM lager
    ;
END
;;
DELIMITER ;

-- 
-- Create procedure for prdukt i lager
-- 


DROP PROCEDURE IF EXISTS get_inventory;
DELIMITER ;;
CREATE PROCEDURE get_inventory()
BEGIN
    SELECT 
		pl.*,
        p.produktnamn
	FROM 
        produktlager AS pl
    LEFT OUTER JOIN
        (
        SELECT produktkod,
           produktnamn
        FROM produkt
        ) AS p
    ON p.produktkod = pl.produktkod
    ;
END
;;
DELIMITER ;




-- 
-- Create procedure for search i lager
-- 


DROP PROCEDURE IF EXISTS search_inventory;
DELIMITER ;;
CREATE PROCEDURE search_inventory(search VARCHAR(200))
BEGIN
	SELECT 
		pl.*,
        p.produktnamn
	FROM 
        produktlager AS pl
    LEFT OUTER JOIN
        (
        SELECT produktkod,
           produktnamn
        FROM produkt
        ) AS p
    ON p.produktkod = pl.produktkod
		WHERE pl.produktkod LIKE search OR
        p.produktnamn LIKE search OR
        pl.hyllnummer LIKE search
        ;
END
;;
DELIMITER ;


-- 
-- Create procedure for add i lager
-- 


DROP PROCEDURE IF EXISTS invadd;
DELIMITER ;;
CREATE PROCEDURE invadd(pkod INT(10), hyllnr VARCHAR(10), antal INT(10))
BEGIN
	INSERT INTO produktlager (produktkod, hyllnummer, antal_produkter) VALUES (pkod, hyllnr, antal)
		ON DUPLICATE KEY UPDATE antal_produkter = antal_produkter + antal;
END
;;
DELIMITER ;



-- 
-- Create procedure for delete i lager
-- 


DROP PROCEDURE IF EXISTS invdel;
DELIMITER ;;
CREATE PROCEDURE invdel(pkod INT(10), hyllnr VARCHAR(10), antal INT(10))
BEGIN
	UPDATE produktlager 
		SET antal_produkter = antal_produkter - antal
		WHERE produktkod = pkod AND
			hyllnummer = hyllnr;
END
;;
DELIMITER ;

--
-- Function for order status.
-- 


DROP FUNCTION IF EXISTS order_status;
DELIMITER ;;

CREATE FUNCTION order_status(
    created_date TIMESTAMP,
    updated_date TIMESTAMP,
    deleted_date TIMESTAMP,
    ordered_date TIMESTAMP,
    sent_date TIMESTAMP
    
)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF deleted_date IS NOT NULL THEN
        RETURN 'Raderad';
    ELSEIF sent_date IS NOT NULL THEN
        RETURN 'Skickad';
    ELSEIF ordered_date IS NOT NULL THEN
        RETURN 'Beställd';
    ELSEIF updated_date IS NOT NULL THEN
        RETURN 'Uppdaterad';
    ELSEIF created_date IS NOT NULL THEN
        RETURN 'Skapad';
    END IF;
    RETURN 'Ingenting'
    ;
END
;;

DELIMITER ;


--
-- Function for produktorder antal.
-- 


DROP FUNCTION IF EXISTS order_antal;
DELIMITER ;;

CREATE FUNCTION order_antal(
    ordernr INT
)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE total_antal INT;
    SET total_antal = (SELECT COUNT(antal) FROM produktorder
    WHERE ordernummer = ordernr);
    IF total_antal IS NULL THEN 
		RETURN 0;
    END IF;
    RETURN total_antal;
    
END
;;

DELIMITER ;







-- 
-- Create procedure for search in orders
-- 


DROP PROCEDURE IF EXISTS search_order;
DELIMITER ;;
CREATE PROCEDURE search_order(search VARCHAR(200))
BEGIN
	SELECT
		k.kundnummer as kundnummer,
		o.ordernummer,
		order_antal(o.ordernummer) AS antal,
		order_status(o.created,
		o.updated,
		o.deleted,
		o.ordered,
		o.sent) as order_status,
		o.created
		FROM kund AS k
		INNER JOIN orders o
		ON o.kundnummer = k.kundnummer
		WHERE k.kundnummer LIKE search OR
        o.ordernummer LIKE search;
END
;;
DELIMITER ;




-- 
-- Create procedure for picklist
-- 


DROP PROCEDURE IF EXISTS plocklista;
DELIMITER ;;
CREATE PROCEDURE plocklista(search INT)
BEGIN
	SELECT
		o.ordernummer AS ordernummer,
		po.produktkod AS produktkod,
		po.antal AS antal,
        GROUP_CONCAT(pl.hyllnummer) AS hylla,
        (
		CASE
			WHEN pl.antal_produkter > 0 THEN GROUP_CONCAT(pl.antal_produkter)
            ELSE 'Slut i lager'
		END) AS antal_i_lager,
        (
        CASE
			WHEN (SUM(pl.antal_produkter) - po.antal) >= 0 THEN 'Tillräckligt på lager'
            ELSE 'Inte tillräckligt på lager' 
            END) AS 'lagerstatus',
		(SUM(pl.antal_produkter) - po.antal) AS 'lagerdiff'
		FROM orders AS o 
		LEFT OUTER JOIN produktorder AS po
		ON o.ordernummer = po.ordernummer
        LEFT OUTER JOIN produktlager AS pl
        ON po.produktkod = pl.produktkod
		WHERE o.ordernummer LIKE search
        GROUP BY pl.produktkod
        ;
END
;;
DELIMITER ;



-- 
-- Create procedure for shipment
-- 


DROP PROCEDURE IF EXISTS ship;
DELIMITER ;;
CREATE PROCEDURE ship(search INT)
BEGIN
	UPDATE orders SET sent = NOW() WHERE ordernummer = search;
END
;;
DELIMITER ;


-- 
-- Create procedure for customers
-- 


DROP PROCEDURE IF EXISTS get_customers;
DELIMITER ;;
CREATE PROCEDURE get_customers()
BEGIN
	SELECT
		kundnummer AS kundnummer,
		CONCAT(fornamn, ' ', efternamn) AS kundnamn
		FROM kund;
END
;;
DELIMITER ;


-- 
-- Create procedure for customers with info
-- 


DROP PROCEDURE IF EXISTS customers_with_info;
DELIMITER ;;
CREATE PROCEDURE customers_with_info()
BEGIN
	SELECT
		kundnummer AS kundnummer,
		CONCAT(fornamn, ' ', efternamn) AS kundnamn,
		CONCAT(adress, ', ', ort, ', ', land, ', ', postnummer) AS kundadress,
		telefon AS telefonnummer
		FROM kund;
END
;;
DELIMITER ;


-- 
-- Create procedure for get orders
-- 


DROP PROCEDURE IF EXISTS get_orders;
DELIMITER ;;
CREATE PROCEDURE get_orders()
BEGIN
	SELECT
		k.kundnummer AS kundnummer,
		CONCAT(k.fornamn, ' ', k.efternamn) AS kundnamn,
		o.ordernummer,
		order_antal(o.ordernummer) AS antal,
		order_status(o.created,
		o.updated,
		o.deleted,
		o.ordered,
		o.sent) AS order_status,
		o.created
		FROM kund AS k
		INNER JOIN orders o
		ON o.kundnummer = k.kundnummer
		;
END
;;
DELIMITER ;



-- 
-- Create procedure for get order
-- 

DROP PROCEDURE IF EXISTS get_order;
DELIMITER ;;
CREATE PROCEDURE get_order(ordernr INT)
BEGIN
	SELECT
		o.ordernummer,
		order_status(o.created,
		o.updated,
		o.deleted,
		o.ordered,
		o.sent) as order_status,
		k.kundnummer as kundnummer,
        CONCAT(k.adress, ', ', k.postnummer, ', ', k.ort, ', ', k.land) AS adress,
        k.telefon AS telefon,
		CONCAT(k.fornamn, ' ', k.efternamn) AS kundnamn
		FROM orders o
		INNER JOIN kund k
		ON k.kundnummer = o.kundnummer
		WHERE o.ordernummer = ordernr;
END
;;
DELIMITER ;



-- 
-- Create procedure for create order
-- 

DROP PROCEDURE IF EXISTS create_order;
DELIMITER ;;
CREATE PROCEDURE create_order(kundnr INT)
BEGIN
	INSERT INTO orders (kundnummer) VALUES (kundnr);
    SELECT 
		ordernummer 
        FROM orders
        WHERE kundnummer = kundnr 
        ORDER BY ordernummer DESC LIMIT 1;
END
;;
DELIMITER ;



-- 
-- Create procedure for order ready
-- 

DROP PROCEDURE IF EXISTS order_ready;
DELIMITER ;;
CREATE PROCEDURE order_ready(ordernr INT)
BEGIN
	UPDATE orders 
    SET ordered = NOW()
    WHERE ordernummer = ordernr
    ;
END
;;
DELIMITER ;



-- 
-- Create procedure for produkt order
-- 

DROP PROCEDURE IF EXISTS create_produkt_order;
DELIMITER ;;
CREATE PROCEDURE create_produkt_order(produktkd INT, ordernr INT, ant INT)
BEGIN
	INSERT INTO produktorder
        (produktkod, ordernummer, antal)
        VALUES
        (produktkd, ordernr, ant);
END
;;
DELIMITER ;


-- 
-- Create procedure for produkt order
-- 

DROP PROCEDURE IF EXISTS get_produkt_order;
DELIMITER ;;
CREATE PROCEDURE get_produkt_order(ordernr INT)
BEGIN
	SELECT *
		FROM produktorder po
		INNER JOIN produkt p
		ON po.produktkod = p.produktkod
		WHERE po.ordernummer = ordernr;
END
;;
DELIMITER ;


-- 
-- Create procedure for logHistory
-- 


DROP PROCEDURE IF EXISTS get_log;
DELIMITER ;;
CREATE PROCEDURE get_log(search VARCHAR(300))
BEGIN
    SELECT * FROM log
    WHERE id LIKE search OR
        tidstampel LIKE search OR
        handelse LIKE search
	ORDER BY tidstampel DESC
	LIMIT 20
	;
END
;;
DELIMITER ;



-- 
-- Create procedure for update category
-- 


DROP PROCEDURE IF EXISTS update_produktkategori;
DELIMITER ;;
CREATE PROCEDURE update_produktkategori(
    c_produktkod INT(10),
    c_kategorinamn VARCHAR(20)
)
BEGIN
     INSERT INTO produktkategori (produktkod, kategorinamn)  
		VALUES (c_produktkod, c_kategorinamn)
	ON DUPLICATE KEY UPDATE kategorinamn = c_kategorinamn;
		
END
;;
DELIMITER ;



-- 
-- Create procedure for product category
-- 


DROP PROCEDURE IF EXISTS show_produktkategori;
DELIMITER ;;
CREATE PROCEDURE show_produktkategori(
    c_kategorinamn VARCHAR(20)
)
BEGIN
    SELECT 
		p.*,
        pk.kategori
	FROM 
        produkt AS p
    INNER JOIN
        (
        SELECT produktkod,
        kategorinamn AS kategori
        FROM produktkategori
       
        ) AS pk
    ON p.produktkod = pk.produktkod
    WHERE
		pk.kategori = c_kategorinamn;
END
;;
DELIMITER ;





--
-- Create procedure for crud produktkategori
--


DROP PROCEDURE IF EXISTS create_produktkategori;
DELIMITER ;;
CREATE PROCEDURE create_produktkategori(
    c_produktkod INT(10),
    c_kategorinamn VARCHAR(20)
)
BEGIN
    INSERT INTO produktkategori (produktkod, kategorinamn)  
		VALUES (c_produktkod, c_kategorinamn)
	;
END
;;
DELIMITER ;


DROP PROCEDURE IF EXISTS get_produktkategori;
DELIMITER ;;
CREATE PROCEDURE get_produktkategori(c_produktkod INT(10))
BEGIN
    SELECT * FROM produktkategori 
		WHERE produktkod LIKE c_produktkod;
END
;;
DELIMITER ;


DROP PROCEDURE IF EXISTS delete_produktkategori;
DELIMITER ;;
CREATE PROCEDURE delete_produktkategori(
	c_produktkod INT(10),
	c_kategorinamn VARCHAR(20))
BEGIN
    DELETE FROM produktkategori       
		WHERE 
			`produktkod` = c_produktkod AND
            `kategorinamn` = c_kategorinamn
            ;
END
;;
DELIMITER ;



-- 
-- Create procedure for clear category
-- 


DROP PROCEDURE IF EXISTS clear_produktkategori;
DELIMITER ;;
CREATE PROCEDURE clear_produktkategori(
	c_produktkod INT(10)
    )
BEGIN
    DELETE FROM produktkategori       
		WHERE 
			`produktkod` = c_produktkod
            ;
END
;;
DELIMITER ;

-- 
-- Create procedure for delete everything from a produkt i lager
-- 


DROP PROCEDURE IF EXISTS delete_produktlager;
DELIMITER ;;
CREATE PROCEDURE delete_produktlager(pkod INT(10))
BEGIN
	DELETE FROM produktlager 
		WHERE produktkod = pkod;
END
;;
DELIMITER ;


-- 
-- Create procedure for delete a produkt in order
-- 


DROP PROCEDURE IF EXISTS delete_row_order;
DELIMITER ;;
CREATE PROCEDURE delete_row_order(pkod INT(10), ordernr INT)
BEGIN
	DELETE FROM produktorder 
		WHERE produktkod = pkod AND
        ordernummer = ordernr;
END
;;
DELIMITER ;


-- 
-- Create procedure for update antal produkt in order
-- 


DROP PROCEDURE IF EXISTS update_row_order;
DELIMITER ;;
CREATE PROCEDURE update_row_order(pkod INT(10), ordernr INT, ant INT)
BEGIN
	UPDATE produktorder
    SET antal = ant
		WHERE produktkod = pkod AND
        ordernummer = ordernr;
END
;;
DELIMITER ;




-- 
-- Create procedure for reduce amount in stock
-- 


DROP PROCEDURE IF EXISTS reduce_pl;
DELIMITER ;;
CREATE PROCEDURE reduce_pl(pkod INT(10), ant INT)
BEGIN
	DECLARE v_pkod INT(10);
    DECLARE v_antal INT;
    DECLARE v_hylla VARCHAR(10);

	DECLARE cur CURSOR FOR
		SELECT 
			produktkod, antal_produkter, hyllnummer 
            FROM
			produktlager
            WHERE produktkod = pkod;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET @done = 1;
		SET @done = 0;
        SET @diff = ant;
        OPEN cur;
        reduce_antal: LOOP
			FETCH cur INTO v_pkod, v_antal, v_hylla;
            IF @done = 1 THEN 
				LEAVE reduce_antal;
            END IF;
            IF v_antal > 0 THEN
				SET @diff = v_antal - @diff;
                SELECT @diff;
				IF @diff <= 0 THEN
					DELETE FROM produktlager
						WHERE produktkod = v_pkod AND
						hyllnummer = v_hylla;
                        SET @diff = - @diff;
				ELSE
					UPDATE produktlager
						SET antal_produkter = @diff
						WHERE produktkod = v_pkod AND
						hyllnummer = v_hylla;
                        SET @done = 1;
				END IF;
			END IF;
		END LOOP reduce_antal;

END
;;
DELIMITER ;


-- 
-- Create procedure to create faktura
-- 


DROP PROCEDURE IF EXISTS create_faktura;
DELIMITER ;;
CREATE PROCEDURE create_faktura(knr INT(10), ordernr INT)
BEGIN
    
    DECLARE summa INT;
    SELECT SUM(po.antal * p.pris) INTO summa
        FROM produktorder AS po
        INNER JOIN produkt AS p
			ON po.produktkod = p.produktkod
    WHERE ordernummer = ordernr;
    INSERT INTO faktura (kundnummer, ordernummer, faktura_status, total_pris)
	 	VALUES (knr, ordernr, "obetald", summa);

END
;;
DELIMITER ;

-- 
-- Create procedure to get faktura
-- 


DROP PROCEDURE IF EXISTS get_faktura;
DELIMITER ;;
CREATE PROCEDURE get_faktura(ordernr INT)
BEGIN
    
    SELECT
		f.kundnummer AS kundnummer,
		CONCAT(k.adress, ', ', k.postnummer, ', ', k.ort, ', ', k.land) AS adress,
        k.telefon AS telefon,
		CONCAT(k.fornamn, ' ', k.efternamn) AS kundnamn,
        p.produktkod AS produktkod,
        p.produktnamn AS produktnamn,
        p.pris AS pris,
        po.antal AS antal,
        po.ordernummer AS ordernummer,
        f.fakturanummer AS fakturanummer,
        f.faktura_status AS faktura_status,
        f.total_pris AS total_pris,
        f.payed_date AS betald_datum,
        o.sent AS sent,
		po.antal * p.pris AS radpris
        FROM faktura AS f
        INNER JOIN produktorder AS po
			ON po.ordernummer = f.ordernummer
		INNER JOIN produkt AS p
			ON p.produktkod = po.produktkod
		INNER JOIN kund as k
			ON k.kundnummer = f.kundnummer
		INNER JOIN orders AS o
			ON o.ordernummer = f.ordernummer
    WHERE f.ordernummer = ordernr;

END
;;
DELIMITER ;

-- 
-- Create procedure to pay faktura
-- 


DROP PROCEDURE IF EXISTS pay_faktura;
DELIMITER ;;
CREATE PROCEDURE pay_faktura(fknr INT, date_payed VARCHAR(40))
BEGIN
    UPDATE faktura
	SET faktura_status = "betald",
    payed_date = (SELECT FROM_UNIXTIME(date_payed))
	WHERE fakturanummer = fknr;

END
;;
DELIMITER ;
