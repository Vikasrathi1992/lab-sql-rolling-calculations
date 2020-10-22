USE sakila;

## 1.Get number of monthly active customers.

select * from bank.user_activity;

create or replace view Monthly_active_users as
select count(distinct account_id) as Active_users, Activity_year, Activity_Month
from user_activity
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month;
select * from bank.Monthly_active_users;


## 2.Active users in the previous month.

with cte_activity as (
  select Active_users, lag(Active_users,1) over (partition by Activity_year) as number_active_users_previous_month, Activity_year, Activity_month
  from Monthly_active_users
)
select * from cte_activity
where number_active_users_previous_month is not null;

## 3.Percentage change in the number of active customers.

with cte_activity as (
  select Active_users,round((Active_users - lag(Active_users,1) over (partition by Activity_year))/(Active_users)* 100,2) as percentage ,
   lag(Active_users,1) over (partition by Activity_year) as last_month, Activity_year, Activity_month
  from Monthly_active_users
)
select * from cte_activity
where last_month is not null;


## 4.Retained customers every month.

create or replace view retained_customers_view as
with distinct_users as (
  select distinct account_id , Activity_Month, Activity_year
  from user_activity
)
select count(distinct d1.account_id) as Retained_customers, d1.Activity_Month, d1.Activity_year
from distinct_users d1
join distinct_users d2 on d1.account_id = d2.account_id
and d1.activity_Month = d2.activity_Month + 1
group by d1.Activity_Month, d1.Activity_year
order by d1.Activity_year, d1.Activity_Month;
select * from bank.retained_customers_view;
