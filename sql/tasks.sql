/* task2 */
SELECT s.org_id, o.name, SUM(s.amount) AS Сумма, AVG(s.amount) AS Среднее, COUNT(s.org_id) AS Количество
FROM custom.org o JOIN custom.summary s ON o.org_id = s.org_id AND o.dt = s.dt
GROUP BY s.org_id, o.name
HAVING COUNT(s.org_id) > 20
ORDER BY s.org_id;

/* task3 */
WITH d AS (
    SELECT account_id, operation_date, agreement_num, operation_id AS debet_operation_id, amount AS debet_amount,
    row_number() OVER (PARTITION BY account_id, operation_date, agreement_num ORDER BY operation_id) AS r
    FROM custom.operations
    WHERE operation_type = 'D'),
c AS (
    SELECT account_id, operation_date, agreement_num, operation_id AS credit_operation_id, amount AS credit_amount,
    row_number() OVER (PARTITION BY account_id, operation_date, agreement_num ORDER BY operation_id) AS r
    FROM custom.operations
    WHERE operation_type = 'C')
SELECT
    CASE WHEN d.account_id IS NULL THEN c.account_id ELSE d.account_id END AS account_id,
    CASE WHEN d.operation_date IS NULL THEN c.operation_date ELSE d.operation_date END AS operation_date,
    CASE WHEN d.agreement_num IS NULL THEN c.agreement_num ELSE d.agreement_num END AS agreement_num,
    d.debet_operation_id, d.debet_amount, c.credit_operation_id, c.credit_amount
FROM d FULL OUTER JOIN c ON d.account_id = c.account_id AND d.operation_date = c.operation_date
                         AND d.r = c.r AND d.agreement_num = c.agreement_num
ORDER BY operation_date, agreement_num;

/* task4 */
with t1 as (
	select tlg, name, dt, row_number() over(order by org_id, dt) as r
	from custom.org),
t2 as (
	select dt, row_number() over(order by org_id, dt) as r
	from custom.org)
select
	CASE WHEN t1.dt + INTERVAL '1' DAY = t2.dt THEN null
    ELSE t1.dt END
    AS dt_to,
    CASE when t1.dt = '2022-01-01' then '2022-01-01'
    else t1.dt end
    AS dt_from,
    t1.tlg as title, t1.name as long_title
from t1 full outer  JOIN t2
on t1.r+1 = t2.r
order by t1.name, t1.dt;










/* task5 */
WITH RECURSIVE t1 (org_id, parent_id, name, path, lvl) AS (
    SELECT o.org_id, o.parent_id, o.name, CAST (o.name AS varchar (50)) AS path, 0
    FROM custom.org o
    WHERE o.parent_id IS NULL

    UNION

    SELECT co.org_id, co.parent_id, co.name, CAST (t1.path || ': '|| co.name AS varchar(50)), lvl + 1
    FROM custom.org co JOIN t1 ON t1.org_id = co.parent_id
    )
SELECT org_id AS id, parent_id, name AS field_name, path AS tree_name, lvl
FROM t1;

/* task6*/
WITH RECURSIVE recur AS (
    SELECT o.org_id, o.parent_id, o.name, SUM(s.amount) AS sum_amount
    FROM custom.org o JOIN custom.summary s ON o.org_id = s.org_id AND o.dt = s.dt
    GROUP BY o.org_id, o.parent_id, o.name

    UNION

    SELECT o.org_id, o.parent_id, o.name, recur.sum_amount
    FROM recur JOIN custom.org o ON recur.parent_id= o.org_id
    )
SELECT org_id, parent_id, name, SUM(sum_amount) AS sum_amount
FROM recur
GROUP BY org_id, parent_id, name
ORDER BY org_id;