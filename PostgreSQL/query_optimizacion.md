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
CASE
  WHEN condition_1 THEN result_1
  WHEN condition_2 THEN result_2
  -- ... more WHEN clauses
  [ELSE else_result]
END;

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
select DISTINCT firstname, surname, joindate
  from cd.members
  where joindate =
    (select max(joindate)
      from cd.members);
```

## Joining with USING

The USING clause provides a shorthand for specifying join conditions when the joining columns have the same name in both tables involved in the join.

When you use JOIN ... USING (column_name), PostgreSQL automatically creates an equality condition for the specified column_name between the two tables. For example, T1 JOIN T2 USING (a, b) is equivalent to T1 JOIN T2 ON T1.a = T2.a AND T1.b = T2.b.

When using USING, the common columns are presented as a single output column in the result set, rather than appearing twice (once from each table). This eliminates ambiguity and reduces redundancy in the output.

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
with sum as (
  select facid, sum(slots) as totalslots
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

```sql
SELECT
    column1,
    column2,
    aggregate_function(column3)
FROM
    table_name
GROUP BY
    ROLLUP (column1, column2);
```

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

### ROW_NUMBER

It is a window function that assigns a unique, sequential integer to each row within a result set or a specified partition of that result set. This function is commonly used for tasks such as ranking, pagination, and identifying duplicates.

```sql
ROW_NUMBER() OVER (
  [PARTITION BY expression_list]
  [ORDER BY expression_list]
)
```

- **OVER** clause: This is essential for all window functions. It defines the "window" or set of rows over which the function operates.
- **PARTITION BY** expression_list (Optional): This clause divides the result set into smaller, independent groups called partitions. If PARTITION BY is used, ROW_NUMBER() restarts its numbering from 1 for each new partition. If omitted, the entire result set is treated as a single partition.
- **ORDER BY** expression_list: This clause specifies the order in which rows within each partition (or the entire result set) are numbered. This order determines how the sequential integers are assigned.

To assign a row number to each employee based on their salary in descending order:

```sql
SELECT
  employee_id,
  first_name,
  last_name,
  salary,
  ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM
    employees;
```

To assign a row number to each employee within their respective departments, ordered by salary within each department:

```sql
SELECT
  employee_id,
  first_name,
  last_name,
  department_id,
  salary,
  ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num_in_department
FROM
  employees;
```

### RANK

It is a window function used to assign a rank to each row within a specified partition of a result set. It's particularly useful for ranking items based on certain criteria, such as finding top performers, generating leaderboards, or sorting data by highest values.

Handling Ties: If multiple rows have the same value for the ranking criteria, they receive the same rank. However, **RANK** will skip the subsequent rank(s), creating gaps in the ranking sequence. For example, if two rows tie for rank 3, both will receive rank 3, and the next rank assigned will be 5 (rank 4 is skipped). on the other hand, **DENSE_RANK** does not skip rank numbers when there are ties, for example, if two rows tie for rank 1, they both get rank 1, and the next distinct value gets rank 2. (e.g., 1, 1, 2, 3)

```sql
RANK() OVER (
    [PARTITION BY partition_expression, ...]
    ORDER BY sort_expression [ASC | DESC], ...
)
```

To rank students by their scores within each class:

```sql
SELECT
    student_name,
    class_id,
    score,
    RANK() OVER (PARTITION BY class_id ORDER BY score DESC) as rank_in_class
FROM
    student_scores;
```

Output the facility id that has the highest number of slots booked

```sql
select facid, sum(slots) as total
from cd.bookings
group by facid
order by total desc
limit 1;

with result as
(
  select facid, sum(slots) as total
  from cd.bookings
  group by facid
)
select * from result
where total = (select max(total) from result);

select facid, total from (
  select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
  from cd.bookings
  group by facid
) as ranked
where rank = 1 ;

select facid, sum(slots) as totalslots
from cd.bookings
group by facid
having sum(slots) = (
  select max(sum2.totalslots) from
  (
    select sum(slots) as totalslots
    from cd.bookings
    group by facid
  ) as sum2
);

select facid, total from (
  select facid, total, rank() over (order by total desc) rank from (
    select facid, sum(slots) total
    from cd.bookings
    group by facid
  ) as sumslots
) as ranked
where rank = 1;
```

Rank members by (rounded) hours used

```sql
with result as
(
  select
    firstname,
    surname,
    ((sum(slots)+10)/20)*10 as hours
  from cd.members as m
  inner join cd.bookings as b using(memid)
  group by memid
)
select *, rank() over (order by hours desc) as rank from  result
order by rank asc, surname, firstname;

select firstname, surname, hours, rank() over (order by hours desc) from
  (select firstname, surname,
    ((sum(bks.slots)+10)/20)*10 as hours
    from cd.bookings bks
    inner join cd.members mems
      on bks.memid = mems.memid
    group by mems.memid
  ) as subq
order by rank, surname, firstname;
```

Find the top three revenue generating facilities

```sql
with result as
(
select
  name,
  sum(
  case
      when memid = 0 then guestcost * slots
      else membercost * slots
    end
  ) as revenue
from cd.facilities
inner join cd.bookings using(facid)
group by name
)
select name, rank() over (order by revenue desc) as rank
from result
limit 3;

select name, rank from (
  select facs.name as name, rank() over (order by sum(case
        when memid = 0 then slots * facs.guestcost
        else slots * membercost
      end) desc) as rank
    from cd.bookings bks
    inner join cd.facilities facs
      on bks.facid = facs.facid
    group by facs.name
  ) as subq
  where rank <= 3
