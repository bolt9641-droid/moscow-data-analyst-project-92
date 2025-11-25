select count(customer_id) as customers_count from customers

-- Запрос подсчитывает количество покупателей в таблице customers с помощью count по колонке customer_id, 
-- которая является уникальным идентификатором для каждого покупателя. 
-- С помощью as customers_count мы даём название итоговой колонке, в которой содержится результат запроса.

    
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller, -- Запрос объединяет имя и фамилию сотрудника в одну колонку с названием "seller".
    COUNT(s.sales_id) AS operations,                  -- Подсчитывает количество сделок (sales_id) для каждого продавца и называет колонку "operations".
    FLOOR(SUM(s.quantity * p.price)) AS income        -- Вычисляет общую выручку (количество * цену), округляет вниз и называет колонку "income".
FROM
    sales s                                           -- Выбирает данные из таблицы "sales" с псевдонимом "s".
JOIN
    products p ON s.product_id = p.product_id         -- Присоединяет таблицу "products" по совпадению product_id.
JOIN
    employees e ON s.sales_person_id = e.employee_id  -- Присоединяет таблицу "employees" по совпадению sales_person_id и employee_id.
GROUP BY
    s.sales_person_id, e.first_name, e.last_name      -- Группирует результаты по ID продавца, имени и фамилии.
ORDER BY
    income DESC                                       -- Сортирует результаты по выручке в порядке убывания.
LIMIT 10;                                             -- Ограничивает вывод первыми десятью записями.


WITH overall_avg AS (
    SELECT FLOOR(AVG(s.quantity * p.price)) AS global_avg_income                   -- Запрос создает временную таблицу, вычисляет среднюю выручку по всем сделкам с округлением вниз и называет её global_avg_income.
    FROM sales s
    JOIN products p ON s.product_id = p.product_id                                 -- Объединяет таблицы products и sales по полю product_id.
)
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,                              -- Объединяет имя и фамилию сотрудника в одну колонку с названием "seller".
    FLOOR(AVG(s.quantity * p.price)) AS average_income                             -- Вычисляет среднюю выручку за сделку для каждого продавца с округлением вниз и называет колонку "average_income".
FROM
    sales s                                                                        -- Выбирает данные из таблицы "sales" с псевдонимом "s".
JOIN
    products p ON s.product_id = p.product_id                                      -- Присоединяет таблицу "products" по совпадению product_id.
JOIN
    employees e ON s.sales_person_id = e.employee_id                               -- Присоединяет таблицу "employees" по совпадению sales_person_id и employee_id.
GROUP BY
    s.sales_person_id, e.first_name, e.last_name                                   -- Группирует результаты по ID продавца, имени и фамилии.
HAVING
    FLOOR(AVG(s.quantity * p.price)) < (SELECT global_avg_income FROM overall_avg) -- Фильтрует продавцов, чья средняя выручка меньше общей средней выручки.
ORDER BY
    average_income ASC;                                                            -- Сортирует результаты по средней выручке в порядке возрастания.


SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,         -- Запрос объединяет имя и фамилию сотрудника в колонку "seller".
    LOWER(TRIM(TO_CHAR(s.sale_date, 'Day'))) AS day_of_week,  -- Преобразует дату в название дня недели на английском, удаляет пробелы, переводит в строчные буквы и называет колонку "day_of_week".
    FLOOR(SUM(s.quantity * p.price)) AS income                -- Вычисляет общую выручку (количество * цену), округляет вниз и называет колонку "income".
FROM
    sales s                                                   -- Выбирает данные из таблицы "sales" с псевдонимом "s".
JOIN
    products p ON s.product_id = p.product_id                 -- Присоединяет таблицу "products" по совпадению product_id.
JOIN
    employees e ON s.sales_person_id = e.employee_id          -- Присоединяет таблицу "employees" по совпадению sales_person_id и employee_id.
GROUP BY
    CONCAT(e.first_name, ' ', e.last_name),                   -- Группирует по полному имени продавца.
    LOWER(TRIM(TO_CHAR(s.sale_date, 'Day'))),                 -- Группирует по названию дня недели.
    case                                                      -- Начинает условное выражение для группировки по номеру дня недели.
        WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7         -- Если день воскресенье (0), присваивает 7 для сортировки.
        ELSE EXTRACT(DOW FROM s.sale_date)                    -- Иначе использует номер дня (1-6 для понедельника-субботы)
    END                                                       -- Завершает условное выражение.
