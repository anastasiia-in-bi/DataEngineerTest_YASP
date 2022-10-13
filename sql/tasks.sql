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
 CREATE TEMPORARY VIEW task4 AS (
	WITH CTE AS(
--date groups creation
		SELECT *,
			dt-(ROW_NUMBER() OVER (PARTITION BY org_id, parent_id, tlg, name ORDER BY dt) * INTERVAL '1 day') as dt_group
		FROM custom.org
	)
--get the start and end dates
	SELECT max(dt) as dt_to, min(dt) as dt_from, tlg as title, name as long_title,
			row_number() over (order by org_id, min(dt)) as rn
	FROM CTE
	GROUP BY tlg, name, org_id, parent_id, dt_group
	ORDER BY org_id, dt_from
);

WITH cte AS (
	SELECT  min(rn) as rn,
			"title",
			json_agg(json_build_object('to', "dt_to",
										'from', "dt_from",
										'title', "title",
 										'long_title', "long_title")) intermediate_json
    FROM task4
    GROUP BY "title"
)
SELECT row_number() over (order by rn) as obj,
		row_to_json(row(json_build_object('temporalTitles', intermediate_json)))->>'f1' as json_build_object
FROM cte
ORDER BY obj;

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