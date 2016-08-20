USE fiflet;

UPDATE
  statistics s
    INNER JOIN ( SELECT DISTINCT id_supplier, virksomhet FROM journal WHERE virksomhet IS NOT NULL ) j ON ( s.id_supplier = j.id_supplier )
SET
  s.abbr_supplier = j.virksomhet;
