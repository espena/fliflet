DROP PROCEDURE IF EXISTS realregenStatistics;

DELIMITER //
CREATE PROCEDURE realregenStatistics( _period CHAR( 7 ) )
BEGIN
  DECLARE bDone INT;
  DECLARE _id_supplier INT UNSIGNED;
  DECLARE _name VARCHAR( 150 );
  DECLARE _startDate CHAR( 10 );
  DECLARE _critInternalDoc VARCHAR( 255 );
  DECLARE curs CURSOR FOR SELECT 0 AS id_supplier UNION SELECT DISTINCT id_supplier FROM supplier;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET bDone = 1;
  SET _startDate = '2015-01-01';
  REPLACE INTO
    statistics(
      id_supplier,
      period,
      doc_count,
      max_doc_date,
      min_doc_date )
  SELECT
    id_supplier,
    _period,
    COUNT( * ) AS doc_count,
    MAX( doc_date ) AS max_doc_date,
    MIN( doc_date ) AS min_doc_date
  FROM
    journal
  WHERE
    doc_date BETWEEN _startDate AND DATE_SUB( CURRENT_DATE(), INTERVAL 2 MONTH )
  AND
    ( _period LIKE '0000-00' OR _period LIKE period )
  GROUP BY
    id_supplier;
  REPLACE INTO
    statistics(
      id_supplier,
      period,
      doc_count,
      max_doc_date,
      min_doc_date )
  SELECT
    0 AS id_supplier,
    _period,
    COUNT( * ) AS doc_count,
    MAX( doc_date ) AS max_doc_date,
    MIN( doc_date ) AS min_doc_date
  FROM
    journal
  WHERE
    doc_date BETWEEN _startDate AND DATE_SUB( CURRENT_DATE(), INTERVAL 2 MONTH )
  AND
    ( _period LIKE '0000-00' OR _period LIKE period );
  OPEN curs;
  SET bDone = 0;
  REPEAT
    FETCH curs INTO _id_supplier;
    SET @diffFields = 'doc2jour,jour2pub,doc2pub,';
    WHILE( LOCATE( ',', @diffFields ) > 0 )
    DO
      SET @fldN = SUBSTRING( @diffFields, 1, LOCATE( ',', @diffFields ) - 1 );
      SET @diffFields = SUBSTRING( @diffFields, LOCATE( ',', @diffFields ) + 1 );
      SET @wherePart = CONCAT( '
          ( d.id_supplier = ', _id_supplier, ' OR ', _id_supplier, ' = 0 )
        AND
          (\'', _period, '\' LIKE \'0000-00\' OR d.period LIKE \'', _period, '\')
        AND
          d.doc_date BETWEEN \'', _startDate, '\' AND DATE_SUB( CURRENT_DATE(), INTERVAL 2 MONTH )' );
      SET @sqlCalcMedian = CONCAT( '
        UPDATE
          statistics AS m
            INNER JOIN (
              SELECT ',
                _id_supplier, ' AS id_supplier,
                \'', _period, '\' AS period,
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
            ) AS n ON ( m.id_supplier = n.id_supplier AND m.period = n.period )
        SET
          m.median_', @fldN, ' = n.median_', @fldN
      );
      SET @sqlCalcMode = CONCAT( '
        UPDATE
          statistics AS m
            INNER JOIN (
              SELECT ',
                _id_supplier, ' AS id_supplier,
                \'', _period, '\' AS period,
                COUNT(*) AS cnt,
                d.datediff_', @fldN, ' AS mode_v_', @fldN, ',
                ROUND( COUNT( * ) * ( 100 / (
                  SELECT
                    COUNT( * ) FROM journal
                  WHERE
                    ( id_supplier = ', _id_supplier, ' OR ', _id_supplier, ' = 0 )
                  AND
                    ( period LIKE \'', _period, '\' OR \'', _period, '\' LIKE \'0000-00\' )
                  AND
                    datediff_', @fldN, ' IS NOT NULL
                ) ) ) AS mode_p_', @fldN, '
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
                  ON ( m.id_supplier = n.id_supplier AND m.period = n.period )
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
              \'', _period, '\' AS period,
              AVG( d.datediff_doc2jour ) AS average_doc2jour,
              AVG( d.datediff_jour2pub ) AS average_jour2pub,
              AVG( d.datediff_doc2pub ) AS average_doc2pub
            FROM
              journal d
            WHERE ',
              @wherePart, '
            ) AS n
                ON ( m.id_supplier = n.id_supplier AND m.period = n.period )
      SET
        m.average_doc2jour = n.average_doc2jour,
        m.average_jour2pub = n.average_jour2pub,
        m.average_doc2pub = n.average_doc2pub'
    );
    PREPARE stmCalcAverages FROM @sqlCalcAverages;
    EXECUTE stmCalcAverages;
    DEALLOCATE PREPARE stmCalcAverages;
  UNTIL bDone END REPEAT;
END//
DELIMITER ;
