--Make a list of Northwind employees. The list should contain the employee's monogram, 
--their full name, the concatenated address (address, city, region, postal code, 
--and country separated by commas), and the days remaining until their next birthday.

select LEFT(FirstName,1)+LEFT(LastName, 1) [Monogram],
FirstName+' '+LastName [FULL NAME], 
Address+', '+City+', '+Region+', '+PostalCode+', '+Country as [ADDRESS],
datediff(day, GETDATE(), BirthDate ) [UntilBirthday]
from Employees

--List Northwind orders placed in August, 1996. 
--Include only shipped, but delayed shipments

select *
from Orders
where month(OrderDate)= 8 and year(orderdate)=1996
and datediff(DAY, ShippedDate, RequiredDate) < 0

--List Northwind order details. Include only the 10 orders with the highest net worth. 
--In a new column, calculate the gross value by adding 20% VAT

select top 10 O.OrderID, UnitPrice*Quantity*1.2 as [Gross Value]
from Orders O join [Order Details] OD on O.OrderID = OD.OrderID
order by UnitPrice*Quantity desc

--Make a list of customers. Include only those customers whose 
--owner of the company is the contact person, 
--and whose company name starts and ends with the same letter.

select * 
from Customers
where left(CompanyName, 1) = RIGHT(CompanyName, 1)
and ContactTitle = 'Owner'

--Find an adjacency list in the three new model databases and 
--write a query using the relationship!

select *
from customers C 
join CustomerCustomerDemo CCD on C.CustomerID = ccd.CustomerID
join CustomerDemographics CD on ccd.CustomerTypeID = cd.CustomerTypeID

select E.FirstName, T.TerritoryDescription
from Employees E
join EmployeeTerritories ET on E.employeeid = ET.EmployeeID
join Territories T on ET.TerritoryID = t.TerritoryID

--Write a query to answer the question: are there any customers without orders?

select * 
from Customers 
where CustomerID not in (select CustomerID from Orders)

--List those orders where the handling employee and the customer lives in the same city

select o.*
from Customers C
join Orders O on C.CustomerID = O.CustomerID
join Employees E on O.EmployeeID = E.EmployeeID
where c.City = e.City

--Write a query to find the most expensive product in each category. 
--Return the product name, category name, unit price and the supplier's name.

select CategoryID, max(UnitPrice)
from Products
group by CategoryID

--Create a list with the orders shipped to France. 
--Include the order ID, the order date, the summarized value and discount value 
--(rounded to 2 decimal places) of the order, and the shipping cost

select o.OrderID, OrderDate, od.Quantity*od.UnitPrice, ROUND(Discount, 2)
from orders O
join [Order Details] OD on O.OrderID = OD.OrderID
where ShipCountry = 'France'

--Create a list with the orders shipped to France or Belgium. 
--Include the order ID, the order date, the summarized value and 
--discount value (rounded to 2 decimal places) of the order, and the shipping cost
--Use SET operators!

select o.OrderID, OrderDate, od.Quantity*od.UnitPrice, ROUND(Discount, 2)
from orders O
join [Order Details] OD on O.OrderID = OD.OrderID
where ShipCountry = 'France'
Union
select o2.OrderID, OrderDate, od2.Quantity*od2.UnitPrice, ROUND(Discount, 2)
from Orders O2
join [Order Details] OD2 on O2.OrderID = OD2.OrderID
where ShipCountry = 'Belgium'

--List the shipping providers and their income (orders.freight) in descending order. 
--Summarize the quantity shipped. Only include fulfilled orders.

select s.CompanyName, sum(Freight)
from Orders O
join Shippers s on o.ShipVia = s.ShipperID
where shippeddate is not Null
group by s.CompanyName
order by s.CompanyName

--List the product categories and their income during the summer months!

select c.CategoryName, sum(od.UnitPrice*od.Quantity) [Income]
from Products P
join [Order Details] OD on p.ProductID = od.ProductID
join Orders O on OD.OrderID = O.OrderID
join Categories c on p.CategoryID = c.CategoryID
where Month(OrderDate) in (6,7,8)
group by c.CategoryName
-- I took the order date into account because I assume that 
-- when an order was made the customer had to pay it right away

--Make a list of employees and their revenue. Include olympic-style ranking!

select E.EmployeeID, sum(OD.UnitPrice*od.Quantity) [Revenue], 
rank() over (order by sum(OD.UnitPrice*od.Quantity) desc) [Ranking]
from Employees E
join Orders O on E.EmployeeID = O.EmployeeID
join [Order Details] OD on O.OrderID = od.OrderID
group by E.EmployeeID

--Make a list of product category income, and the hypothetical income based 
--on sales quantity and list price. 
--Include the difference in a separate column and sort by this difference.

select P.CategoryID, 
sum(od.Quantity*od.UnitPrice) [Hypothetic?], 
sum(P.UnitsInStock*p.UnitPrice) [Based?], 
sum(od.Quantity*od.UnitPrice) - sum(P.UnitsInStock*p.UnitPrice) [Difference?]
from Products P
join [Order Details] OD on P.ProductID = OD.ProductID
group by P.CategoryID

--Generate a quarterly sales report for the 'Beverages' category, 
--detailing sales per quarter and comparing them to the previous quarter's sales.

