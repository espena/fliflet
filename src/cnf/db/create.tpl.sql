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
  datediff_workdays_doc2jour INT UNSIGNED,
  datediff_workdays_jour2pub INT UNSIGNED,
  datediff_workdays_doc2pub INT UNSIGNED,
  datediff_abs_doc2jour INT UNSIGNED,
  datediff_abs_jour2pub INT UNSIGNED,
  datediff_abs_doc2pub INT UNSIGNED,
  scrapetime TIMESTAMP,
  period CHAR( 7 ),
  INDEX idx_supplier ( id_supplier ),
  UNIQUE INDEX uidx_doc_identity ( gov_body, case_year, case_num, doc_num ),
  INDEX idx_doc_date ( doc_date ),
  INDEX idx_jour_date ( jour_date ),
  INDEX idx_pub_date ( pub_date )
) COMMENT 'doc_date';

CREATE TABLE supplier (
  id_supplier INT UNSIGNED PRIMARY KEY,
  name VARCHAR( 150 )
);

CREATE FUNCTION periodBias() RETURNS VARCHAR( 10 )
DETERMINISTIC
BEGIN
  DECLARE _bias VARCHAR( 10 );
  SELECT
    table_comment
  INTO
    _bias
  FROM
    INFORMATION_SCHEMA.TABLES
  WHERE
    table_schema = '%%database%%'
  AND
    table_name = 'journal';
  RETURN _bias;
END;

CREATE FUNCTION easterSunday( _strYear CHAR( 4 ) ) RETURNS DATE
DETERMINISTIC
BEGIN

  DECLARE _year INT;
  DECLARE _a INT;
  DECLARE _b INT;
  DECLARE _c INT;
  DECLARE _d INT;
  DECLARE _e INT;
  DECLARE _f INT;
  DECLARE _g INT;
  DECLARE _h INT;
  DECLARE _i INT;
  DECLARE _k INT;
  DECLARE _l INT;
  DECLARE _m INT;
  DECLARE _n INT;
  DECLARE _p INT;

  SET _year = CAST( _strYear AS SIGNED );
  SET _a = MOD( _year, 19 );
  SET _b = FLOOR( _year / 100 );
  SET _c = MOD( _year, 100 );
  SET _d = FLOOR( _b / 4 );
  SET _e = MOD( _b, 4 );
  SET _f = FLOOR( ( _b + 8 ) / 25 );
  SET _g = FLOOR( ( _b - _f + 1 ) / 3 );
  SET _h = MOD( 19 * _a + _b - _d - _g + 15, 30 );
  SET _i = FLOOR( _c / 4 );
  SET _k = MOD( _c, 4 );
  SET _l = MOD( 32 + 2 * _e + 2 * _i - _h - _k, 7 );
  SET _m = FLOOR( ( _a + 11 * _h + 22 * _l ) / 451 );
  SET _n = FLOOR( ( _h + _l - 7 * _m + 114 ) / 31 );
  SET _p = MOD( _h + _l - 7 * _m + 114, 31 );
  SET _p = _p + 1;

  RETURN CONCAT( _strYear, '-', LPAD( CAST( _n AS CHAR ), 2, '0' ), '-', LPAD( CAST( _p AS CHAR ), 2, '0' ) );

END;

