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
  internal BOOLEAN,
  direction ENUM( 'I', 'O', 'N/A' ),
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
  name VARCHAR( 150 )
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
  DECLARE _name VARCHAR( 150 );
  DECLARE _startDate CHAR( 10 );
  DECLARE _critInternalDoc VARCHAR( 255 );
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
    mode_v_doc2jour DOUBLE,
    mode_v_jour2pub DOUBLE,
    mode_v_doc2pub DOUBLE,
    mode_p_doc2jour DOUBLE,
    mode_p_jour2pub DOUBLE,
    mode_p_doc2pub DOUBLE,
    average_doc2jour DOUBLE,
    average_jour2pub DOUBLE,
    average_doc2pub DOUBLE );
  SET _startDate = '2015-01-01';
  REPLACE INTO
    statistics(
      id_supplier,
      doc_count,
      max_doc_date,
      min_doc_date )
  SELECT
    id_supplier,
    COUNT( * ) AS doc_count,
    MAX( doc_date ) AS max_doc_date,
    MIN( doc_date ) AS min_doc_date
  FROM
    journal
  WHERE
    doc_date BETWEEN _startDate AND DATE_SUB( CURRENT_DATE(), INTERVAL 2 MONTH )
  GROUP BY
    id_supplier;
  OPEN curs;
  SET bDone = 0;
  SET _critInternalDoc = ' AND d.internal = TRUE';
  REPEAT
    FETCH curs INTO _id_supplier;
    SET @diffFields = 'doc2jour,jour2pub,doc2pub,';
    WHILE( LOCATE( ',', @diffFields ) > 0 )
    DO
      SET @fldN = SUBSTRING( @diffFields, 1, LOCATE( ',', @diffFields ) - 1 );
      SET @diffFields = SUBSTRING( @diffFields, LOCATE( ',', @diffFields ) + 1 );
      SET @wherePart = CONCAT( '
        d.id_supplier = ', _id_supplier, '
        AND
        d.doc_date BETWEEN \'', _startDate, '\' AND DATE_SUB( CURRENT_DATE(), INTERVAL 2 MONTH )' );
      SET @sqlCalcMedian = CONCAT( '
        UPDATE
          statistics AS m
            INNER JOIN (
              SELECT ',
                _id_supplier, ' AS id_supplier,
                AVG( t1.datediff_', @fldN, ' ) AS median_', @fldN, '
              FROM
              (
                SELECT
                  @rownum:=@rownum + 1 AS `row_number`,
                  d.datediff_', @fldN, '
                FROM
                  journal d, ( SELECT @rownum:=0 ) r
                WHERE
                  d.datediff_', @fldN, ' IS NOT NULL
                  AND ', @wherePart, '
                ORDER BY
                  d.datediff_', @fldN, '
              ) AS t1,
              (
                SELECT
                  COUNT(*) AS total_rows
                FROM
                  journal d
                WHERE
                  d.datediff_', @fldN, ' IS NOT NULL
                  AND ', @wherePart, '
              ) AS t2
              WHERE
                t1.row_number IN ( FLOOR( ( total_rows + 1 ) / 2 ), FLOOR( ( total_rows + 2 ) / 2 ) )
            ) AS n ON ( m.id_supplier = n.id_supplier )
        SET
          m.median_', @fldN, ' = n.median_', @fldN
      );
      SET @sqlCalcMode = CONCAT( '
        UPDATE
          statistics AS m
            INNER JOIN (
              SELECT ',
                _id_supplier, ' AS id_supplier,
                COUNT(*) AS cnt,
                d.datediff_', @fldN, ' AS mode_v_', @fldN, ',
                ROUND( COUNT( * ) * ( 100 / ( SELECT COUNT( * ) FROM journal WHERE id_supplier = ', _id_supplier, ' AND datediff_', @fldN, ' IS NOT NULL ) ) ) AS mode_p_', @fldN, '
              FROM
                journal d
              WHERE
                d.datediff_', @fldN, ' IS NOT NULL
                AND ', @wherePart, '
              GROUP BY
                d.datediff_', @fldN, '
              ORDER BY
                cnt DESC
              LIMIT 1 ) AS n
                  ON ( m.id_supplier = n.id_supplier )
        SET
          m.mode_v_', @fldN, ' = n.mode_v_', @fldN,',
          m.mode_p_', @fldN, ' = n.mode_p_', @fldN
      );
      PREPARE stmCalcMedian FROM @sqlCalcMedian;
      EXECUTE stmCalcMedian;
      DEALLOCATE PREPARE stmCalcMedian;
      PREPARE stmCalcMode FROM @sqlCalcMode;
      EXECUTE stmCalcMode;
      DEALLOCATE PREPARE stmCalcMode;
    END WHILE;
    SET @sqlCalcAverages = CONCAT( '
      UPDATE
        statistics AS m
          INNER JOIN (
            SELECT ',
              _id_supplier, ' AS id_supplier,
              AVG( d.datediff_doc2jour ) AS average_doc2jour,
              AVG( d.datediff_jour2pub ) AS average_jour2pub,
              AVG( d.datediff_doc2pub ) AS average_doc2pub
            FROM
              journal d
            WHERE ',
              @wherePart, '
            ) AS n
                ON ( m.id_supplier = n.id_supplier )
      SET
        m.average_doc2jour = n.average_doc2jour,
        m.average_jour2pub = n.average_jour2pub,
        m.average_doc2pub = n.average_doc2pub'
    );
    PREPARE stmCalcAverages FROM @sqlCalcAverages;
    EXECUTE stmCalcAverages;
    DEALLOCATE PREPARE stmCalcAverages;
  UNTIL bDone END REPEAT;
  UPDATE
    statistics s
      INNER JOIN (
        SELECT DISTINCT
          j.id_supplier,
          j.gov_body,
          u.name
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
    s.name_supplier = k.name;
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

CREATE PROCEDURE overviewModes()
BEGIN
  SELECT
    id_supplier,
    name_supplier AS name,
    doc_count,
    abbr_supplier AS label,
    mode_v_doc2jour AS doc2jour,
    mode_v_jour2pub AS jour2pub,
    mode_v_doc2pub AS doc2pub,
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
                               _internal BOOLEAN,
                               _direction ENUM( 'I', 'O', 'N/A' ),
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
         internal,
         direction,
         second_party,
         exception_basis,
         period )
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
     _internal,
     _direction,
     _second_party,
     _exception_basis,
     CONCAT( SUBSTRING( _doc_date, 1, 4 ), '-', SUBSTRING( _doc_date, 6, 2 ) ) );
  UPDATE
    journal
  SET
    datediff_doc2jour = DATEDIFF( _jour_date, _doc_date ),
    datediff_jour2pub = DATEDIFF( _pub_date, _jour_date ),
    datediff_doc2pub = DATEDIFF( _pub_date, _doc_date )
  WHERE
    gov_body = _gov_body
  AND
    case_year = _case_year
  AND
    case_num = _case_num
  AND
    doc_num = _doc_num
  AND
    _pub_date <= CURRENT_DATE()
  AND
    _jour_date <= _pub_date
  AND
    _doc_date <= _jour_date;
END;

CREATE PROCEDURE insertSupplier(
  _id_supplier INT UNSIGNED,
  _name VARCHAR( 150 ) )
BEGIN
   REPLACE INTO
       supplier (
         id_supplier,
         name )
   VALUES (
     _id_supplier,
     _name );
END;
