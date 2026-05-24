
# 🧠 Руководство по оптимизации SQL-запросов для PostgreSQL, MS SQL и Oracle

## 1. Общие принципы оптимизации
- Минимизируйте выборку: выбирайте только нужные колонки.
- Используйте `WHERE`, чтобы ограничить строки до минимально необходимого набора.
- Избегайте `SELECT *`.

## 2. Использование индексов
### PostgreSQL:
- Используйте **GIN** и **GiST** для поиска по JSONB/тексту.
- **Partial Indexes**: индексируются только строки, удовлетворяющие условию.
### MS SQL:
- Используйте **Filtered Indexes**, **Covering Indexes**.
### Oracle:
- Используйте **Bitmap Indexes** для колонок с низкой кардинальностью.

```sql
-- PostgreSQL partial index
CREATE INDEX idx_active_users ON users(user_id)
WHERE is_active = true;
```

## 3. JOIN, CTE и подзапросы
- Используйте `EXISTS` вместо `IN` для подзапросов с большим числом строк.
- Не злоупотребляйте `CTE`, особенно рекурсивными: они материализуются.
- Проверяйте планы выполнения: `EXPLAIN ANALYZE`, `SET STATISTICS IO ON`.

```sql
-- Более эффективный подход
SELECT * FROM orders o
WHERE EXISTS (
  SELECT 1 FROM customers c
  WHERE c.id = o.customer_id AND c.vip = true
);
```

## 4. План выполнения
- PostgreSQL: `EXPLAIN ANALYZE`
- MS SQL: `SET STATISTICS TIME, IO ON`
- Oracle: `EXPLAIN PLAN FOR ...` и `DBMS_XPLAN.DISPLAY`

## 5. Партиционирование
- **Range**, **List**, **Hash** — выбирайте в зависимости от данных.
- PostgreSQL 14+ поддерживает декларативное партиционирование.
- Oracle: Composite partitioning (range + list).

## 6. Материализованные представления
- Используйте, когда часто нужны агрегаты или тяжёлые JOIN-ы.
- PostgreSQL: `REFRESH MATERIALIZED VIEW`
- Oracle: `FAST REFRESH` при условии соответствия

```sql
-- PostgreSQL
CREATE MATERIALIZED VIEW sales_summary AS
SELECT region, SUM(amount) FROM sales GROUP BY region;
```

## 7. Оконные функции
- Мощные, но требуют сортировки → внимательно с большими объёмами
```sql
SELECT user_id, amount,
  RANK() OVER (PARTITION BY user_id ORDER BY amount DESC) AS rank
FROM transactions;
```

## 8. Специфика платформ
- PostgreSQL:
  - Отлично работает с CTE, но может материализовать.
  - Лучше избегать ненужных `OFFSET`, использовать keyset pagination.
- MS SQL:
  - Поддержка **index hints**, но использовать осторожно.
  - Оптимизатор может проигнорировать `WITH (NOLOCK)` при несогласованных данных.
- Oracle:
  - Уникальный оптимизатор (CBO), reliance на **hints** (`/*+ */`).
  - Используйте `AUTOTRACE`, `DBMS_STATS`.

## 9. Примеры плохого и хорошего SQL

❌ Плохо:
```sql
SELECT * FROM users
WHERE UPPER(name) = 'EGOR';
```

✅ Лучше:
```sql
-- Создать функциональный индекс (если поддерживается)
CREATE INDEX idx_users_upper_name ON users(UPPER(name));

SELECT * FROM users
WHERE UPPER(name) = 'EGOR';
```

---

📌 Используйте индексы с умом, следите за планом выполнения, не бойтесь экспериментировать и всегда профилируйте ваши запросы.
