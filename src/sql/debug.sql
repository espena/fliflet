DROP PROCEDURE IF EXISTS getMostDelayed;
DELIMITER //
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
  ORDER BY
    datediff_workdays_doc2pub
  DESC
    LIMIT 30;

  UNTIL _done END REPEAT;

  CLOSE crsSuppliers;

END//
DELIMITER ;
