DROP DATABASE IF EXISTS %%database%%;
CREATE DATABASE %%database%% DEFAULT CHARSET 'utf8';
USE %%database%%;

CREATE TABLE journal (
  id_journal BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  id_supplier INT UNSIGNED NOT NULL,
  case_title TEXT,
  doc_title TEXT,
  case_year CHAR( 4 ),
  case_num INT UNSIGNED,
  doc_num INT UNSIGNED,
  gov_body VARCHAR( 30 ),
  doc_date DATE,
  jour_date DATE,
  pub_date DATE,
  direction ENUM( 'I', 'O' ),
  second_party TEXT,
  exception_basis VARCHAR( 150 ),
  datediff_doc2jour INT UNSIGNED,
  datediff_jour2pub INT UNSIGNED,
  datediff_doc2pub INT UNSIGNED,
  scrapetime TIMESTAMP,
  period CHAR( 7 ),
  INDEX idx_supplier ( id_supplier ),
  UNIQUE INDEX uidx_doc_identity ( gov_body, case_year, case_num, doc_num )
);

CREATE TABLE supplier (
  id_supplier INT UNSIGNED PRIMARY KEY,
  navn VARCHAR( 150 )
);

CREATE TABLE clouds(
  ord VARCHAR( 100 ),
  vekt INT,
  id_supplier INT UNSIGNED
);

CREATE PROCEDURE getCloudDatasets( _id_supplier INT UNSIGNED )
BEGIN
  SELECT
    DATEDIFF( pub_date, doc_date ) AS forsinkelse,
    LOWER( doc_title ) AS doc_title
  FROM
    journal
  WHERE
    pub_date > doc_date
  AND
    pub_date < CURRENT_DATE()
  AND
    ( _id_supplier = 0 OR _id_supplier = id_supplier )
  ORDER BY
    forsinkelse
      DESC
  LIMIT
    10000;
  SELECT
    DATEDIFF( pub_date, doc_date ) AS forsinkelse,
    LOWER( doc_title ) AS doc_title
  FROM
    journal
  WHERE
    pub_date > doc_date
  AND
    pub_date < CURRENT_DATE()
  AND
    ( _id_supplier = 0 OR _id_supplier = id_supplier )
  ORDER BY
    forsinkelse
      ASC
  LIMIT
    10000;
END;

CREATE PROCEDURE getCloudDatasetsInv( _id_supplier INT UNSIGNED )
BEGIN
  SELECT
    DATEDIFF( pub_date, doc_date ) AS forsinkelse,
    LOWER( doc_title ) AS doc_title
  FROM
    journal
  WHERE
    pub_date > doc_date
  AND
    pub_date < CURRENT_DATE()
  AND
    ( _id_supplier = 0 OR _id_supplier = id_supplier )
  ORDER BY
    forsinkelse
      ASC
  LIMIT
    10000;
  SELECT

    DATEDIFF( pub_date, doc_date ) AS forsinkelse,
    LOWER( doc_title ) AS doc_title
  FROM
    journal
  WHERE
    pub_date > doc_date
  AND
    pub_date < CURRENT_DATE()
  AND
    ( _id_supplier = 0 OR _id_supplier = id_supplier )
  ORDER BY
    forsinkelse
      DESC
  LIMIT
    10000;
END;

