SELECT
  CONCAT( YEAR( dokdato ), '-', LPAD( MONTH( dokdato ), 2, '0' ) ) AS periode,
  AVG( DATEDIFF( jourdato, dokdato ) ) AS dager_jour,
  AVG( DATEDIFF( pubdato, dokdato ) ) AS dager_pub
FROM
  journal
WHERE
  dokdato > '2014-12-31'
AND
  dokdato < jourdato
AND
  jourdato < pubdato
GROUP BY
  periode
ORDER BY
  periode ASC;
