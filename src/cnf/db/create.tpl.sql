DROP DATABASE IF EXISTS %%database%%;
CREATE DATABASE %%database%% DEFAULT CHARSET 'utf8';
USE %%database%%;

DROP FUNCTION IF EXISTS bound;
DROP FUNCTION IF EXISTS bround;
DROP FUNCTION IF EXISTS corr;
DROP FUNCTION IF EXISTS covariance;
DROP FUNCTION IF EXISTS cut;
DROP FUNCTION IF EXISTS fnv;
DROP FUNCTION IF EXISTS getint;
DROP FUNCTION IF EXISTS group_first;
DROP FUNCTION IF EXISTS group_last;
DROP FUNCTION IF EXISTS invbit;
DROP FUNCTION IF EXISTS isbit;
DROP FUNCTION IF EXISTS kurtosis;
DROP FUNCTION IF EXISTS lessavg;
DROP FUNCTION IF EXISTS lesspartpct;
DROP FUNCTION IF EXISTS lesspart;
DROP FUNCTION IF EXISTS median;
DROP FUNCTION IF EXISTS stats_mode;
DROP FUNCTION IF EXISTS ngram;
DROP FUNCTION IF EXISTS noverk;
DROP FUNCTION IF EXISTS percentile_cont;
DROP FUNCTION IF EXISTS percentile_disc;
DROP FUNCTION IF EXISTS rotbit;
DROP FUNCTION IF EXISTS rotint;
DROP FUNCTION IF EXISTS row_number;
DROP FUNCTION IF EXISTS rsumd;
DROP FUNCTION IF EXISTS rsumi;
DROP FUNCTION IF EXISTS setbit;
DROP FUNCTION IF EXISTS setint;
DROP FUNCTION IF EXISTS skewness;
DROP FUNCTION IF EXISTS slug;
DROP FUNCTION IF EXISTS xround;
CREATE FUNCTION bound RETURNS real SONAME 'udf_infusion.so';
CREATE FUNCTION bround RETURNS real SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION corr RETURNS real SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION covariance RETURNS real SONAME 'udf_infusion.so';
CREATE FUNCTION cut RETURNS string SONAME 'udf_infusion.so';
CREATE FUNCTION fnv RETURNS integer SONAME 'udf_infusion.so';
CREATE FUNCTION getint RETURNS integer SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION group_first RETURNS string SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION group_last RETURNS string SONAME 'udf_infusion.so';
CREATE FUNCTION invbit RETURNS integer SONAME 'udf_infusion.so';
CREATE FUNCTION isbit RETURNS integer SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION kurtosis RETURNS real SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION lessavg RETURNS integer SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION lesspartpct RETURNS integer SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION lesspart RETURNS integer SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION median RETURNS real SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION stats_mode RETURNS real SONAME 'udf_infusion.so';
CREATE FUNCTION ngram RETURNS string SONAME 'udf_infusion.so';
CREATE FUNCTION noverk RETURNS integer SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION percentile_cont RETURNS real SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION percentile_disc RETURNS real SONAME 'udf_infusion.so';
CREATE FUNCTION rotbit RETURNS integer SONAME 'udf_infusion.so';
CREATE FUNCTION rotint RETURNS integer SONAME 'udf_infusion.so';
CREATE FUNCTION row_number RETURNS integer SONAME 'udf_infusion.so';
CREATE FUNCTION rsumd RETURNS real SONAME 'udf_infusion.so';
CREATE FUNCTION rsumi RETURNS integer SONAME 'udf_infusion.so';
CREATE FUNCTION setbit RETURNS integer SONAME 'udf_infusion.so';
CREATE FUNCTION setint RETURNS integer SONAME 'udf_infusion.so';
CREATE AGGREGATE FUNCTION skewness RETURNS real SONAME 'udf_infusion.so';
CREATE FUNCTION slug RETURNS string SONAME 'udf_infusion.so';
CREATE FUNCTION xround RETURNS integer SONAME 'udf_infusion.so';

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