CREATE PROCEDURE regenStatistics()
BEGIN
  DECLARE bDone INT;
  DECLARE _id_supplier INT UNSIGNED;
  DECLARE _navn VARCHAR( 150 );
  DECLARE curs CURSOR FOR SELECT DISTINCT id_supplier FROM supplier;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET bDone = 1;

  DROP TABLE IF EXISTS statistics;

  CREATE TABLE statistics(
    id_supplier INT UNSIGNED PRIMARY KEY,
    abbr_supplier VARCHAR( 30 ),
    name_supplier VARCHAR( 150 ),
    period CHAR( 7 ),
    doc_count INT UNSIGNED,
    max_doc_date DATE,
    min_doc_date DATE,
    median_doc2jour DOUBLE,
    median_jour2pub DOUBLE,
    median_doc2pub DOUBLE,
    modal_v_doc2jour DOUBLE,
    modal_v_jour2pub DOUBLE,
    modal_v_doc2pub DOUBLE,
    modal_p_doc2jour DOUBLE,
    modal_p_jour2pub DOUBLE,
    modal_p_doc2pub DOUBLE,
    average_doc2jour DOUBLE,
    average_jour2pub DOUBLE,
    average_doc2pub DOUBLE );

  OPEN curs;
  SET bDone = 0;

  REPEAT
    FETCH curs INTO _id_supplier;
    REPLACE INTO
      statistics( id_supplier, doc_count, median_doc2pub )
    SELECT
      _id_supplier AS id_supplier,
      COUNT( * ) AS doc_count,
      AVG( t1.datediff_doc2pub ) AS median_doc2pub
    FROM
    (
      SELECT
        @rownum:=@rownum + 1 AS `row_number`,
        d.datediff_doc2pub
      FROM
        journal d, ( SELECT @rownum:=0 ) r
      WHERE
        d.datediff_doc2pub IS NOT NULL
      AND
        d.id_supplier = _id_supplier
      AND
        d.doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
      ORDER BY
        d.datediff_doc2pub
    ) AS t1,
    (
      SELECT
        COUNT(*) AS total_rows
      FROM
        journal d
      WHERE
        d.datediff_doc2pub IS NOT NULL
      AND
        d.id_supplier = _id_supplier
      AND
        d.doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
    ) AS t2
    WHERE 1
    AND
      t1.row_number IN ( FLOOR( ( total_rows + 1 ) / 2 ), FLOOR( ( total_rows + 2 ) / 2 ) );
    UPDATE
      statistics AS m
        INNER JOIN (
          SELECT
            _id_supplier AS id_supplier,
            AVG( t1.datediff_doc2jour ) AS median_doc2jour
          FROM
          (
            SELECT
              @rownum:=@rownum + 1 AS `row_number`,
              d.datediff_doc2jour
            FROM
              journal d, ( SELECT @rownum:=0 ) r
            WHERE
              d.datediff_doc2jour IS NOT NULL
            AND
              d.id_supplier = _id_supplier
            AND
              d.doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
            ORDER BY
              d.datediff_doc2jour
          ) AS t1,
          (
            SELECT
              COUNT(*) AS total_rows
            FROM
              journal d
            WHERE
              d.datediff_doc2jour IS NOT NULL
            AND
              d.id_supplier = _id_supplier
            AND
              d.doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
          ) AS t2
          WHERE 1
          AND
            t1.row_number IN ( FLOOR( ( total_rows + 1 ) / 2 ), FLOOR( ( total_rows + 2 ) / 2 ) )
        ) AS n ON ( m.id_supplier = n.id_supplier )
    SET
      m.median_doc2jour = n.median_doc2jour;
    UPDATE
      statistics AS m
        INNER JOIN (
          SELECT
            _id_supplier AS id_supplier,
            AVG( t1.datediff_jour2pub ) AS median_jour2pub
          FROM
          (
            SELECT
              @rownum:=@rownum + 1 AS `row_number`,
              d.datediff_jour2pub
            FROM
              journal d, ( SELECT @rownum:=0 ) r
            WHERE
              d.datediff_jour2pub IS NOT NULL
            AND
              d.id_supplier = _id_supplier
            AND
              d.doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
            ORDER BY
              d.datediff_jour2pub
          ) AS t1,
          (
            SELECT
              COUNT(*) AS total_rows
            FROM
              journal d
            WHERE
              d.datediff_jour2pub IS NOT NULL
            AND
              d.id_supplier = _id_supplier
            AND
              d.doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
          ) AS t2
          WHERE 1
          AND
            t1.row_number IN ( FLOOR( ( total_rows + 1 ) / 2 ), FLOOR( ( total_rows + 2 ) / 2 ) )
        ) AS n ON ( m.id_supplier = n.id_supplier )
    SET
      m.median_jour2pub = n.median_jour2pub;
    UPDATE
      statistics AS m
        INNER JOIN (
          SELECT
            _id_supplier AS id_supplier,
            AVG( datediff_doc2jour ) AS average_doc2jour,
            AVG( datediff_jour2pub ) AS average_jour2pub,
            AVG( datediff_doc2pub ) AS average_doc2pub
          FROM
            journal
          WHERE
            id_supplier = _id_supplier
          AND
            doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
          ) AS n
              ON ( m.id_supplier = n.id_supplier )
    SET
      m.average_doc2jour = n.average_doc2jour,
      m.average_jour2pub = n.average_jour2pub,
      m.average_doc2pub = n.average_doc2pub;
    UPDATE
      statistics AS m
        INNER JOIN (
          SELECT
            _id_supplier AS id_supplier,
            COUNT(*) AS cnt,
            datediff_doc2jour AS modal_v_doc2jour,
            ROUND( COUNT( * ) * ( 100 / ( SELECT COUNT( * ) FROM journal WHERE id_supplier = _id_supplier AND datediff_doc2jour IS NOT NULL ) ) ) AS modal_p_doc2jour
          FROM
            journal
          WHERE
            id_supplier = _id_supplier
          AND
            datediff_doc2jour IS NOT NULL
          AND
            doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
          GROUP BY
            datediff_doc2jour
          ORDER BY
            cnt DESC
          LIMIT 1 ) AS n
              ON ( m.id_supplier = n.id_supplier )
    SET
      m.modal_v_doc2jour = n.modal_v_doc2jour,
      m.modal_p_doc2jour = n.modal_p_doc2jour;
    UPDATE
      statistics AS m
        INNER JOIN (
          SELECT
            _id_supplier AS id_supplier,
            COUNT(*) AS n,
            datediff_jour2pub AS modal_v_jour2pub,
            ROUND( COUNT( * ) * ( 100 / ( SELECT COUNT( * ) FROM journal WHERE id_supplier = _id_supplier AND datediff_jour2pub IS NOT NULL ) ) ) AS modal_p_jour2pub
          FROM
            journal
          WHERE
            id_supplier = _id_supplier
          AND
            datediff_jour2pub IS NOT NULL
          AND
            doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
          GROUP BY
            datediff_jour2pub
          ORDER BY
            n DESC
          LIMIT 1 ) AS n
              ON ( m.id_supplier = n.id_supplier )
    SET
      m.modal_v_jour2pub = n.modal_v_jour2pub,
      m.modal_p_jour2pub = n.modal_p_jour2pub;
    UPDATE
      statistics AS m
        INNER JOIN (
          SELECT
            _id_supplier AS id_supplier,
            COUNT(*) AS n,
            datediff_doc2pub AS modal_v_doc2pub,
            ROUND( COUNT( * ) * ( 100 / ( SELECT COUNT( * ) FROM journal WHERE id_supplier = _id_supplier AND datediff_doc2pub IS NOT NULL ) ) ) AS modal_p_doc2pub
          FROM
            journal
          WHERE
            id_supplier = _id_supplier
          AND
            datediff_doc2pub IS NOT NULL
          AND
            doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
          GROUP BY
            datediff_doc2pub
          ORDER BY
            n DESC
          LIMIT 1 ) AS n
              ON ( m.id_supplier = n.id_supplier )
    SET
      m.modal_v_doc2pub = n.modal_v_doc2pub,
      m.modal_p_doc2pub = n.modal_p_doc2pub;
  UNTIL bDone END REPEAT;
  UPDATE
    statistics s
      INNER JOIN (
        SELECT DISTINCT
          j.id_supplier,
          j.gov_body,
          u.navn
        FROM
          journal j
            INNER JOIN
              supplier u
                ON ( j.id_supplier = u.id_supplier )
        WHERE
          gov_body IS NOT NULL ) k
            ON ( s.id_supplier = k.id_supplier )
  SET
    s.abbr_supplier = k.gov_body,
    s.name_supplier = k.navn;
  UPDATE
    statistics s
      INNER JOIN (
        SELECT
          id_supplier,
          COUNT( * ) AS doc_count,
          MAX( doc_date ) AS max_doc_date,
          MIN( doc_date ) AS min_doc_date
        FROM
          journal
        WHERE
          datediff_doc2pub IS NOT NULL
        AND
          doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
        GROUP BY id_supplier ) j
            ON ( s.id_supplier = j.id_supplier )
  SET
    s.doc_count = j.doc_count,
    s.max_doc_date = j.max_doc_date,
    s.min_doc_date = j.min_doc_date;