CREATE PROCEDURE rebasePeriod( _d ENUM( 'doc_date', 'jour_date', 'pub_date' ) )
BEGIN
  UPDATE journal SET period = NULL;
  SET @sql = CONCAT( '
    UPDATE
      journal
    SET
      period = SUBSTRING( ', _d, ', 1, 7 )
    WHERE
      doc_date > \'1979-12-31\'
    AND
      doc_date <= jour_date
    AND
      jour_date <= pub_date
    AND
      pub_date <= CURRENT_DATE()' );
  PREPARE stm FROM @sql;
  EXECUTE stm;
  DEALLOCATE PREPARE stm;
  SET @sql = CONCAT( 'ALTER TABLE journal COMMENT \'', _d, '\'' );
  PREPARE stm FROM @sql;
  EXECUTE stm;
  DEALLOCATE PREPARE stm;
END;

CREATE PROCEDURE createCalendarTable()
BEGIN

  DECLARE _dateBgn DATE;
  DECLARE _dateEnd DATE;
  DECLARE _dateCur DATE;
  DECLARE _year CHAR( 4 );
  DECLARE _easterSunday DATE;

  DROP TABLE IF EXISTS calendar;
  CREATE TABLE calendar (
    cal_date DATE NOT NULL PRIMARY KEY,
    workday BOOLEAN NOT NULL DEFAULT TRUE );

  SET _dateBgn = '1900-01-01';
  SET _dateEnd = '2020-01-01';

  SET _dateCur = _dateBgn;
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

  SET _dateCur = _dateBgn;
  WHILE _dateCur <= _dateEnd DO

    SET _year = YEAR( _dateCur );
    SET _easterSunday = easterSunday( _year );

    UPDATE
      calendar
    SET
      workday = FALSE
    WHERE
      cal_date IN (
        DATE_SUB( _easterSunday, INTERVAL 3 DAY ),
        DATE_SUB( _easterSunday, INTERVAL 2 DAY ),
        DATE_ADD( _easterSunday, INTERVAL 1 DAY ),
        DATE_ADD( _easterSunday, INTERVAL 39 DAY ),
        DATE_ADD( _easterSunday, INTERVAL 49 DAY ),
        DATE_ADD( _easterSunday, INTERVAL 50 DAY ),
        CONCAT( _year, '-01-01' ),
        CONCAT( _year, '-05-01' ),
        CONCAT( _year, '-05-17' ),
        CONCAT( _year, '-12-25' ),
        CONCAT( _year, '-12-26' ) );

    SET _dateCur := _dateCur + INTERVAL 1 YEAR;

  END WHILE;

  ALTER TABLE calendar ADD INDEX idx_workday( workday );

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
    cal_date >= _d2
  AND
    cal_date < _d1
  AND
    workday = TRUE;
  RETURN _workdays;
END;

CREATE PROCEDURE regenStatistics()
BEGIN

  DECLARE _startDate DATE;
  DECLARE _period CHAR( 7 );
  DECLARE _id_supplier INT UNSIGNED;
  DECLARE _direction VARCHAR( 2 );

  DECLARE _bDone BOOL;
  DECLARE _bDoneTmp BOOL;
  DECLARE _bDoneTmp2 BOOL;

  DECLARE
    _cursPeriod
      CURSOR FOR
        SELECT DISTINCT
          period
        FROM
          journal
        WHERE
          period IS NOT NULL
        AND
          pub_date BETWEEN '2011-01-01' AND DATE_SUB( CURRENT_DATE(), INTERVAL 2 WEEK )
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

  DECLARE
    _cursDirection
      CURSOR FOR
        SELECT
          'IO' AS direction
        UNION
          SELECT
            'I' AS direction
        UNION
          SELECT
            'O' AS direction;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET _bDone = 1;

  SET _startDate = '2011-01-01';

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
    median_abs_doc2jour DOUBLE,
    median_abs_jour2pub DOUBLE,
    median_abs_doc2pub DOUBLE,
    mode_v_doc2jour DOUBLE,
    mode_v_jour2pub DOUBLE,
    mode_v_doc2pub DOUBLE,
    mode_v_abs_doc2jour DOUBLE,
    mode_v_abs_jour2pub DOUBLE,
    mode_v_abs_doc2pub DOUBLE,
    mode_p_doc2jour DOUBLE,
    mode_p_jour2pub DOUBLE,
    mode_p_doc2pub DOUBLE,
    mean_doc2jour DOUBLE,
    mean_jour2pub DOUBLE,
    mean_doc2pub DOUBLE,
    mean_abs_doc2jour DOUBLE,
    mean_abs_jour2pub DOUBLE,
    mean_abs_doc2pub DOUBLE,
    stddev_doc2jour DOUBLE,
    stddev_jour2pub DOUBLE,
    stddev_doc2pub DOUBLE,
    direction ENUM( 'I', 'O', 'IO' ),
    PRIMARY KEY idx_identity ( id_supplier, period, direction ) );

  OPEN _cursPeriod;

    SET _bDone = 0;
    REPEAT

      FETCH _cursPeriod INTO _period;
      SET _bDoneTmp = _bDone;
      OPEN _cursSupplier;

        SET _bDone = 0;
        REPEAT

          FETCH _cursSupplier INTO _id_supplier;
          SET _bDoneTmp2 = _bDone;
          OPEN _cursDirection;

            SET _bDone = 0;
            REPEAT

              FETCH _cursDirection INTO _direction;

              REPLACE INTO
                statistics(
                  id_supplier,
                  period,
                  doc_count,
                  max_doc_date,
                  min_doc_date,
                  stddev_doc2jour,
                  stddev_jour2pub,
                  stddev_doc2pub,
                  mean_doc2jour,
                  mean_jour2pub,
                  mean_doc2pub,
                  mean_abs_doc2jour,
                  mean_abs_jour2pub,
                  mean_abs_doc2pub,
                  median_doc2jour,
                  median_jour2pub,
                  median_doc2pub,
                  median_abs_doc2jour,
                  median_abs_jour2pub,
                  median_abs_doc2pub,
                  mode_v_doc2jour,
                  mode_v_jour2pub,
                  mode_v_doc2pub,
                  mode_v_abs_doc2jour,
                  mode_v_abs_jour2pub,
                  mode_v_abs_doc2pub,
                  direction )
              SELECT
                _id_supplier,
                _period,
                COUNT( * ) AS doc_count,
                MAX( doc_date ) AS max_doc_date,
                MIN( doc_date ) AS min_doc_date,
                STDDEV_POP( datediff_workdays_doc2jour ),
                STDDEV_POP( datediff_workdays_jour2pub ),
                STDDEV_POP( datediff_workdays_doc2pub ),
                AVG( datediff_workdays_doc2jour ),
                AVG( datediff_workdays_jour2pub ),
                AVG( datediff_workdays_doc2pub ),
                AVG( datediff_abs_doc2jour ),
                AVG( datediff_abs_jour2pub ),
                AVG( datediff_abs_doc2pub ),
                MEDIAN( datediff_workdays_doc2jour ),
                MEDIAN( datediff_workdays_jour2pub ),
                MEDIAN( datediff_workdays_doc2pub ),
                MEDIAN( datediff_abs_doc2jour ),
                MEDIAN( datediff_abs_jour2pub ),
                MEDIAN( datediff_abs_doc2pub ),
                STATS_MODE( datediff_workdays_doc2jour ),
                STATS_MODE( datediff_workdays_jour2pub ),
                STATS_MODE( datediff_workdays_doc2pub ),
                STATS_MODE( datediff_abs_doc2jour ),
                STATS_MODE( datediff_abs_jour2pub ),
                STATS_MODE( datediff_abs_doc2pub ),
                _direction
              FROM
                journal
              WHERE
                ( _id_supplier = 0 OR _id_supplier LIKE id_supplier )
              AND
                ( _period = period OR ( _period = '0000-00' AND period >= '2015-01' AND period <= '2016-08' ) )
              AND
                ( _direction = direction OR _direction = 'IO' );

            UNTIL _bDone END REPEAT;

          CLOSE _cursDirection;
          SET _bDone = _bDoneTmp2;

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
  DECLARE _date_bias DATE;
  SET @dateBiasCol = periodBias();
  CASE @dateBiasCol
    WHEN 'doc_date' THEN SET _date_bias = _doc_date;
    WHEN 'jour_date' THEN SET _date_bias = _jour_date;
    WHEN 'pub_date' THEN SET _date_bias = _pub_date;
  END CASE;
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
     CONCAT( SUBSTRING( _date_bias, 1, 4 ), '-', SUBSTRING( _date_bias, 6, 2 ) ) );
  UPDATE
    journal
  SET
    datediff_abs_doc2jour = datediff( _jour_date, _doc_date ),
    datediff_abs_jour2pub = datediff( _pub_date, _jour_date ),
    datediff_abs_doc2pub = datediff( _pub_date, _doc_date ),
    datediff_workdays_doc2jour = datediff_workdays( _jour_date, _doc_date ),
    datediff_workdays_jour2pub = datediff_workdays( _pub_date, _jour_date ),
    datediff_workdays_doc2pub = datediff_workdays( _pub_date, _doc_date )
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

