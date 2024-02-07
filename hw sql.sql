--1.Use the Invoice table to determine the countries that have the lowest invoices.
select  
	invoiceid, 
	billingcountry, 
	sum(total)  qnt_invoice
from invoice
group by invoiceid, billingcountry, total  
order by invoiceid;

--The country with the most invoices should appear last
select 
	customerid,
	billingcountry,
	count(customerid) quant_inv
from invoice
group by customerid, billingcountry
order by quant_inv

--Write a query that returns the 5 city that has the lowest sum
--of invoice totals. Return both the city name and the sum of all invoice totals.
select   
	billingcity,   
	sum(total)  total_sum
from invoice
group by billingcity, total  
order by total
limit 5;

--Build a query that returns the person who has spent the least money.
select
    c.CustomerId,
    c.FirstName,
    c.LastName,
    SUM(i.Total) as TotalSpent
from  Customer c
join
    Invoice i on c.CustomerId = i.CustomerId
group by
    c.CustomerId,
    c.FirstName,
    c.LastName   
order by TotalSpent
limit 5;

--Write a query to return the email, first name, last name, and
--Genre of all Rock Music listeners. Return your list ordered alphabetically by
--email address starting with &#39;S&#39;.
select c.FirstName, 
	   c.LastName,
	   c.Email,
	   g."name" as Genre
from customer c 
join 
 	invoice i 	on i.customerid = c.customerid
join
	invoiceline il on il.invoiceid = i.invoiceid
join 
	track t on  t.trackid = il.trackid
join 
	genre g on t.genreid = g.genreid 
where 
	g."name" = 'Rock'
	and c.email like 's%';
--
select "name",  sum(trackid) as cnt_tr
	from track t
	group by "name", trackid
	order by cnt_tr desc 

--5.Write a query that determines the customer that has spent the most on
--music for each country.	
select
    c.Country,
    c.CustomerId,
    c.FirstName || ' ' || c.LastName as CustomerName,
    max(total_spent) AS TotalSpent
from
    Customer c
join (
    select
        i.CustomerId,
        sum(il.UnitPrice * il.Quantity) as total_spent
    from
        Invoice i
    join InvoiceLine il on i.InvoiceId = il.InvoiceId
    group by
        i.CustomerId
    ) as customer_spending on c.CustomerId = customer_spending.CustomerId
group by
    c.Country, c.CustomerId, CustomerName
order by
    c.Country;

--How many tracks appeared 5 times, 4 times, 3 times....?   
select
    "name",
    count(trackid) as appearance_count
from
    track t
group by
    "name"
-- appearance_count = 5 equals 6
-- appearance_count = 4 equals 4
-- appearance_count = 3 equals 21
-- could not find easy way to use three conditions
having count(*) = 3
order by appearance_count desc;

--Which album generated the most revenue?
select
    a.title as album_title,
    SUM(il.unitprice * il.quantity) AS total_revenue
from
    album a
inner join
    track t on a.albumid = t.albumid
inner join
    invoiceline il on t.trackid = il.trackid
group by
    a.albumid, a.title
order by
    total_revenue desc
limit 5;
 
--Which countries have the highest sales revenue? What percent of total
--revenue does each country make up   
select
    cu.country as country_name,
    sum(il.unitprice * il.quantity) as total_revenue,
    (sum(il.unitprice * il.quantity) / (select sum(unitprice * quantity) from invoiceline)) * 100 as percent_total_revenue
from
    customer cu
inner join
    invoice i on cu.customerid = i.customerid
inner join
    invoiceline il on i.invoiceid = il.invoiceid
group by
    cu.country
order by
    total_revenue desc;
   
--How many customers did each employee support, what is the average
--revenue for each sale, and what is their total sale?  
select
    e.firstname || ' ' || e.lastname as employee_name,
    count(distinct c.customerid) as num_customers_supported,
    avg(il.unitprice * il.quantity) as average_revenue_per_sale,
    sum(il.unitprice * il.quantity) as total_sale
from
    employee e
left join
    customer c on e.employeeid = c.supportrepid
left join
    invoice i on c.customerid = i.customerid
left join
    invoiceline il on i.invoiceid = il.invoiceid
group by
    e.employeeid, e.firstname, e.lastname
order by
    employee_name;

-- Do longer or shorter length albums tend to generate more revenue?
with trackcounts as (
  select
       albumid,
        count(trackid) as numtracks
    from
        track
    group by
        albumid
),
albumrevenue as (
    select
        t.albumid,
        sum(il.unitprice) as totalrevenue
    from
        invoiceline il
    join
        track t on il.trackid = t.trackid
    group by
        t.albumid
),
albumlength as (
    select
        a.albumid,
        case
            when tc.numtracks < 10 then 'short'
            when tc.numtracks between 10 and 20 then 'medium'
            else 'long'
        end as lengthcategory
    from
        album a
    join
        trackcounts tc on a.albumid = tc.albumid
)
select
    al.lengthcategory,
    avg(ar.totalrevenue / tc.numtracks) as avgrevenuepertrack
from
    albumlength al
join
    albumrevenue ar on al.albumid = ar.albumid
join
    trackcounts tc on al.albumid = tc.albumid
group by
    al.lengthcategory
order by
    al.lengthcategory;




   




