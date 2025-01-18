---EASY LEVEL 
--Quetion 1



SElECT * FROM album

SELECT * FROM employee
Order by levels desc
limit 1

Select COUNT(*) as c, billing_country
from invoice
group by billing_country
order by c desc

Select total from invoice
order by total desc 
limit 3

Select * from invoice 
Select SUM(total) as invoice_total, billing_city
FROM invoice
group by billing_city
order by invoice_total desc


select * from customer
select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total 
from customer
join invoice on customer.customer_id = invoice.customer_id
Group by customer.customer_id
order by total DESC
limit 1

MODERATE

--QUESTION 1 

SELECT DISTINCT email,first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id 
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
    select track_id from track
	join genre on track.genre_id = genre.genre_id
	Where genre.name LIKE 'Rock'
)
ORDER BY email;


--QUESTION 2 

select * from track

Select artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_song
FROM track
JOIN album ON album.album_id = track.album_id 
JOIN artist ON artist.artist_id = album.artist_id 
JOIN genre ON genre.genre_id = track.genre_id 
Where genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_song DESC
LIMIT 10;

--QUESTION 3


SELECT name,milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
	FROM track)
ORDER BY milliseconds DESC;


--- ADVANCE LEVEL 

--QUESTION 1

WITH best_selling_artist AS (
     SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
	 SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	 FROM invoice_line
	 JOIN track ON track.track_id = invoice_line.track_id
	 JOIN album ON album.album_id = track.album_id
	 JOIN artist ON artist.artist_id = album.artist_id
	 GROUP BY 1 
	 ORDER BY 3 DESC
	 LIMIT 1 
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spend
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



--- Question 2 

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNO
	FROM  invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC

)
SELECT * FROM popular_genre WHERE RowNO <= 1




---Question 3 



WITH RECURSIVE
     customer_with_country AS (
         SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		 FROM invoice
		 JOIN customer ON customer.customer_id =  invoice.customer_id
		 GROUP BY 1,2,3,4
		 ORDER BY 1,5 DESC),

     country_max_spending AS(
          SELECT billing_country, MAX(total_spending) AS max_spending 
		  FROM customer_with_country 
		  GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id 
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;