USE fiflet;
SELECT
  COUNT(*) AS n,
  datediff_jour2pub AS modal_v_jour2pub,
  ROUND( COUNT( * ) * ( 100 / ( SELECT COUNT( * ) FROM journal WHERE datediff_jour2pub IS NOT NULL ) ) ) AS modal_p_jour2pub
FROM
  journal
WHERE
  datediff_jour2pub IS NOT NULL
GROUP BY
  datediff_jour2pub
ORDER BY
  n DESC
LIMIT 1;