select 
	case GROUPING(year(orderdate))
		when 0 then cast(year(O.OrderDate) AS VARCHAR(4))
		when 1 then 'GRAND TOTAL'
	end [year],
	case GROUPING(datepart(Quarter, Orderdate))
		when 0 then 'Q' + cast(datepart(Quarter, O.OrderDate) AS VARCHAR(1))
		when 1 then isnull(cast(year(orderdate) as varchar(4)), 'ALL')+' TOTAL'
	end [quarter],
sum(OD.Quantity*od.UnitPrice) [RevenuePerOrder]
from [Order Details] OD
join Products P on OD.ProductID = P.ProductID
join Categories C on P.CategoryID = C.CategoryID
join Orders O on Od.OrderID = O.OrderID
where C.CategoryName = 'Beverages'
group by rollup (year(orderdate), datepart(Quarter, Orderdate))

--List the discontinued products with their last order date.

select p.ProductID, max(o.orderdate)
from products p 
join [Order Details] od on p.ProductID = od.ProductID
join Orders o on od.OrderID = o.OrderID
where Discontinued = 1
group by p.ProductID

--We have a hypothesis that the unitsonorder field is redundant and equals the 
--summarized quantity of the given product on open (not shipped) orders. 
--Check this hypothesis with an SQL query.

select *
from products
where UnitsOnOrder <> 0

--List the number of products for which there is a stock shortage 
--(the quantity ordered but not yet delivered is greater than the stock of the product) 
--and the extent of this shortage. Make the query using CTE.

with StockShortageCTE as(
select ProductID, UnitsInStock-UnitsOnOrder [shortage]
from Products
where UnitsInStock<UnitsOnOrder
)


select *
from StockShortageCTE  
--********OR********

--select count(*) [NumberOFProducts], sum(shortage) [CumulatedShortage]
--from StockShortageCTE

-- _____________________________________________________________________________
-- /////////////SWITCH TO PUBS DATABASE TO BE ABLE TO RUN THE CODE\\\\\\\\\\\\\\
-- *****************************************************************************
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<HAVE FUN THERE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--Write a query that returns the book titles, their authors' names, the book price, and the publisher's name from 
--the pubs database. Filter the books that have a price between 15 and 20 dollars. 
--Sort the result by the authors' last names in ascending order and then by the book price in descending order.

select t.title [Title], 
isnull(a.au_fname+' ', '')+isnull(a.au_lname, '') [Author's name], 
price [Price], 
p.pub_name [Publisher's name]
from titles t
join titleauthor ta on t.title_id = ta.title_id
join authors a on ta.au_id = a.au_id
join publishers p on t.pub_id = p.pub_id
where price between 15 and 20
order by a.au_lname ,price desc

-- Write a query that displays the bestselling books with the following details: 
-- book title, first author's lastname, book price, year-to-date sales (`ytd_sales`), and publisher's name. 
-- Filter the books that have sold more than 500 copies year-to-date. 
-- Order the result by the number of copies sold in descending order so the most popular books appear at the top.

select t.title [Title], 
a.au_lname [Author's lastname], 
price [Price],
ytd_sales [Year-to-Date Sales], 
p.pub_name [Publisher's name]
from titles t
join titleauthor ta on t.title_id = ta.title_id
join authors a on ta.au_id = a.au_id
join publishers p on t.pub_id = p.pub_id
where ytd_sales>500
order by ytd_sales desc

--Write a query that displays the book title, advance paid, book price, year-to-date sales, 
--total revenue (price * ytd_sales), and the remaining amount of the advance that has not yet 
--been covered by sales (advance - (price * ytd_sales)). 
--Only display books where the advance paid is greater than the total revenue from sales. 

select title, advance, ytd_sales, price*ytd_sales [total revenue], advance - (price * ytd_sales) [remaining]
from titles
where advance>price*ytd_sales

--What is the average income on different authors' books? Also include authors without income with 0.

select au_id, AVG(ytd_sales*price)
from titles t
join titleauthor ta on t.title_id = ta.title_id
group by au_id

--List the titles, include only those that have more than one author.

select title, count(ta.au_id)
from titles t
join titleauthor ta on t.title_id = ta.title_id
group by title
having count(ta.au_id) > 1

-- Make a list of bookstores. Include the count of sales events, 
-- the sum of books sold, the total revenue of bookstores in the same state, 
-- and the Olympic-style ranking within the state.

select s.stor_id [Store], sum(qty*price) [Revenue], state [State], RANK() over (partition by state order by sum(qty*price) desc) [Rank in State]
from stores s 
join sales sls on s.stor_id = sls.stor_id
join titles t on sls.title_id =t.title_id
group by s.stor_id, state

select *
from stores s 
join sales sls on s.stor_id = sls.stor_id
join titles t on sls.title_id =t.title_id
order by s.stor_id

-- |______________________________________________________|
-- |--------SWITCH TO ADVENTUREWORKS_OLTP DATABASE--------|
-- |______________________________________________________|

--Make a list of employees who have received a pay rise. On each line, write the employee's name, salary, 
--previous salary and the percentage of the increase. 
--(An employee should be listed as many times as the number of times he or she has received a pay rise.)

select *
from HumanResources.EmployeePayHistory







