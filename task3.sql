-- Вывести количество фильмов в каждой категории, отсортировать по убыванию. 
SELECT 
	c.name, COUNT(f.film_id) AS film_count
FROM category c
LEFT JOIN film_category fc
ON c.category_id = fc.category_id
LEFT JOIN film f
ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY film_count DESC;

-- Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
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

--Вывести категорию фильмов, на которую потратили больше всего денег.
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

--Вывести названия фильмов, которых нет в inventory. 
--Написать запрос без использования оператора IN.



-- Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.

-- Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.

-- Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), и которые начинаются на букву “a”. 
-- То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.