END;
CREATE PROCEDURE overviewAverages()
BEGIN
  SELECT
    id_supplier,
    name_supplier AS name,
    abbr_supplier AS label,
    doc_count,
    average_doc2jour AS doc2jour,
    average_doc2pub - average_doc2jour AS jour2pub,
    average_doc2pub AS doc2pub,
    max_doc_date AS max_date,
    min_doc_date AS min_date
  FROM
    statistics
  ORDER BY
    doc2pub DESC;
END;

CREATE PROCEDURE overviewMedians()
BEGIN
  SELECT
    id_supplier,
    name_supplier AS name,
    abbr_supplier AS label,
    doc_count,
    median_doc2jour AS doc2jour,
    median_jour2pub AS jour2pub,
    median_doc2pub AS doc2pub,
    max_doc_date AS max_date,
    min_doc_date AS min_date
  FROM
    statistics
  ORDER BY
    doc2pub DESC;
END;

CREATE PROCEDURE overviewModals()
BEGIN
  SELECT
    id_supplier,
    name_supplier AS name,
    abbr_supplier AS label,
    doc_count,
    modal_v_doc2jour AS doc2jour,
    modal_v_jour2pub AS jour2pub,
    modal_v_doc2pub AS doc2pub,
    max_doc_date AS max_date,
    min_doc_date AS min_date
  FROM
    statistics
  ORDER BY
    doc2pub DESC;
