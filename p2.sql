
--Crear atributo
ALTER TABLE film
ADD COLUMN full_text_idx tsvector;


--Poblar atributo 
UPDATE film
SET full_text_idx =
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'B');


--Crear indice sobre nuevo atributo 
CREATE INDEX film_full_text_gin
ON film
USING GIN (full_text_idx);



--Replicar Registros
--EN la primera pasada no se usa, se trabaja con los datos originales
--En la segunda se inserta 500 registros más (replicados)


-- Insertar 500 registros replicados recalculando full_text_idx
INSERT INTO film (
    title,
    description,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update,
    special_features,
    fulltext,
    full_text_idx
)
SELECT
    new_title,
    description,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    now() AS last_update,
    special_features,
    fulltext,
    setweight(to_tsvector('english', coalesce(new_title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'B') AS full_text_idx
FROM (
    SELECT
        title || ' replica_' || row_number() OVER () AS new_title,
        description,
        release_year,
        language_id,
        rental_duration,
        rental_rate,
        length,
        replacement_cost,
        rating,
        special_features,
        fulltext,
        film_id
    FROM film
    WHERE title NOT LIKE '% replica_%'
    ORDER BY film_id
    LIMIT 500
) AS replicas;


SELECT count(*) AS total_registros
FROM film;


--CONSULTAS 
--RANKING TOP

--Con Indice 
--top5 con Indice
EXPLAIN ANALYZE
SELECT
    film_id,
    title,
    description,
    ts_rank(full_text_idx, plainto_tsquery('english', 'action drama')) AS rank
FROM film
WHERE full_text_idx @@ plainto_tsquery('english', 'action drama')
ORDER BY rank DESC
LIMIT 5;

--top25 con Indice
EXPLAIN ANALYZE
SELECT
    film_id,
    title,
    description,
    ts_rank(full_text_idx, plainto_tsquery('english', 'action drama')) AS rank
FROM film
WHERE full_text_idx @@ plainto_tsquery('english', 'action drama')
ORDER BY rank DESC
LIMIT 25;

--top100 con Indice
EXPLAIN ANALYZE
SELECT
    film_id,
    title,
    description,
    ts_rank(full_text_idx, plainto_tsquery('english', 'action drama')) AS rank
FROM film
WHERE full_text_idx @@ plainto_tsquery('english', 'action drama')
ORDER BY rank DESC
LIMIT 100;



--Sin Indice

--top5 sin Indice 
EXPLAIN ANALYZE
SELECT
    film_id,
    title,
    description,
    ts_rank(
        (
            setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
            setweight(to_tsvector('english', coalesce(description, '')), 'B')
        ),
        plainto_tsquery('english', 'action drama')
    ) AS rank
FROM film
WHERE (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'B')
) @@ plainto_tsquery('english', 'action drama')
ORDER BY rank DESC
LIMIT 5;

--top25 sin Indice 
EXPLAIN ANALYZE
SELECT
    film_id,
    title,
    description,
    ts_rank(
        (
            setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
            setweight(to_tsvector('english', coalesce(description, '')), 'B')
        ),
        plainto_tsquery('english', 'action drama')
    ) AS rank
FROM film
WHERE (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'B')
) @@ plainto_tsquery('english', 'action drama')
ORDER BY rank DESC
LIMIT 25;

--top100 sin Indice 
EXPLAIN ANALYZE
SELECT
    film_id,
    title,
    description,
    ts_rank(
        (
            setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
            setweight(to_tsvector('english', coalesce(description, '')), 'B')
        ),
        plainto_tsquery('english', 'action drama')
    ) AS rank
FROM film
WHERE (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'B')
) @@ plainto_tsquery('english', 'action drama')
ORDER BY rank DESC
LIMIT 100;
