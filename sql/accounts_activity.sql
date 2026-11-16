WITH acs_cnt AS (
SELECT s.date, sp.country,
a.send_interval,
a.is_verified,
a.is_unsubscribed, COUNT(DISTINCT acs.account_id) AS account_cnt
FROM `DA.account` a
  JOIN `DA.account_session` acs ON a.id = acs.account_id
  JOIN `DA.session` s ON acs.ga_session_id = s.ga_session_id
  JOIN `DA.session_params` sp ON s.ga_session_id = sp.ga_session_id
GROUP BY s.date, sp.country, a.send_interval, a.is_verified, a.is_unsubscribed),


emails_metrics AS (
SELECT
DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
sp.country, a.send_interval, a.is_verified, a.is_unsubscribed, 0 AS account_cnt,
COUNT(DISTINCT es.id_message) AS sent_msg,
COUNT(DISTINCT eo.id_message) AS open_msg,
COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM  `DA.email_sent` es
  LEFT JOIN `DA.email_open` eo
  ON es.id_message = eo.id_message
  LEFT JOIN `DA.email_visit` ev
  ON eo.id_message = ev.id_message
  JOIN `DA.account` a
  ON es.id_account = a.id
  JOIN `DA.account_session` acs ON a.id = acs.account_id
  JOIN `DA.session` s ON acs.ga_session_id = s.ga_session_id
  JOIN `DA.session_params` sp ON s.ga_session_id = sp.ga_session_id
 GROUP BY date, sp.country, a.send_interval, a.is_verified, a.is_unsubscribed),


unions_metrics AS (
SELECT date, country, send_interval, is_verified, is_unsubscribed, account_cnt,
0 AS sent_msg, 0 AS open_msg, 0 AS visit_msg
FROM acs_cnt


UNION DISTINCT


SELECT date, country, send_interval, is_verified, is_unsubscribed, 
0 AS account_cnt, sent_msg, open_msg, visit_msg
FROM emails_metrics),


grouped_metrics AS (
SELECT date, country, send_interval, is_verified, is_unsubscribed,
SUM(account_cnt) AS account_cnt, SUM(sent_msg) AS sent_msg, 
SUM(open_msg) AS open_msg, SUM(visit_msg) AS visit_msg
FROM unions_metrics
GROUP BY date, country, send_interval, is_verified, is_unsubscribed),


total_metrics AS (
SELECT country, SUM(account_cnt) AS total_country_account_cnt, SUM(sent_msg) AS total_country_sent_cnt,
DENSE_RANK() OVER (ORDER BY SUM(account_cnt) DESC) AS rank_total_country_account_cnt,
DENSE_RANK() OVER (ORDER BY SUM(sent_msg) DESC) AS rank_total_country_sent_cnt
FROM grouped_metrics
GROUP BY country)


SELECT date, country, send_interval, is_verified, is_unsubscribed, account_cnt, sent_msg, open_msg, visit_msg,
total_country_account_cnt, total_country_sent_cnt, rank_total_country_account_cnt, rank_total_country_sent_cnt
FROM grouped_metrics
JOIN total_metrics USING(country)
WHERE rank_total_country_account_cnt <= 10 OR rank_total_country_sent_cnt <= 10
