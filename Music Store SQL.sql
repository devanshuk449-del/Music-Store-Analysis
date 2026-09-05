--Easy
--1. Who is the senior most employee based on job title?

Select * From Employee
Order By Level Desc
Limit 1;

--2. Which countries have the most Invoices? 

Select Billing_Country,
Count(*) as Total_Invoices
From Invoice
Group By Billing_Country
Order By Total_Invoices Desc

--3. What are top 3 values of total invoice?

Select Total From Invoice
Order By Total Desc
Limit 3;

--4. Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals 

Select Billing_City,
Sum(Total) As Invoice_Total
From Invoice
Group By Billing_City
Order By Invoice_Total Desc

--5. Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money

Select Customer.Customer_Id, Customer.Full_Name,
Sum(Invoice.Total) as Invoice_Total
From Customer
Join Invoice
On Customer.Customer_Id = Invoice.Customer_Id
Group By Customer.Customer_Id,
Customer.Full_Name
Order By Invoice_Total Desc
Limit 1;

--Moderate
--1. Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A 

Select Distinct
Customer.Email,
Customer.First_Name,
Customer.Last_Name,
Genre.Name As Genre
From Customer
Join Invoice on Customer.Customer_Id = Invoice.Customer_Id
Join Invoice_Line on Invoice.Invoice_Id = Invoice_Line.Invoice_Id
Join Track on Invoice_Line.Track_Id = Track.Track_Id
Join Genre on Track.Genre_Id = Genre.Genre_Id
Where Genre.Name = 'Rock'
Order By Customer.Email Asc;

--2. Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands

Select
Artist.Name as Artist_Name,
Count(Track.Track_Id) as Total_Rock_Tracks
From Artist
Join Album on Artist.Artist_Id = Album.Artist_Id
Join Track on Album. ALbum_Id = Track.Album_Id
Join Genre on Track.Genre_Id = Genre.Genre_Id
Where Genre.Name = 'Rock'
Group By Artist.Name
Order By Total_Rock_Tracks Desc
Limit 10;

--3. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first 

Select 
Name as Track_Name,
Milliseconds
From Track
Where Milliseconds >(
Select Avg(Milliseconds) From Track
)
Order By Milliseconds Desc;

--Advance
--1. Find how much amount spent by each customer on artists? Write a query to return 
--customer name, artist name and total spent 

Select
Customer.Full_Name,
Artist.Name as Artist_Name,
Round(Sum(Invoice_Line.Unit_Price * Invoice_Line.Quantity),2) as Total_Spent
From Customer
Join Invoice on Customer.Customer_Id = Invoice.Customer_Id
Join Invoice_Line on Invoice.Invoice_Id = Invoice_Line.Invoice_Id
Join Track on Invoice_Line.Track_Id = Track.Track_Id
Join Album on Track.Album_Id = Album.Album_Id
Join Artist on Album.Artist_Id = Artist.Artist_Id
Group By Customer.Full_Name, Artist_Name
Order By Total_Spent Desc;

--2. We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres 

With Genre_Purchase_Count As (
    Select
        Customer.Country,
        Genre.Name As Genre,
        Count(*) As Total_Purchases
    From Customer
    Join Invoice On Customer.Customer_Id = Invoice.Customer_Id
    Join Invoice_Line On Invoice.Invoice_Id = Invoice_Line.Invoice_Id
    Join Track On Invoice_Line.Track_Id = Track.Track_Id
    Join Genre On Track.Genre_Id = Genre.Genre_Id
    Group By Customer.Country, Genre.Name
),
Max_Purchases_Per_Country As (
    Select 
        Country,
        Max(Total_Purchases) As Max_Purchases
    From Genre_Purchase_Count
    Group By Country
)
Select 
    gpc.country,
    gpc.genre,
    gpc.total_purchases
From Genre_Purchase_Count gpc
Join Max_Purchases_Per_Country mpc
  On gpc.country = mpc.country And gpc.total_purchases = mpc.max_purchases
Order By gpc.country Asc, gpc.genre Asc;

--3. Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how 
--much they spent. For countries where the top amount spent is shared, provide all 
--customers who spent this amount 


With Customer_Total_Spent As (
    Select 
        Customer.Country,
        Customer.Customer_Id,
        Customer.Full_Name,
        Round(Sum(Invoice.Total), 2) As Total_Spent
    From Customer
    Join Invoice On Customer.Customer_Id = Invoice.Customer_Id
    Group By Customer.Country, Customer.Customer_Id, Customer.Full_Name
),
Max_Spent_Per_Country As (
    Select 
        Country,
        Max(Total_Spent) As Max_Spent
    From Customer_Total_Spent
    Group By Country
)
Select 
    cts.country,
    cts.full_name,
    cts.total_spent
From Customer_Total_Spent cts
Join Max_Spent_Per_Country mspc
  On cts.country = mspc.country And cts.total_spent = mspc.max_spent
Order By cts.country Asc, cts.full_name Asc;


