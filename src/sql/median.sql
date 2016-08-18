SELECT
  AVG( t1.datediff_dok2pub ) AS median_val
FROM
(
  SELECT
    @rownum:=@rownum + 1 AS `row_number`,
    d.datediff_dok2pub
  FROM
    journal d, ( SELECT @rownum:=0 ) r
  WHERE
    d.datediff_dok2pub IS NOT NULL
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
) AS t2
WHERE 1
AND
  t1.row_number IN ( FLOOR( ( total_rows + 1 ) / 2 ), FLOOR( ( total_rows + 2 ) / 2 ) );