CREATE PROCEDURE getReportSuppliers()
BEGIN
SELECT
  s.id_supplier,
  s.name AS longname,
  x.gov_body AS shortname,
  ROUND( STDDEV_POP( j.datediff_workdays_doc2jour ), 1 ) AS stddev_doc2jour,
  ROUND( STDDEV_POP( j.datediff_workdays_jour2pub ), 1 ) AS stddev_jour2pub,
  ROUND( STDDEV_POP( j.datediff_workdays_doc2pub ), 1 ) AS stddev_doc2pub,
  COUNT( * ) AS doc_count
FROM
  supplier s
INNER JOIN
  ( SELECT DISTINCT id_supplier, gov_body FROM journal ) x
ON
  ( s.id_supplier = x.id_supplier )
INNER JOIN
  journal j
    ON ( j.id_supplier = s.id_supplier AND j.period >= '2014-01' )
GROUP BY
  s.id_supplier,
  x.gov_body
ORDER BY
  s.name;
END;

CREATE PROCEDURE getMostDelayed()
BEGIN
  DECLARE _done BOOLEAN;
  DECLARE _id_supplier INT UNSIGNED;
  DECLARE _name VARCHAR( 150 );
  DECLARE crsSuppliers CURSOR FOR SELECT id_supplier, name FROM supplier ORDER BY name;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET _done = 1;
  OPEN crsSuppliers;
  SET _done = 0;
  REPEAT
    FETCH crsSuppliers INTO _id_supplier, _name;
    SELECT
      _name AS name,
      id_supplier,
      gov_body,
      doc_date,
      jour_date,
      pub_date,
      datediff_workdays_doc2pub AS doc2pub,
      case_year,
      case_num,
      doc_num,
      case_title,
      doc_title
    FROM
      journal
    WHERE
      period IS NOT NULL
    AND
      ( _id_supplier = 0 OR _id_supplier = id_supplier )
    AND
      pub_date >= '2016-01-01'
    ORDER BY
      datediff_workdays_doc2pub
    DESC
      LIMIT 15;
  UNTIL _done END REPEAT;
  CLOSE crsSuppliers;
