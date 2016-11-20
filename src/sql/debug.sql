DROP PROCEDURE IF EXISTS getOverviewTable;

DELIMITER //

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

END//

DELIMITER ;
