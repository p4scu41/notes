## SARGABLE (Search ARGument ABLE) Queries - Efficient use of Index

```sql
-- Bad:
SELECT ... WHERE Year (myDate) = 2008;
-- Fixed:
SELECT ... WHERE myDate >= '01-01-2008' AND myDate< '01-01-2009';

--Bad:
Select ... WHERE SUBSTRING(DealerName,4) = 'Ford';
-- Fixed:
Select ... WHERE DealerName Like 'Ford%';

-- Bad:
Select ... WHERE DateDiff(mm,OrderDate, GetDate()) >= 30;
-- Fixed:
Select ... WHERE OrderDate < DateAdd(mm, -30, GetDate());
```

- Avoid using functions or calculations on indexed columns in the WHERE clause
- Use direct comparisons when possible, instead of wrapping the column in a function
- If we need to use a function on a column, consider creating a computed column or a function-based index, if the database system supports

[PostgreSQL Exercises](https://pgexercises.com)

## CASE WHEN THEN

```sql
select
	name,
	case
		when monthlymaintenance > 100 then 'expensive'
		else 'cheap'
	end as cost
from cd.facilities;
```

## DISTINCT

Specifying **DISTINCT** after SELECT removes duplicate rows from the result set. Note that this applies to rows: if row A has multiple columns, row B is only equal to it if the values in all columns are the same. As a general rule, don't use DISTINCT in a willy-nilly fashion - it's not free to remove duplicates from large query result sets, so do it as-needed.

```sql
select firstname, surname, joindate
	from cd.members
	where joindate =
		(select max(joindate)
			from cd.members);
```

## BETWEEN

```sql
select b.starttime, f.name from cd.bookings as b
inner join cd.facilities as f on f.facid = b.facid
where name like 'Tennis Court%' and
	-- starttime >= '2012-09-21' and starttime < '2012-09-22'
	starttime between '2012-09-21' and '2012-09-22'
order by b.starttime;
```

## CONCAT & ||

```sql
select DISTINCT
	-- CONCAT(m.firstname, ' ', m.surname) as member,
	m.firstname || ' ' || m.surname as member,
	f.name
from cd.members as m
inner join cd.bookings as b
	on b.memid = m.memid
inner join cd.facilities as f
	on f.facid = b.facid
	and f.name like 'Tennis Court%'
order by member;
```

## Subquery & Common Table Expression (CTE)

```sql
select
	m.firstname || ' ' || m.surname as member,
	f.name as facility,
	case
		when m.memid = 0 then f.guestcost * b.slots
		else f.membercost * b.slots
	end as cost
from cd.members as m
inner join cd.bookings as b
	on b.memid = m.memid
	and b.starttime between '2012-09-14' and '2012-09-15'
inner join cd.facilities as f
	on f.facid = b.facid
where
	(m.memid = 0 and f.guestcost * b.slots > 30) or
	(m.memid != 0 and f.membercost * b.slots > 30)
order by cost desc;

-- Subquery Version
select * from (
    select
        m.firstname || ' ' || m.surname as member,
        f.name as facility,
        case
            when m.memid = 0 then f.guestcost * b.slots
            else f.membercost * b.slots
        end as cost
    from cd.members as m
    inner join cd.bookings as b
        on b.memid = m.memid
        and b.starttime between '2012-09-14' and '2012-09-15'
    inner join cd.facilities as f
        on f.facid = b.facid
)
where cost > 30
order by cost desc;

-- Common Table Expression (CTE) Version
WITH results as (
    select
        m.firstname || ' ' || m.surname as member,
        f.name as facility,
        case
            when m.memid = 0 then f.guestcost * b.slots
            else f.membercost * b.slots
        end as cost
    from cd.members as m
    inner join cd.bookings as b
        on b.memid = m.memid
        and b.starttime between '2012-09-14' and '2012-09-15'
    inner join cd.facilities as f
        on f.facid = b.facid
)
select * from results
where cost > 30
order by cost desc;
```

## INSERT

```sql
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    SELECT 9, 'Spa', 20, 30, 100000, 800
    UNION ALL
        SELECT 10, 'Squash Court 2', 3.5, 17.5, 5000, 80;
```

```sql
insert into cd.facilities values
((
    select max(facid) + 1 from cd.facilities
),'Spa', 20, 30, 100000, 800);

-- Alternative
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;
```

## UPDATE...FROM

```sql
update cd.facilities facs
    set
        membercost = facs2.membercost * 1.1,
        guestcost = facs2.guestcost * 1.1
    from (select * from cd.facilities where facid = 0) facs2
    where facs.facid = 1;
```

## DELETE

```sql
delete from cd.members where memid not in (select memid from cd.bookings);

-- Alternative: correlated subquery
delete from cd.members mems where not exists (select 1 from cd.bookings where memid = mems.memid);
```

## Common Table Expression (CTE) (WITH)

```sql
with sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots
	from sum
	where totalslots = (select max(totalslots) from sum);
```


```sql
with sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots
	from sum
	where totalslots = (select max(totalslots) from sum);
```

## ROLLUP & CUBE (GROUPING SETS)

ROLLUP is an extension to the GROUP BY clause that provides a shorthand for defining multiple grouping sets, specifically for creating hierarchical summaries of data. It is particularly useful for generating subtotals and a grand total in reports.

ROLLUP assumes a hierarchical relationship between the columns specified within its parentheses. It generates grouping sets based on this hierarchy, progressively aggregating the data from the most detailed level to the grand total.

SELECT
    column1,
    column2,
    aggregate_function(column3)
FROM
    table_name
GROUP BY
    ROLLUP (column1, column2);

Explanation:
- The columns listed within ROLLUP() define the hierarchy. For example, ROLLUP(column1, column2) would first group by column1 and column2, then by column1 alone, and finally provide a grand total.
- aggregate_function() is used to calculate summary values (e.g., SUM(), AVG(), COUNT()).
- The result set will include rows for each level of aggregation, with NULL values appearing in the columns that are not part of the current grouping level, indicating subtotals or the grand total.

While both ROLLUP and CUBE are used for generating multiple grouping sets, ROLLUP focuses on hierarchical aggregation, generating a subset of possible grouping sets based on the defined hierarchy. CUBE, on the other hand, generates all possible combinations of grouping sets from the specified columns, providing a more comprehensive but potentially larger result set.

```sql
select
	facid,
	extract(month from starttime) as month,
	sum(slots) as slots
from cd.bookings
where starttime between '2012-01-01' and '2013-01-01'
group by rollup(facid, month)
order by facid, month
```

## TO_CHAR

```sql
select
	f.facid,
	f.name,
	trim(to_char(sum(b.slots)/2.0, '999999D99')) as slots
from cd.bookings as b
inner join cd.facilities as f on
	f.facid = b.facid
group by f.facid
order by f.facid
```

## Window functions

Window functions operate on the result set of your (sub-)query, after the WHERE clause and all standard aggregation. They operate on a window of data.

```sql
select
	count(*) over() as count,
	firstname,
	surname
from cd.members
order by joindate
```

By default this is unrestricted: the entire result set, but it can be restricted to provide more useful results. For example, suppose instead of wanting the count of all members, we want the count of all members who joined in the same month as that member:

```sql
select count(*) over(partition by date_trunc('month',joindate)),
	firstname, surname
	from cd.members
order by joindate
```

In this example, we partition the data by month. For each row the window function operates over any rows that have a joindate in the same month. The window function thus produces a count of the number of members who joined in that month.

You can go further. Imagine if, instead of the total number of members who joined that month, you want to know what number joinee they were that month. You can do this by adding in an ORDER BY to the window function:

```sql
 count(*) over(partition by date_trunc('month',joindate) order by joindate),
	firstname, surname
	from cd.members
order by joindate
```

The ORDER BY changes the window again. Instead of the window for each row being the entire partition, the window goes from the start of the partition to the current row, and not beyond. Thus, for the first member who joins in a given month, the count is 1. For the second, the count is 2, and so on.

One final thing that's worth mentioning about window functions: you can have multiple unrelated ones in the same query. Try out the query below for an example - you'll see the numbers for the members going in opposite directions! This flexibility can lead to more concise, readable, and maintainable queries.

```sql
 count(*) over(partition by date_trunc('month',joindate) order by joindate asc),
	count(*) over(partition by date_trunc('month',joindate) order by joindate desc),
	firstname, surname
	from cd.members
order by joindate
```