END;

CREATE PROCEDURE getOverview(
  dataset CHAR( 10 ),
  aggregate VARCHAR( 10 ),
  sortcrit VARCHAR( 10 ),
  _direction ENUM( 'IO', 'I', 'O' ) )
BEGIN

  SET @sql = CONCAT( '
    SELECT
      id_supplier,
      name_supplier AS label_longname,
      abbr_supplier AS label, ',
      aggregate, '_', dataset, ' AS value, ',
      aggregate, '_abs_', dataset, ' AS value_abs
    FROM
      statistics
    WHERE
      period LIKE \'0000-00\'
    AND
      id_supplier > 0
    AND
      ( direction = \'IO\' OR direction = \'', _direction, '\' )
    ORDER BY ',
      aggregate, '_', sortcrit, ' DESC' );

  PREPARE stm FROM @sql;
  EXECUTE stm;
  DEALLOCATE PREPARE stm;

END;

CREATE PROCEDURE getOverviewTable(
  _dataset CHAR( 10 ),
  _sortcrit VARCHAR( 10 ),
  _direction ENUM( 'IO', 'I', 'O' ) )
BEGIN

  SET @sql = CONCAT( '
    SELECT
      id_supplier,
      name_supplier AS label_longname,
      abbr_supplier AS label, ',
      'ROUND(mean_', _dataset, ', 2) AS mean, ',
      'ROUND(mean_abs_', _dataset, ', 2) AS mean_abs, ',
      'median_', _dataset, ' AS median, ',
      'median_abs_', _dataset, ' AS median_abs
    FROM
      statistics
    WHERE
      period LIKE \'0000-00\'
    AND
      id_supplier > 0
    AND
      ( direction = \'IO\' OR direction = \'', _direction, '\' )
    ORDER BY
      mean_', _sortcrit, ' DESC' );

  PREPARE stm FROM @sql;
  EXECUTE stm;
  DEALLOCATE PREPARE stm;

END;

CREATE PROCEDURE getTimeline(
  _dataset VARCHAR( 10 ),
  _aggregate VARCHAR( 10 ),
  _id_supplier INT UNSIGNED,
  _direction ENUM( 'IO', 'I', 'O' ) )
BEGIN

  SET @sql = CONCAT( '
    SELECT
      period AS label, ',
      _aggregate, '_', _dataset, ' AS value, ',
      _aggregate, '_abs_', _dataset, ' AS value_abs
    FROM
      statistics
    WHERE
      period NOT LIKE \'0000-00\'
    AND
      period >= \'2014-01\'
    AND
      doc_count > 100
    AND
      id_supplier = ', _id_supplier, '
    AND
      direction = \'', _direction, '\'
    ORDER BY
      period ASC' );

  PREPARE stm FROM @sql;
  EXECUTE stm;
  DEALLOCATE PREPARE stm;

END;