CREATE PROCEDURE createCalendarTable()
BEGIN

  DECLARE _dateCur DATE;
  DECLARE _dateEnd DATE;

  DROP TABLE IF EXISTS calendar;
  CREATE TABLE calendar (
    cal_date DATE NOT NULL PRIMARY KEY,
    workday BOOLEAN NOT NULL DEFAULT TRUE );

  SET _dateCur = '2010-01-01';
  SET _dateEnd = '2016-12-31';

  WHILE _dateCur <= _dateEnd DO

    INSERT INTO
      calendar (
        cal_date,
        workday )
    VALUES (
      _dateCur,
      IF( DATE_FORMAT( _dateCur, '%w' ) IN ( 0, 6 ), FALSE, TRUE )
    );
    SET _dateCur := _dateCur + INTERVAL 1 DAY;

  END WHILE;

  UPDATE
    calendar
  SET
    workday = FALSE
  WHERE
    cal_date IN(
      '2010-01-01', '2010-04-01', '2010-04-02', '2010-04-05', '2010-05-01',
      '2010-05-13', '2010-05-17', '2010-05-24',
      '2011-01-01', '2011-04-21', '2011-04-22', '2011-04-25', '2011-05-01',
      '2011-05-17', '2011-05-24', '2011-06-02', '2011-06-13', '2011-12-26',
      '2012-01-01', '2012-04-05', '2012-04-06', '2012-04-09', '2012-05-01',
      '2012-05-17', '2012-05-28', '2012-12-25', '2012-12-26',
      '2013-01-01', '2013-03-28', '2013-03-29', '2013-04-01', '2013-05-01',
      '2013-05-09', '2013-05-17', '2013-05-20', '2013-12-25', '2013-12-26',
      '2014-01-01', '2014-04-17', '2014-04-18', '2014-04-21', '2014-05-01',
      '2014-05-17', '2014-05-29', '2014-06-09', '2014-12-25', '2014-12-26',
      '2015-01-01', '2015-04-02', '2015-04-03', '2015-04-06', '2015-05-01',
      '2015-05-17', '2015-05-14', '2015-05-25', '2015-12-25', '2015-12-26',
      '2016-01-01', '2016-03-24', '2016-03-25', '2016-03-28', '2016-05-01',
      '2016-05-05', '2016-05-16', '2016-05-17', '2016-12-25', '2016-12-26' );
END;

CALL createCalendarTable();

CREATE FUNCTION datediff_workdays( _d1 DATE, _d2 DATE ) RETURNS INT UNSIGNED
DETERMINISTIC
BEGIN
  DECLARE _workdays INT UNSIGNED;
  SET _workdays = 0;
  SELECT
    COUNT( * )
      INTO _workdays
  FROM
    calendar
  WHERE
    cal_date BETWEEN _d2 AND _d1
  AND
    workday = TRUE;
  RETURN _workdays;
END;

