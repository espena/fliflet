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
  scrapetime TIMESTAMP,
  UNIQUE INDEX uidx_dokidentitet ( virksomhet, saksaar, saksnr, doknr )
);

CREATE TABLE supplier (
  id_supplier INT UNSIGNED PRIMARY KEY,
  navn VARCHAR( 150 )
);

CREATE PROCEDURE statsOverview()
BEGIN
  SELECT
    s.navn,
    j.virksomhet AS forkortelse,
    COUNT( j.id_journal ) AS antall_dok,
    ROUND( AVG( DATEDIFF( j.jourdato, j.dokdato ) ) ) AS dager_jour,
    ROUND( AVG( DATEDIFF( j.pubdato, j.dokdato ) ) ) AS dager_pub,
    GREATEST( ROUND( AVG( DATEDIFF( j.jourdato, j.dokdato ) ) ), ROUND( AVG( DATEDIFF( j.pubdato, j.dokdato ) ) ) ) AS sortparam
  FROM
    supplier s
      INNER JOIN
        journal j
          ON ( s.id_supplier = j.id_supplier )
  WHERE
    j.dokdato < j.jourdato
  AND
    j.jourdato < j.pubdato
  GROUP BY
    j.id_supplier,
    j.virksomhet
  HAVING
    dager_jour < 365
  ORDER BY
    sortparam DESC;
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
