--1. Вывести количество фильмов в каждой категории, отсортировать по убыванию. 
SELECT 
	c.name, COUNT(f.film_id) AS film_count
FROM category c
LEFT JOIN film_category fc
ON c.category_id = fc.category_id
LEFT JOIN film f
ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY film_count DESC;

--2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
SELECT 
	a.last_name, COUNT(r.rental_id) AS rental_count
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON fa.film_id = f.film_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY a.last_name
ORDER BY rental_count DESC
LIMIT 10;

--3. Вывести категорию фильмов, на которую потратили больше всего денег.
SELECT 
	c.name, SUM(p.amount) AS total_amount
FROM category c
LEFT JOIN film_category fc
ON c.category_id = fc.category_id
LEFT JOIN film f
ON fc.film_id = f.film_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY total_amount DESC
LIMIT 1;

--4. Вывести названия фильмов, которых нет в inventory. 
--   Написать запрос без использования оператора IN.
SELECT 
	f.title
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
WHERE i.inventory_id IS NULL;

--5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. 
--   Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.
WITH actor_film_count AS(
	SELECT 
		a.last_name AS actor_name, COUNT(f.film_id) AS total_film_count
	FROM actor a
	JOIN film_actor fa
	ON a.actor_id = fa.actor_id
	JOIN film f
	ON fa.film_id = f.film_id
	JOIN film_category fc
	ON fc.film_id = f.film_id
	JOIN category c
	ON c.category_id = fc.category_id
	WHERE c.name = 'Children'
	GROUP BY a.last_name),
ranked_actors AS (
	SELECT 
	actor_name, total_film_count, 
	RANK() OVER (ORDER BY total_film_count DESC) AS rank
	FROM actor_film_count
)
SELECT
	actor_name, total_film_count
FROM ranked_actors
WHERE rank <=3;

--6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.
SELECT  
    c.city,  
    COUNT(CASE WHEN cust.active = 1 THEN 1 END) AS active_customers_count,  
    COUNT(CASE WHEN cust.active = 0 THEN 1 END) AS inactive_customers_count  
FROM customer cust  
JOIN address a 
ON cust.address_id = a.address_id  
JOIN city c 
ON a.city_id = c.city_id  
GROUP BY c.city  
ORDER BY inactive_customers_count DESC;  

--7. Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), 
--   и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
WITH rental_sum AS (
	SELECT 
		cat.name category_name, c.city city, 
		ROUND(SUM(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600), 2) AS total_hours
	FROM category cat
	LEFT JOIN film_category fc
	ON cat.category_id = fc.category_id
	LEFT JOIN film f
	ON fc.film_id = f.film_id
	JOIN inventory i
	ON i.film_id = f.film_id
	JOIN rental r
	ON i.inventory_id = r.inventory_id
	JOIN customer cust
	ON r.customer_id = cust.customer_id
	JOIN address a
	ON cust.address_id = a.address_id
	JOIN city c
	ON a.city_id = c.city_id
	WHERE c.city LIKE 'A%'
	GROUP BY cat.name, c.city
),
max_rental AS (
	SELECT
		category_name, city, total_hours,
		RANK() OVER (PARTITION BY city ORDER BY total_hours DESC) as rank
	FROM rental_sum
)
SELECT
	category_name, city, total_hours
FROM max_rental
WHERE rank = 1
ORDER BY total_hours DESC
LIMIT 1;