select count(customer_id) as customers_count from customers;


select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from
    sales as s
inner join
    products as p
    on s.product_id = p.product_id
inner join
    employees as e
    on s.sales_person_id = e.employee_id
group by
    s.sales_person_id, e.first_name, e.last_name
order by
    income desc
limit 10;


with overall_avg as (
    select floor(avg(s.quantity * p.price)) as global_avg_income
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
)

select
    concat(e.first_name, ' ', e.last_name) as seller,
    floor(avg(s.quantity * p.price)) as average_income
from
    sales as s
inner join products as p
    on s.product_id = p.product_id
inner join employees as e
    on s.sales_person_id = e.employee_id
group by
    s.sales_person_id, e.first_name, e.last_name
having
    floor(avg(s.quantity * p.price)) < (
        select overall_avg.global_avg_income from overall_avg
    )
order by
    average_income asc;


select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from
    sales as s
inner join
    products as p
    on s.product_id = p.product_id
inner join
    employees as e
    on s.sales_person_id = e.employee_id
group by
    s.sales_person_id, e.first_name, e.last_name
order by
    income desc
limit 10;


select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    count(*) as age_count
from
    customers
group by
    age_category
order by
    age_category asc;


select
    to_char(s.sale_date, 'yyyy-mm') as selling_month,
    count(distinct s.customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from
    sales as s
inner join
    products as p
    on s.product_id = p.product_id
group by
    to_char(s.sale_date, 'yyyy-mm')
order by
    selling_month asc;


with first_sales as (
    select
        customer_id,
        min(sale_date) as first_sale_date
    from
        sales
    group by
        customer_id
),

promo_first as (
    select
        fs.customer_id,
        fs.first_sale_date,
        s.sales_person_id
    from
        first_sales as fs
    inner join
        sales as s
        on fs.customer_id = s.customer_id and fs.first_sale_date = s.sale_date
    inner join
        products as p
        on s.product_id = p.product_id
    where
        p.price = 0
    group by
        fs.customer_id, fs.first_sale_date, s.sales_person_id
)

select
    pf.first_sale_date as sale_date,
    concat(c.first_name, ' ', c.last_name) as customer,
    concat(e.first_name, ' ', e.last_name) as seller
from
    promo_first as pf
inner join
    customers as c
    on pf.customer_id = c.customer_id
inner join
    employees as e
    on pf.sales_person_id = e.employee_id
order by
    pf.customer_id asc;
