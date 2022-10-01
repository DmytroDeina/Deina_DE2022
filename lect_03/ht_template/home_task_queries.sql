/*
 Завдання на SQL до лекції 02.
 */


/*
1.
Вивести кількість фільмів в кожній категорії.
Результат відсортувати за спаданням.
*/
select
    name as category_name,
    count(*) as number_of_films
from public.category c
    inner join public.film_category fc
    on c.category_id = fc.category_id
order by number_of_films desc;


/*
2.
Вивести 10 акторів, чиї фільми брали на прокат найбільше.
Результат відсортувати за спаданням.
*/

select
    last_name,
    first_name,
    count(*) as times_rented
from public.actor a
    inner join public.film_actor fa
    on a.actor_id = fa.actor_id
        inner join public.inventory i
        on fa.film_id = i.film_id
            inner join public.rental r
            on i.inventory_id = r.inventory_id
group by last_name, first_name
order by times_rented desc
limit 10;



/*
3.
Вивести категорія фільмів, на яку було витрачено найбільше грошей
в прокаті
*/
-- Додаткова перевірка на випадок якщо категорій з максимальною сумою витрат > 1
with cat_sum as (
                select
                    name as category_name,
                    sum(amount) as total_payments
                from public.category c
                    inner join public.film_category fc
                    on c.category_id = fc.category_id
                        inner join public.inventory i
                        on fc.film_id = i.film_id
                            inner join public.rental r
                            on i.inventory_id = r.inventory_id
                                inner join public.payment p
                                on r.rental_id = p.rental_id
                group by name
)
select
    category_name
from cat_sum
where total_payments = (select max(total_payments)
                        from cat_sum);

/*
4.
Вивести назви фільмів, яких немає в inventory.
Запит має бути без оператора IN
*/
select
    title
from public.film f
    left join public.inventory i
    on f.film_id = i.film_id
where i.film_id is null;


/*
5.
Вивести топ 3 актори, які найбільше зʼявлялись в категорії фільмів “Children”.
*/
select
    last_name,
    first_name,
    count(*) as num_appeared
from public.actor a
    inner join public.film_actor fa
    on a.actor_id = fa.actor_id
        inner join public.film_category fc
        on fa.film_id = fc.film_id
            inner join public.category c
            on fc.category_id = c.category_id
where c.name = 'Children'
group by last_name, first_name
order by num_appeared desc
limit 3;



/*
6.
Вивести міста з кількістю активних та неактивних клієнтів
(в активних customer.active = 1).
Результат відсортувати за кількістю неактивних клієнтів за спаданням.
*/

select
    city,
    sum(cr.active) as number_of_active_customers,
    sum(case when cr.active = 0 then 1 else 0 end) as number_of_inactive_customers
from public.city c
    inner join public.address a
    on c.city_id = a.city_id
        inner join public.store s
        on a.adress_id = s.adress_id
            inner join public.customer c
            on s.store_id = c.store_id
group by city
order by number_of_inactive_customers desc