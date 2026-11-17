# Accounts Activity Dynamic: SQL + Looker Studio

 [Open the live dashboard](https://datastudio.google.com/reporting/53308d01-5789-4c98-af0a-1f10c3fe48fd)
## Project Overview
 
This project helps analyze how new accounts are created and how users react to email campaigns. It also shows how behavior differs between countries, so we can find the key markets.
 
The final dataset is built with SQL in **BigQuery**. The dashboard is built in **Looker Studio**.
 
## Business Questions
 
- How does the number of created accounts change over time?
- How many emails are sent, opened, and clicked?
- Which countries have the most accounts and the most sent emails?
- How do users differ by send interval, account verification, and subscription status?

<img width="1436" height="1078" alt="image" src="https://github.com/user-attachments/assets/a0623b4e-6c31-4dd3-9464-75965cc7245b" />

## Tech Stack
 
- **BigQuery** (Standard SQL)
- **Looker Studio**


## Data Sources
 
The query uses the following tables:
 
| Table | Description |
|---|---|
| `account` | Account details: send interval, verification, unsubscribe status |
| `account_session` | Link between accounts and sessions |
| `session` | Session date |
| `session_params` | Session parameters, including country |
| `email_sent` | Sent emails |
| `email_open` | Opened emails |
| `email_visit` | Clicks (visits) from emails |

## Output Dataset
 
The final query returns one row for each combination of date, country, and account segment.
 
| Column | Description |
|---|---|
| `date` | Date |
| `country` | Country |
| `send_interval` | Email sending interval |
| `is_verified` | Whether the account is verified |
| `is_unsubscribed` | Whether the user has unsubscribed |
| `account_cnt` | Number of created accounts |
| `sent_msg` | Number of sent emails |
| `open_msg` | Number of opened emails |
| `visit_msg` | Number of clicks from emails |
| `total_country_account_cnt` | Total accounts created in the country |
| `total_country_sent_cnt` | Total emails sent in the country |
| `rank_total_country_account_cnt` | Country rank by number of accounts |
| `rank_total_country_sent_cnt` | Country rank by number of sent emails |

## How the SQL Works
 
The query uses CTEs, so each step is easy to read:
 
1. **`acs_cnt`**: counts unique created accounts by date, country, and account segment.
2. **`emails_metrics`**: counts unique sent, opened, and clicked emails. The email date is calculated as the session date plus `sent_date` days.
3. **`unions_metrics`**: combines account metrics and email metrics into one table with the same columns.
4. **`grouped_metrics`**: sums the metrics, so we get one row per date, country, and segment.
5. **`total_metrics`**: calculates total values for each country and ranks countries with `DENSE_RANK()`.
6. **Final `SELECT`**: joins the totals back to the daily data and keeps only countries that are in the **top 10** by accounts or by sent emails.
**SQL techniques used:** CTEs, multiple `JOIN`s, `UNION DISTINCT`, `COUNT(DISTINCT)`, `DATE_ADD`, window function `DENSE_RANK()`.

## Key Findings
 
- The **United States**, **India**, and **Canada** are the top three countries by both accounts (12,384 / 2,687 / 2,067) and sent emails (233,503 / 51,189 / 37,914).
- The United States sends about 4.5 times more emails than India, the second market.
- **China** has the highest open rate (41.2%), while the **United Kingdom** has the highest click rate among opened emails (13.8%).
- Open rates in the top markets are similar (about 31-41%), but click-to-sent rates are low everywhere (about 3-5%), so the biggest drop in the funnel happens between opening an email and clicking a link.
- The two rankings do not always match: for example, Italy is 9th by accounts but 11th by sent emails, and China is 8th by accounts but 5th by sent emails.
- Email activity grows from November 2020, peaks at about 5.4K emails per day in early December 2020, and then declines until February 2021.

## Note About the Data
 
The dataset is private, so it is **not included** in this repository and the project cannot be reproduced directly. The repository shows the SQL logic, the structure of the final dataset, and the dashboard result.