END;

CREATE PROCEDURE insertRecord( _id_supplier INT UNSIGNED,
                               _case_title TEXT,
                               _doc_title TEXT,
                               _case_year CHAR( 4 ),
                               _case_num INT UNSIGNED,
                               _doc_num INT UNSIGNED,
                               _gov_body VARCHAR( 30 ),
                               _doc_date DATE,
                               _jour_date DATE,
                               _pub_date DATE,
                               _direction ENUM( 'I', 'O' ),
                               _second_party TEXT,
                               _exception_basis VARCHAR( 150 ) )
BEGIN
   REPLACE INTO
       journal (
         id_supplier,
         case_title,
         doc_title,
         case_year,
         case_num,
         doc_num,
         gov_body,
         doc_date,
         jour_date,
         pub_date,
         direction,
         second_party,
         exception_basis,
         period,
         datediff_doc2jour,
         datediff_jour2pub,
         datediff_doc2pub )
   VALUES (
     _id_supplier,
     _case_title,
     _doc_title,
     _case_year,
     _case_num,
     _doc_num,
     _gov_body,
     _doc_date,
     _jour_date,
     _pub_date,
     _direction,
     _second_party,
     _exception_basis,
     CONCAT( SUBSTRING( _doc_date, 1, 4 ), '-', SUBSTRING( _doc_date, 6, 2 ) ),
     DATEDIFF( _jour_date, _doc_date ),
     DATEDIFF( _pub_date, _jour_date ),
     DATEDIFF( _pub_date, _doc_date ) );
END;

CREATE PROCEDURE insertSupplier( _id_supplier INT UNSIGNED,
                                 _navn VARCHAR( 150 ) )
BEGIN
   REPLACE INTO
       supplier (
         id_supplier,
         navn )
   VALUES (
     _id_supplier,
     _navn );
END;