CREATE PROCEDURE regenStatistics()
BEGIN

  DECLARE _startDate DATE;
  DECLARE _period CHAR( 7 );
  DECLARE _id_supplier INT UNSIGNED;

  DECLARE _bDone BOOL;
  DECLARE _bDoneTmp BOOL;

  DECLARE
    _cursPeriod
      CURSOR FOR
        SELECT DISTINCT
          period
        FROM
          journal
        WHERE
          doc_date BETWEEN '2015-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 2 MONTH )
        UNION
          SELECT
            '0000-00' AS period
        ORDER BY
          period;

  DECLARE
    _cursSupplier
      CURSOR FOR
        SELECT
          id_supplier
        FROM
          supplier
        UNION
          SELECT
            0 AS id_supplier;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET _bDone = 1;

  SET _startDate = '2015-01-01';

  DROP TABLE IF EXISTS statistics;
  CREATE TABLE statistics(
    id_supplier INT UNSIGNED,
    period CHAR( 7 ),
    abbr_supplier VARCHAR( 30 ),
    name_supplier VARCHAR( 150 ),
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
    mean_doc2jour DOUBLE,
    mean_jour2pub DOUBLE,
    mean_doc2pub DOUBLE,
    PRIMARY KEY idx_identity ( id_supplier, period ) );

  OPEN _cursPeriod;

    SET _bDone = 0;
    REPEAT

      FETCH _cursPeriod INTO _period;
      SET _bDoneTmp = _bDone;
      OPEN _cursSupplier;

        SET _bDone = 0;
        REPEAT

          FETCH _cursSupplier INTO _id_supplier;

          REPLACE INTO
            statistics(
              id_supplier,
              period,
              doc_count,
              max_doc_date,
              min_doc_date,
              mean_doc2jour,
              mean_jour2pub,
              mean_doc2pub,
              median_doc2jour,
              median_jour2pub,
              median_doc2pub,
              mode_v_doc2jour,
              mode_v_jour2pub,
              mode_v_doc2pub )
          SELECT
            _id_supplier,
            _period,
            COUNT( * ) AS doc_count,
            MAX( doc_date ) AS max_doc_date,
            MIN( doc_date ) AS min_doc_date,
            AVG( datediff_doc2jour ),
            AVG( datediff_jour2pub ),
            AVG( datediff_doc2pub ),
            MEDIAN( datediff_doc2jour ),
            MEDIAN( datediff_jour2pub ),
            MEDIAN( datediff_doc2pub ),
            STATS_MODE( datediff_doc2jour ),
            STATS_MODE( datediff_jour2pub ),
            STATS_MODE( datediff_doc2pub )
          FROM
            journal
          WHERE
            doc_date BETWEEN _startDate AND DATE_SUB( CURRENT_DATE(), INTERVAL 2 MONTH )
          AND
            ( _id_supplier = 0 OR _id_supplier LIKE id_supplier )
          AND
            ( _period LIKE '0000-00' OR _period LIKE period );

        UNTIL _bDone END REPEAT;

      CLOSE _cursSupplier;
      SET _bDone = _bDoneTmp;

    UNTIL _bDone END REPEAT;

  CLOSE _cursPeriod;

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
    datediff_doc2jour = datediff_workdays( _jour_date, _doc_date ),
    datediff_jour2pub = datediff_workdays( _pub_date, _jour_date ),
    datediff_doc2pub = datediff_workdays( _pub_date, _doc_date )
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

CREATE PROCEDURE getListSuppliers()
BEGIN
  SELECT * FROM supplier ORDER BY name;
END;

CREATE PROCEDURE getOverview(
  dataset VARCHAR( 10 ),
  aggregate VARCHAR( 10 ),
  sortcrit VARCHAR( 10 ) )
BEGIN

  SET @sql = CONCAT( '
    SELECT
      id_supplier,
      name_supplier AS label_longname,
      abbr_supplier AS label, ',
      aggregate, '_', dataset, ' AS value
    FROM
      statistics
    WHERE
      period LIKE \'0000-00\'
    AND
      id_supplier > 0
    ORDER BY ',
      aggregate, '_', sortcrit, ' DESC' );

  PREPARE stm FROM @sql;
  EXECUTE stm;
  DEALLOCATE PREPARE stm;

END;

CREATE PROCEDURE getTimeline(
  _dataset VARCHAR( 10 ),
  _aggregate VARCHAR( 10 ),
  _id_supplier INT UNSIGNED )
BEGIN

  SET @sql = CONCAT( '
    SELECT
      period AS label, ',
      _aggregate, '_', _dataset, ' AS value
    FROM
      statistics
    WHERE
      period NOT LIKE \'0000-00\'
    AND
      id_supplier = ', _id_supplier, '
    ORDER BY
      period ASC' );

  PREPARE stm FROM @sql;
  EXECUTE stm;
  DEALLOCATE PREPARE stm;

END;
