DROP DATABASE IF EXISTS %%database%%;
CREATE DATABASE %%database%% DEFAULT CHARSET 'utf8';
USE %%database%%;

CREATE TABLE journal (
  id_journal BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  id_supplier INT UNSIGNED NOT NULL,
  sakstittel TEXT,
  doktittel TEXT,
  saksaar CHAR( 4 ),
  saksnr INT UNSIGNED,
  doknr INT UNSIGNED,
  virksomhet VARCHAR( 30 ),
  dokdato DATE,
  jourdato DATE,
  pubdato DATE,
  annenpart TEXT,
  unntaksgrunnlag VARCHAR( 150 ),
  datediff_dok2jour INT UNSIGNED,
  datediff_jour2pub INT UNSIGNED,
  datediff_dok2pub INT UNSIGNED,
  scrapetime TIMESTAMP,
  INDEX idx_supplier ( id_supplier ),
  UNIQUE INDEX uidx_dokidentitet ( virksomhet, saksaar, saksnr, doknr )
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
    DATEDIFF( pubdato, dokdato ) AS forsinkelse,
    LOWER( doktittel ) AS doktittel
  FROM
    journal
  WHERE
    pubdato > dokdato
  AND
    pubdato < CURRENT_DATE()
  AND
    ( _id_supplier = 0 OR _id_supplier = id_supplier )
  ORDER BY
    forsinkelse
      DESC
  LIMIT
    10000;
  SELECT
    DATEDIFF( pubdato, dokdato ) AS forsinkelse,
    LOWER( doktittel ) AS doktittel
  FROM
    journal
  WHERE
    pubdato > dokdato
  AND
    pubdato < CURRENT_DATE()
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
    DATEDIFF( pubdato, dokdato ) AS forsinkelse,
    LOWER( doktittel ) AS doktittel
  FROM
    journal
  WHERE
    pubdato > dokdato
  AND
    pubdato < CURRENT_DATE()
  AND
    ( _id_supplier = 0 OR _id_supplier = id_supplier )
  ORDER BY
    forsinkelse
      ASC
  LIMIT
    10000;
  SELECT
    DATEDIFF( pubdato, dokdato ) AS forsinkelse,
    LOWER( doktittel ) AS doktittel
  FROM
    journal
  WHERE
    pubdato > dokdato
  AND
    pubdato < CURRENT_DATE()
  AND
    ( _id_supplier = 0 OR _id_supplier = id_supplier )
  ORDER BY
    forsinkelse
      DESC
  LIMIT
    10000;
END;

CREATE PROCEDURE regenMedians()
BEGIN

  DECLARE bDone INT;
  DECLARE _id_supplier INT UNSIGNED;
  DECLARE _navn VARCHAR( 150 );
  DECLARE curs CURSOR FOR SELECT DISTINCT id_supplier FROM supplier;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET bDone = 1;

  UPDATE
    journal
  SET
    datediff_dok2jour = DATEDIFF( jourdato, dokdato ),
    datediff_jour2pub = DATEDIFF( pubdato, jourdato ),
    datediff_dok2pub = DATEDIFF( pubdato, dokdato )
  WHERE
    dokdato <= jourdato
  AND
    jourdato <= pubdato
  AND
    pubdato <= CURRENT_DATE()
  AND
    dokdato > '1999-12-31';

  DROP TABLE IF EXISTS median;

  CREATE TABLE median(
    id_supplier INT UNSIGNED PRIMARY KEY,
    period CHAR( 7 ),
    median_dok2jour DOUBLE,
    median_jour2pub DOUBLE,
    median_dok2pub DOUBLE );

  OPEN curs;
  SET bDone = 0;

  REPEAT
    FETCH curs INTO _id_supplier;
    REPLACE INTO
      median( id_supplier, median_dok2pub )
    SELECT
      _id_supplier AS id_supplier,
      AVG( t1.datediff_dok2pub ) AS median_dok2jour
    FROM
    (
      SELECT
        @rownum:=@rownum + 1 AS `row_number`,
        d.datediff_dok2pub
      FROM
        journal d, ( SELECT @rownum:=0 ) r
      WHERE
        d.datediff_dok2pub IS NOT NULL
      AND
        d.id_supplier = _id_supplier
      ORDER BY
        d.datediff_dok2pub
    ) AS t1,
    (
      SELECT
        COUNT(*) AS total_rows
      FROM
        journal d
      WHERE
        d.datediff_dok2pub IS NOT NULL
      AND
        d.id_supplier = _id_supplier
    ) AS t2
    WHERE 1
    AND
      t1.row_number IN ( FLOOR( ( total_rows + 1 ) / 2 ), FLOOR( ( total_rows + 2 ) / 2 ) );
    UPDATE
      median AS m
        INNER JOIN (
          SELECT
            _id_supplier AS id_supplier,
            AVG( t1.datediff_dok2jour ) AS median_dok2jour
          FROM
          (
            SELECT
              @rownum:=@rownum + 1 AS `row_number`,
              d.datediff_dok2jour
            FROM
              journal d, ( SELECT @rownum:=0 ) r
            WHERE
              d.datediff_dok2jour IS NOT NULL
            AND
              d.id_supplier = _id_supplier
            ORDER BY
              d.datediff_dok2jour
          ) AS t1,
          (
            SELECT
              COUNT(*) AS total_rows
            FROM
              journal d
            WHERE
              d.datediff_dok2jour IS NOT NULL
            AND
              d.id_supplier = _id_supplier
          ) AS t2
          WHERE 1
          AND
            t1.row_number IN ( FLOOR( ( total_rows + 1 ) / 2 ), FLOOR( ( total_rows + 2 ) / 2 ) )
        ) AS n ON ( m.id_supplier = n.id_supplier )
    SET
      m.median_dok2jour = n.median_dok2jour;
    UPDATE
      median AS m
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
          ) AS t2
          WHERE 1
          AND
            t1.row_number IN ( FLOOR( ( total_rows + 1 ) / 2 ), FLOOR( ( total_rows + 2 ) / 2 ) )
        ) AS n ON ( m.id_supplier = n.id_supplier )
    SET
      m.median_jour2pub = n.median_jour2pub;
  UNTIL bDone END REPEAT;
