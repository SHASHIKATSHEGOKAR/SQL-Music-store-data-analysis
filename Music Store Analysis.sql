/* make chinook as the defalut database */
USE chinook

/* Easy */

/* Q1. Who isthe most senior most employee based on the job title */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2 which countries have the most invocies */

select count(*) as c , billingcountry 
from Invoice
group by billingcountry
order by c desc;

/* Q3 what are top 3 values of total Invoices */

select total from invoice 
order by total desc
limit 3;

/* Q4 which city has the best customers? we would like to throw a promotional 
	musical Festival in the city we made the most meney. write a query that returns one city that has the highest sum of invoice totals. 
	return both the city name & sum of all invoice totals */

select sum(total) as invoicetotal, billingcity 
from invoice 
group by billingcity
order by invoicetotal desc;

/* Q5 who is the best customer? the customer who has spent the most money will be declared the 
	 best customer. write a query that returns the person who has spent the most money. */
     
 select customer.customerID, customer.FirstName, customer.LastName, sum(invoice.total) as Total
 from customer
 join invoice on customer.customerID = invoice.customerID 
 group by customer.customerID 
 order by Total desc
 limit 1;
 
/* Medium */
 
/* 1 write query to return the email, first name, last name, & genre of all rock music listeners
  Return your list orderd alphabetically by email strating with A */

select distinct email, FirstName, LastName 
from customer 
join invoice on customer.customerID = invoice.customerID
Join Invoiceline on Invoiceline.InvoiceID = Invoice.InvoiceID
where TrackID in (
	select TrackID from track 
    join genre on  Track.GenreID = genre.GenreID
    where genre.name like 'Rock'
    )
    order by email;
    
/*2 Le's invite the artist who have written the most rock music in our dataset write a query
   that returns the Artist name and total track count of the top 10 rock bands */

select artist.artistID, artist.name,count(artist.artistID) as number_of_songs
from track
join album on album.albumID = track.albumID 
join artist on artist.artistID = album.artistID
join genre on genre.genreID = track.genreid
where genre.name like 'Rock'
group by artist.artistID
order by number_of_songs desc
limit 10;

/* Q3 Return all the track names that have a song length longer than the average long length.
	  Return the name and milliseconds for each trak. order by the song length with the longestsongs 
      listed first */

select name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
    from track
    )
order by milliseconds desc;

/* Hard */

/* Q1. Find how much amount spend by each customer on artist, write a query to return      
	customer name, artis name and total spent */
    
    with best_selling_artist as (
		select artist.artistid as artistID, artist.name as artistname, 
		sum(invoiceline.UnitPrice * Invoiceline.Quantity) as spent_total 
		from invoiceline
        join track on track.trackID = invoiceline.trackID
        join album on album.albumID = track.albumID
        join artist on artist.artistID = album.artistID
        group by 1
        order by 3 desc
        limit 1
        )
select c.customerID, c.firstname, c.lastname, bsa.artistname, 
sum(il.quantity * il.unitprice) as amount_spent
from invoice i 
join customer c on c.customerID = i.customerID
join invoiceline il on il.invoiceID = i.invoiceID
join track t on il.trackID = t.trackID
join album abl on abl.albumID = t.albumID
join best_selling_artist bsa on bsa.artistID = abl.artistID
group by 1,2,3,4
order by 5 desc; 

/* Q2 We watn to find out the most popular music Genre for each counry
	  We determine the most popular genre as the genre with the highest amount of purchases.
	  Write a query that returns each country along with the top Genre.For countries where 
	  the maximum number of Purchases is shared return all Genres */

with popular_genre as 
(
    select count(invoiceline.quantity) as purchases, customer.country, genre.name, genre.genreID, 
		row_number() over(partition by customer.country 
		order by count(invoiceline.quantity) desc) as rowNo 
    from invoiceline
    join invoice on invoice.invoiceID = invoiceline.invoiceID
    join customer on customer.customerID = invoice.customerID
    join track on track.trackID = invoiceline.trackID
    join genre on genre.genreID = track.genreID
    group by 2,3,4
    order by 2 asc, 1 desc
)
select * from popular_genre where rowNo <= 1; 
    
/* Q3 Write a query that determines the customer that has spent the most on music for each
  country. Write a query that returns the country along with the top customer and how 
  much they spent. For countries where the top amount spent is shared, provide all customers
  who spent this amount */

with customer_with_country as (
		select customer.customerID,firstname,lastname,billingcountry, sum(total) as spending_total,
    row_number() over(partition by billingcountry order by sum(total) desc) as rowNO
		from invoice 
        join customer on customer.customerID = invoice.customerID
        group by 1,2,3,4
        order by 4 asc, 5 desc) 
select * from customer_with_country where rowNO <= 1












