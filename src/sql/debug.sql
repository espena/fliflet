DROP PROCEDURE IF EXISTS createCalendarTable;
DROP PROCEDURE IF EXISTS regenStatistics;
DELIMITER //
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

END//

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
              mode_v_abs_doc2pub )
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
            STATS_MODE( datediff_abs_doc2pub )
          FROM
            journal
          WHERE
            ( _id_supplier = 0 OR _id_supplier LIKE id_supplier )
          AND
            ( _period = period OR ( _period = '0000-00' AND period >= '2015-01' AND period < '2016-08-01' ) );

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

END//


DELIMITER ;