ORDER BY
    CASE                                                      -- Начинает условное выражение для сортировки по номеру дня недели
        WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7         -- Если день воскресенье (0), присваивает 7.
        ELSE EXTRACT(DOW FROM s.sale_date)                    -- Иначе использует номер дня (1-6)
    END,                                                      -- Завершает условное выражение и сортирует по нему.
    seller;                                                   -- Сортирует по имени продавца.


SELECT                                          -- Начинает выборку данных из таблицы.
    CASE                                        -- Начинает условное выражение для категоризации возраста.
        WHEN age BETWEEN 16 AND 25 THEN '16-25' -- Если возраст от 16 до 25, присваивает категорию '16-25'.
        WHEN age BETWEEN 26 AND 40 THEN '26-40' -- Если возраст от 26 до 40, присваивает категорию '26-40'.
        WHEN age > 40 THEN '40+'                -- Если возраст больше 40, присваивает категорию '40+'.
    END AS age_category,                        -- Завершает условное выражение и называет колонку "age_category".
    COUNT(*) AS age_count                       -- Подсчитывает количество записей в каждой группе и называет колонку "age_count".
FROM                                            -- Указывает источник данных.
    customers                                   -- Выбирает данные из таблицы "customers".
GROUP BY                                        -- Группирует результаты.
    age_category                                -- Группирует по колонке "age_category".
ORDER BY                                        -- Сортирует результаты.
    age_category ASC;                           -- Сортирует по "age_category" в порядке возрастания.


SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS date,          -- Преобразует дату продажи в формат ГОД-МЕСЯЦ и называет колонку "date".
    COUNT(DISTINCT s.customer_id) AS total_customers, -- Подсчитывает количество уникальных покупателей по customer_id.
    FLOOR(SUM(s.quantity * p.price)) AS income        -- Вычисляет суммарную выручку (количество * цену), округляет вниз и называет колонку "income".
FROM
    sales s                                           -- Выбирает данные из таблицы "sales" с псевдонимом "s".
JOIN
    products p ON s.product_id = p.product_id         -- Присоединяет таблицу "products" по совпадению product_id.
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM')                   -- Группирует результаты по месяцу в формате ГОД-МЕСЯЦ.
ORDER BY
    date ASC;                                         -- Сортирует результаты по дате в порядке возрастания.


WITH first_sales AS (
    SELECT
        customer_id,
        MIN(sale_date) AS first_sale_date         -- Запрос находит минимальную дату первой покупки для каждого покупателя.
    FROM
        sales
    GROUP BY
        customer_id                               -- Группирует по customer_id для определения первой покупки.
),
promo_first AS (
    SELECT
        fs.customer_id,
        fs.first_sale_date,
        s.sales_person_id                         -- Выбирает данные о первой покупке, если товар акционный (price=0)
    FROM
        first_sales fs
    JOIN
        sales s ON fs.customer_id = s.customer_id AND fs.first_sale_date = s.sale_date -- Присоединяет sales для совпадения по покупателю и дате первой покупки.
    JOIN
        products p ON s.product_id = p.product_id                                      -- Присоединяет products для проверки цены.
    WHERE
        p.price = 0                                                                    -- Фильтрует только акционные товары с ценой 0
    GROUP BY
        fs.customer_id, fs.first_sale_date, s.sales_person_id                           -- Группирует для уникальности (если несколько товаров в первой покупке).
)
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,  -- Объединяет имя и фамилию покупателя в колонку "customer".
    pf.first_sale_date AS sale_date,                     -- Выбирает дату первой покупки.
    CONCAT(e.first_name, ' ', e.last_name) AS seller     -- Объединяет имя и фамилию продавца в колонку "seller".
FROM
    promo_first pf                                       -- Выбирает данные из временной таблицы promo_first с псевдонимом "pf".
JOIN
    customers c ON pf.customer_id = c.customer_id        -- Присоединяет таблицу "customers" по совпадению customer_id.
JOIN
    employees e ON pf.sales_person_id = e.employee_id    -- Присоединяет таблицу "employees" по совпадению sales_person_id.
ORDER BY
    pf.customer_id ASC;                                  -- Сортирует результаты по ID покупателя в порядке возрастания.
