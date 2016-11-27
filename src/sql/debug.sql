UPDATE
  journal
SET
  datediff_abs_doc2jour = NULL,
  datediff_abs_jour2pub = NULL,
  datediff_abs_doc2pub = NULL,
  datediff_workdays_doc2jour = NULL,
  datediff_workdays_jour2pub = NULL,
  datediff_workdays_doc2pub = NULL;

UPDATE
  journal
SET
  datediff_abs_doc2jour = datediff( jour_date, doc_date ),
  datediff_abs_jour2pub = datediff( pub_date, jour_date ),
  datediff_abs_doc2pub = datediff( pub_date, doc_date ),
  datediff_workdays_doc2jour = datediff_workdays( jour_date, doc_date ),
  datediff_workdays_jour2pub = datediff_workdays( pub_date, jour_date ),
  datediff_workdays_doc2pub = datediff_workdays( pub_date, doc_date )
WHERE
  pub_date <= CURRENT_DATE()
AND
  jour_date <= pub_date
AND
  doc_date <= jour_date;
