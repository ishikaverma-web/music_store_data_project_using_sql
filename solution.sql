
select * from albumy
order by album_id asc;

create table album as
select * from albumy
order by album_id asc;

select * from album;

drop table albumy;
-- who is the senior most employee based on the job title ?
select * from employee
order by levels desc
limit 1;

-- which country have the most invoices?
select * from invoice;

select count(invoice_id) , billing_country from invoice
group by billing_country
order by count(invoice_id) desc;

-- what are the top 3 values of total invoice?

select total  from invoice

order by total desc
limit 3;

-- which city has the best customers? we would like to throw a promotional music festival in the city that made the most money . 
-- write a query that returns one city that has the highest sum of invoice totals . return both the city name and sum of all invoice totals ?

select billing_city , sum(total)as t from invoice
group by billing_city
order by t desc;


-- who is the best customer? the customer who has spent the most money 
-- will be declared the best customer. write a query that returns the person who has spent the most money 



select customer.customer_id , customer.first_name, customer.last_name , sum(invoice.total) from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id ,customer.first_name, customer.last_name
order by sum(invoice.total) desc
limit 1;

-- write a query to return the email , fn , ln, and genre of all rock music listeners. return your list ordered 
-- alpha, by email starting with A

select distinct email, first_name , last_name from customer
join invoice on customer.customer_id = invoice.invoice_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name  like 'ROCK')
order by email;

-- lets invite the artist who have written the most rock music in our dataset . write a quesry that alter
-- returns the artist name and total track count of the top 10 rock bands

select artist.artist_id , artist.name , count(artist.artist_id) as total_songs
from track 
join album on track.album_id = album.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'rock'
group by artist.artist_id ,artist.name 
order by total_songs desc
limit 10;

-- return all the track names that have a song length longer than the average song length.
-- return the name and miliseconds for each track . order the song length with the longest song listed first.

select * from track; -- to get the idea of what schema to use

select track_id ,name,  milliseconds  from track
where milliseconds > (select
avg(milliseconds) from track)
order by milliseconds desc;


-- find how much amount spent by each customer on arists? write a query to return customer name, artist name and total spent

with best_selling_artist as (
select artist.artist_id as artist_id , artist.name as artist_name , sum(invoice_line.unit_price*
invoice_line.quantity) as total_sales from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1 ,2
order by 3 desc
limit 1
)
select customer.customer_id , customer.first_name, customer.last_name,  best_selling_artist.artist_name
,sum(invoice_line.unit_price*
invoice_line.quantity) as total_spent from invoice
join customer on invoice.customer_id = customer.customer_id 
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id 
join best_selling_artist on best_selling_artist.artist_id = artist.artist_id
group by 1,2,3,4
order by 5 desc;

-- we want to find out the most popular music genre for each country. we determine the most 
-- popular genre as the genre with the highest amount of purchases. write a quesry that returns each country along with
-- the top genre. for countries where the maximum number of purchases is shared return all genres.

with popular_genre as (
select count(invoice_line.quantity) as purchases , genre.name , genre.genre_id , customer.country ,
row_number() over (partition by customer.country order by count(invoice_line.quantity) desc ) as row_num
from invoice_line 
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 4 asc , 1 desc
)



select * from popular_genre
where row_num<=1;

 
