-- The business wants to run email campaigns for customers in store id 2 and needs the email ids, first name as well as last name of the customers. 
-- Write a query to fetch this data.
SELECT email, first_name, last_name
from customer
where store_id = 2;

-- While doing the audit of the business, one of the financial analyst found out that some DVD's are being rented out for $0.99. 
-- The finance department needs the count of such movies whose rental rate is $0.99. Can you help them?

SELECT count(rental_rate) as movies_count
from film
where rental_rate = 0.99;

-- The accounts department is thinking of coming up with a different way of accounting for the business costs. 
-- For this they need to find out the number of movies rented at different rental price points. 
-- Write an SQL query to provide this crucial input to the accounts department.

select rental_rate, count(*) as no_of_movies
from film
group by rental_rate;

-- The marketing team wants to understand how number of movies are spread across movie ratings. 
-- Can you help them?

SELECT rating, count(*) as no_of_movies
from film
GROUP by rating;

-- The marketing team also wants to know how ratings are distributed across stores. 
-- The team needs to know the distribution of ratings for each store in the dataset. 
-- Write a SQL query to help solve this problem.

select f.rating, count(i.store_id) as stores
from film f join inventory i on f.film_id=i.film_id
group by f.rating;

-- The digital marketing team is studying what other movie rental businesses are doing- 
-- what kind of movies are being rented out by competitors as well as the current company. 
-- Your job is to provide the team with details on film name, category each film belongs to and the language in which the film is.

SELECT f.title, c.name, l.name
from film f join film_category fc on f.film_id=fc.film_id
join category c on fc.category_id=c.category_id
join language l on l.language_id=f.language_id;

-- The business is interested to know about the popularity of the movies in the current inventory, 
-- the stores and customers who bring in more revenue. 
-- Help the business in finding out:
-- 
-- 

/*The number of times each movie is rented out.*/

select i.film_id, f.title, count(i.film_id) as rented_movies
from rental r
join inventory i on r.inventory_id=i.inventory_id
join film f on i.film_id=f.film_id
group by 1,2
order by 3 desc;

/*Revenue per movie*/

select
	i.film_id,
	f.title,
	count(i.film_id) as rented_movies,
	f.rental_rate,
	count(i.film_id)*f.rental_rate as revenue_from_movies
from rental r
join inventory i on r.inventory_id=i.inventory_id
join film f on i.film_id=f.film_id
GROUP by 1,2,4
order by 5 DESC;

/* Which customer has spent the most?*/

select
	c.customer_id,
	sum(p.amount) as spending
from customer c
join payment p on c.customer_id=p.customer_id
group by 1
order by 2 DESC
limit 1;

/*Most revenue earned by a store*/

select s.store_id, sum(p.amount) as total_revenue_by_store
from store s
join inventory i on i.store_id=s.store_id
join rental r on i.inventory_id=r.inventory_id
join payment p on p.rental_id=r.rental_id
group by 1
order by 2 desc
limit 1;

/*One important aspect of business is loyalty and reward programs for customers as well as internal stakeholders.
The business is currently looking at launching some strategic initiatives for which they need to know the following information: */

-- Last Rental Date of every customer

select customer_id, max(rental_date) as last_rental_date
from rental
GROUP by customer_id;

-- Total revenue per month

SELECT strftime('%m', payment_date) as Months, sum(amount) as revenue_per_month
from payment
group by 1;

-- Number of distinct renters per month

select strftime('%m',rental_date) as Month, count(distinct customer_id) as no_of_renters
from rental
group by 1;

-- Number of distinct film rented each month

select strftime('%m',rental_date) as Month, count(distinct i.film_id) as no_of_film_rented
from rental r
join inventory i on r.inventory_id=i.inventory_id
group by 1;

-- Number of rentals in Comedy, Sports and Family

select strftime('%m',rental_date) as Month, count(distinct i.film_id) as no_of_film_rented
from rental r
join inventory i on r.inventory_id=i.inventory_id
join film_category fc on fc.film_id=i.film_id
join category c on fc.category_id=c.category_id
where c.name in ('Comedy','Sports','Family')
group by 1;

-- Users who have rented movies at least three times

select r.customer_id, (c.first_name||" "||c.last_name) as full_name, count(c.customer_id)
from rental r
join customer c on c.customer_id=r.customer_id
group by 1
having count(c.customer_id) > 3
order by 1;

-- How much revenue has one single store made over PG13 and R rated films?

select s.store_id, f.rating, sum(p.amount) as revenue
from store s
join inventory i on i.store_id=s.store_id
join rental r on r.inventory_id=i.inventory_id
join payment p on p.rental_id=r.rental_id
join film f on f.film_id=i.film_id
where f.rating in ('PG13','R')
group by 1, 2;