order by rank;
```

### NTILE

Used to divide an ordered set of rows into a specified number of ranked groups, often called "buckets" or "tiles," as equally sized as possible. It assigns a bucket number (starting from 1) to each row within these groups.

``` sql
NTILE(num_tiles) OVER (
    [PARTITION BY partition_expression, ...]
    ORDER BY sort_expression [ASC | DESC], ...
)
```

- **num_tiles**: An integer representing the desired number of groups or buckets to divide the rows into.

How it Works:
- **Ordering**: Rows are first ordered according to the ORDER BY clause within each partition (if specified).
- **Division**: The ordered rows are then divided into num_tiles groups.
- **Assignment**: Each row is assigned a bucket number from 1 to num_tiles, indicating which group it belongs to.
- **Handling Unequal Sizes**: If the total number of rows (or rows within a partition) is not perfectly divisible by num_tiles, the NTILE() function distributes the remaining rows by placing them into the initial buckets, making those buckets slightly larger than the later ones.

- Data Segmentation: Dividing data into deciles, quartiles, or other equal-sized groups for analysis.
- Percentile Calculations: While NTILE() itself doesn't directly calculate percentiles, it can be used as a building block for percentile-like analysis by dividing data into 100 tiles.
- Ranking and Reporting: Creating reports that categorize items into specific performance tiers or groups based on a particular metric.

```sql
select
  name,
  case
    when tile = 1 then 'high'
    when tile = 2 then 'average'
    when tile = 3 then 'low'
  end as revenue
from (
  select name, NTILE(3) over (order by revenue desc) as tile
  from
    (
    select
      name,
      sum(
      case
          when memid = 0 then guestcost * slots
          else membercost * slots
        end
      ) as revenue
    from cd.facilities
    inner join cd.bookings using(facid)
    group by name
  ) order by tile, name
);

select name, case when class=1 then 'high'
    when class=2 then 'average'
    else 'low'
    end revenue
  from (
    select facs.name as name, ntile(3) over (order by sum(case
        when memid = 0 then slots * facs.guestcost
        else slots * membercost
      end) desc) as class
    from cd.bookings bks
    inner join cd.facilities facs
      on bks.facid = facs.facid
    group by facs.name
  ) as subq
order by class, name;
```

## Complex JOINs

Calculate the payback time for each facility, based on the 3 complete months of data so far.

```sql
with revenues as
(
  select
    facid,
    sum(
    case
        when memid = 0 then guestcost * slots
        else membercost * slots
      end
    ) as revenue
  from cd.facilities
  inner join cd.bookings using(facid)
  group by facid
)
select
  name,
  initialoutlay / (revenue/3 - monthlymaintenance) as months
from revenues
inner join cd.facilities using(facid)
order by name;
---

select
  facs.name as name,
  facs.initialoutlay/((sum(case
      when memid = 0 then slots * facs.guestcost
      else slots * membercost
    end)/3) - facs.monthlymaintenance) as months
  from cd.bookings bks
  inner join cd.facilities facs
    on bks.facid = facs.facid
  group by facs.facid
order by name;
---

select
  name,
  initialoutlay / (monthlyrevenue - monthlymaintenance) as repaytime
  from
  (
    select
      facs.name as name,
      facs.initialoutlay as initialoutlay,
      facs.monthlymaintenance as monthlymaintenance,
      sum(case
        when memid = 0 then slots * facs.guestcost
        else slots * membercost
      end)/3 as monthlyrevenue
    from cd.bookings bks
    inner join cd.facilities facs
      on bks.facid = facs.facid
    group by facs.facid
  ) as subq
order by name;
---

with monthdata as (
  select
    mincompletemonth,
    maxcompletemonth,
    (extract(year from maxcompletemonth)*12) +
      extract(month from maxcompletemonth) -
      (extract(year from mincompletemonth)*12) -
      extract(month from mincompletemonth) as nummonths
  from (
    select
      date_trunc('month',
        (select max(starttime) from cd.bookings)) as maxcompletemonth,
      date_trunc('month',
        (select min(starttime) from cd.bookings)) as mincompletemonth
  ) as subq
)
select 	name,
  initialoutlay / (monthlyrevenue - monthlymaintenance) as repaytime
  from
    (
      select
        facs.name as name,
        facs.initialoutlay as initialoutlay,
        facs.monthlymaintenance as monthlymaintenance,
        sum(case
          when memid = 0 then slots * facs.guestcost
          else slots * membercost
        end)/(select nummonths from monthdata) as monthlyrevenue
      from cd.bookings bks
      inner join cd.facilities facs
        on bks.facid = facs.facid
      where bks.starttime < (select maxcompletemonth from monthdata)
      group by facs.facid
    ) as subq
order by name;
```

## GENERATE_SERIES

It is a powerful set-returning function used to generate a series of values. It can produce sequences of numbers (integers, bigints, or numerics) or date/time values (dates, timestamps, or timestamptz).

```sql
generate_series(start, stop[, step]);
```

- **start**: The starting value of the series (inclusive).
- **stop**: The ending value of the series (inclusive, if it aligns with the step).
- **step** (optional): The increment value between consecutive elements in the series. If omitted, the default step is 1 for numeric series and 1 unit of the respective date/time type for date/time series (e.g., 1 day for dates).

```sql
SELECT generate_series(1, 5);
SELECT generate_series(1, 10, 2);
SELECT generate_series('2025-01-01'::date, '2025-01-05'::date, '1 day'::interval);
SELECT generate_series('2025-01-01 00:00:00'::timestamp, '2025-01-01 06:00:00'::timestamp, '1 hour'::interval);
```

Calculate a rolling average of total revenue

```sql

```
