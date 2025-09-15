select * from track
where Composer is null

select isnull(FirstName+' ', '')+isnull(LastName, '') as [Full Name]
from customer

--- not taking nulls in account, hurrraaayyyy


select left(invoiceid, 1) 
from Invoice

select *
from Invoice
where YEAR(InvoiceDate) between 2009 and 2011 ---in (2009, 2010, 2011)

select * 
from Customer
where LastName like '_A%'

select * 
from Customer
where LastName like '_[AE]%' ---everything

select * 
from Customer
where LastName like '_[^AE]%' ---everything except

------------------------------------------------

select 
	countrytype = case Country 
		when 'United States' then 'US'
		when 'Canada' then 'CND'
		else 'Europe'
	end, *,
	countrytype2 = case
		when country in ('Canad', 'Canada') then 'Canada'
		when country = 'United States' then 'US'
		else 'Europe'
	end,
	IIF (country like 'Canad%', 'Canada', IIF(country = 'United States', 'US', 'Europe'))
from Customer

select invoiceid as [Invoice number], invoicedate, total
from invoice
order by InvoiceDate

select FirstName, LastName, Company, 'Customer' [type]
from Customer
union all
select FirstName, LastName, 'Chinook', 'Employee' --gotto use a constant to match the vibes
from Employee

select *
from track t full join InvoiceLine il on t.TrackId = il.TrackId

select e1.*, e2.LastName 
from employee e1 full join Employee e2 on e1.ReportsTo = e2.EmployeeId

select *
from track
where trackid in (select trackid from InvoiceLine)

select * 
from track
where UnitPrice =(
select min(UnitPrice) 
from InvoiceLine 
where InvoiceLine.trackid = track.trackid)

select * 
from track
where exists(
select 1 
from InvoiceLine 
where InvoiceLine.trackid = track.trackid)

--------------------

select t.name, sum(il.UnitPrice*il.Quantity) as prs
from track t join InvoiceLine il on t.TrackId = il.trackid
group by t.name
order by prs

select count(*), COUNT(composer), count(distinct Composer)
from Track

select t.name, sum(il.UnitPrice*il.Quantity)
from track t join InvoiceLine il on t.TrackId = il.trackid
group by t.name
having sum(il.UnitPrice*il.Quantity)>4
order by sum(il.UnitPrice*il.Quantity), count(t.trackid)

select 
	case GROUPING(g.name)
		when 0 then g.Name
		when 1 then 'GRAND TOTAL'
	end,
	case GROUPING(t.name)
		when 0 then t.name
		when 1 then isnull(upper(g.Name), 'ALL')+' TOTAL'
	end, 
sum(il.UnitPrice*il.Quantity)
from track t 
	join InvoiceLine il on t.TrackId = il.trackid 
	join genre g on g.GenreId = t.GenreId
group by rollup(g.name, t.Name)

-----------------ANALYTIC FUNCTIONS
select t.name, g.name, sum(il.UnitPrice*il.Quantity) OVER (partition by t.genreid)
from track t join InvoiceLine il on t.TrackId = il.trackid
join genre g on t.GenreId = g.GenreId

select g.name, 
sum(il.UnitPrice*il.Quantity)
from track t join InvoiceLine il on t.TrackId = il.trackid
join genre g on t.GenreId = g.GenreId
group by g.Name
order by g.name

select *, 
sum(total) over (
	partition by year(invoicedate) 
	order by year(invoicedate) 
	rows between 1 preceding and 1 following) -- takes the sum of the rows 1 up and down, you need to use order by 
from invoice

-----------hierachical data

select TrackId as [@id], name, UnitPrice
from Track
for XML PATH('Track'), root('tracks')

select TrackId, name, UnitPrice
from Track
for JSON AUTO

declare @booksxml xml
set @booksxml = 
'
<catalog>
<book id ="10">
<author> John Smith </author>
<author> John Doe </author>
</book>
</catalog>
'

select 
	book.value('@id', 'Varchar(50)') as BookId
	book.value('(author)[1]','Varchar(100)') as author
from @booksxml
gotta finish...
