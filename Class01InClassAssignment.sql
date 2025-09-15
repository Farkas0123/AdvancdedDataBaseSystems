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