END;

CREATE PROCEDURE statsOverview( _id_supplier INT UNSIGNED )
BEGIN
  SELECT
    j.id_supplier,
    s.navn,
    j.virksomhet AS forkortelse,
    COUNT( j.id_journal ) AS antall_dok,
    ROUND( AVG( DATEDIFF( j.jourdato, j.dokdato ) ) ) AS dager_jour,
    ROUND( AVG( DATEDIFF( j.pubdato, j.dokdato ) ) ) - ROUND( AVG( DATEDIFF( j.jourdato, j.dokdato ) ) ) AS dager_pub,
    ROUND( AVG( DATEDIFF( j.pubdato, j.dokdato ) ) ) AS dager_tot,
    MAX( j.dokdato ) AS max_dato,
    MIN( j.dokdato ) AS min_dato
  FROM
    supplier s
  INNER JOIN
    journal j
      ON ( s.id_supplier = j.id_supplier )
  WHERE
    ( _id_supplier = 0 OR j.id_supplier = _id_supplier )
  AND
    j.dokdato < j.jourdato
  AND
    j.jourdato < j.pubdato
  AND
    j.dokdato > '2015-12-31'
  AND
    j.dokdato < DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
  GROUP BY
    j.id_supplier,
    j.virksomhet
  ORDER BY
    dager_tot DESC;
END;

CREATE PROCEDURE insertRecord( _id_supplier INT UNSIGNED,
                               _sakstittel TEXT,
                               _doktittel TEXT,
                               _saksaar CHAR( 4 ),
                               _saksnr INT UNSIGNED,
                               _doknr INT UNSIGNED,
                               _virksomhet VARCHAR( 30 ),
                               _dokdato DATE,
                               _jourdato DATE,
                               _pubdato DATE,
                               _annenpart TEXT,
                               _unntaksgrunnlag VARCHAR( 150 ) )
BEGIN
   REPLACE INTO
       journal (
         id_supplier,
         sakstittel,
         doktittel,
         saksaar,
         saksnr,
         doknr,
         virksomhet,
         dokdato,
         jourdato,
         pubdato,
         annenpart,
         unntaksgrunnlag )
   VALUES (
     _id_supplier,
     _sakstittel,
     _doktittel,
     _saksaar,
     _saksnr,
     _doknr,
     _virksomhet,
     _dokdato,
     _jourdato,
     _pubdato,
     _annenpart,
     _unntaksgrunnlag );
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
