USE fiflet;

DROP PROCEDURE IF EXISTS recalcDateDiffs;
DROP PROCEDURE IF EXISTS getTimeline;

DELIMITER //

CREATE PROCEDURE recalcDateDiffs()
BEGIN
  UPDATE
    journal
  SET
    datediff_abs_doc2jour = NULL,
    datediff_abs_jour2pub = NULL,
    datediff_abs_doc2pub = NULL,
    datediff_workdays_doc2jour = NULL,
    datediff_workdays_jour2pub = NULL,
    datediff_workdays_doc2pub = NULL;

  UPDATE
    journal
  SET
    datediff_abs_doc2jour = datediff( jour_date, doc_date ),
    datediff_abs_jour2pub = datediff( pub_date, jour_date ),
    datediff_abs_doc2pub = datediff( pub_date, doc_date ),
    datediff_workdays_doc2jour = datediff_workdays( jour_date, doc_date ),
    datediff_workdays_jour2pub = datediff_workdays( pub_date, jour_date ),
    datediff_workdays_doc2pub = datediff_workdays( pub_date, doc_date )
  WHERE
    pub_date <= CURRENT_DATE()
  AND
    jour_date <= pub_date
  AND
    doc_date <= jour_date;
END//

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
      period <= \'2016-08\'
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

END//

DELIMITER ;
