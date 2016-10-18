DROP PROCEDURE IF EXISTS getTimeline;

DELIMITER //

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

END//

DELIMITER ;
