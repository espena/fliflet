UPDATE
  journal
SET
  datediff_doc2jour = datediff_workdays( jour_date, doc_date ),
  datediff_jour2pub = datediff_workdays( pub_date, jour_date ),
  datediff_doc2pub = datediff_workdays( pub_date, doc_date )
WHERE
  pub_date <= CURRENT_DATE()
AND
  jour_date <= pub_date
AND
  doc_date <= jour_date;
