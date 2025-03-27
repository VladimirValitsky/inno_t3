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
SELECT 
	f.title
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
WHERE i.inventory_id IS NULL;

-- Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. 
-- Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.
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

-- Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.


-- TODO: check for logic
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

-- Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), и которые начинаются на букву “a”. 
-- То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.




CTE rental_hours:

Сначала мы получаем сумму часов аренды фильмов по категориям для городов, где категория начинается с "a".
Используется SUM(TIMESTAMPDIFF(HOUR, r.rental_date, r.return_date)) для подсчета общего времени аренды в часах.
CTE max_rental_hours:

Определяем максимальные часы аренды для каждой категории от rental_hours.
CTE rental_hours_with_dashes:

Аналогично первому CTE, но здесь выбираем только города, в названиях которых есть символ "–".
CTE max_rental_hours_with_dashes:

Определяем максимальные часы аренды для каждой категории из rental_hours_with_dashes.
Основной запрос:

Используем UNION ALL, чтобы соединить результаты двух подзапросов. Мы извлекаем название категорий и максимальные часы аренды для каждой из двух условий и предоставляем контекст с помощью category_type.







WITH rental_hours AS (  
    SELECT  
        c.city_id,  
        cat.category_id,  
        SUM(TIMESTAMPDIFF(HOUR, r.rental_date, r.return_date)) AS total_hours  
    FROM  
        customer cu  
    JOIN  
        address a ON cu.address_id = a.address_id  
    JOIN  
        city c ON a.city_id = c.city_id  
    JOIN  
        inventory i ON cu.customer_id = r.customer_id  
    JOIN  
        rentals r ON i.inventory_id = r.inventory_id  
    JOIN  
        film_categories fc ON i.film_id = fc.film_id  
    JOIN  
        categories cat ON fc.category_id = cat.category_id  
    WHERE  
        cat.category_name LIKE 'a%' -- Категории, начинающиеся на 'a'  
    GROUP BY  
        c.city_id, cat.category_id  
),  
max_rental_hours AS (  
    SELECT   
        category_id,  
        MAX(total_hours) AS max_hours  
    FROM   
        rental_hours   
    GROUP BY   
        category_id  
),  
rental_hours_with_dashes AS (  
    SELECT  
        c.city_id,  
        cat.category_id,  
        SUM(TIMESTAMPDIFF(HOUR, r.rental_date, r.return_date)) AS total_hours  
    FROM  
        customer cu  
    JOIN  
        address a ON cu.address_id = a.address_id  
    JOIN  
        city c ON a.city_id = c.city_id  
    JOIN  
        inventory i ON cu.customer_id = r.customer_id  
    JOIN  
        rentals r ON i.inventory_id = r.inventory_id  
    JOIN  
        film_categories fc ON i.film_id = fc.film_id  
    JOIN  
        categories cat ON fc.category_id = cat.category_id  
    WHERE  
        c.city_name LIKE '%-%' -- Города, содержащие '-'  
    GROUP BY  
        c.city_id, cat.category_id  
),  
max_rental_hours_with_dashes AS (  
    SELECT   
        category_id,  
        MAX(total_hours) AS max_hours  
    FROM   
        rental_hours_with_dashes   
    GROUP BY   
        category_id  
)  
SELECT   
    'Categories starting with A' AS category_type,  
    cat.category_name,  
    mh.max_hours  
FROM   
    max_rental_hours mh  
JOIN   
    categories cat ON mh.category_id = cat.category_id  
WHERE   
    mh.max_hours IS NOT NULL  

UNION ALL  

SELECT   
    'Categories in cities with dashes' AS category_type,  
    cat.category_name,  
    mhw.max_hours  
FROM   
    max_rental_hours_with_dashes mhw  
JOIN   
    categories cat ON mhw.category_id = cat.category_id  
WHERE   
    mhw.max_hours IS NOT NULL;  