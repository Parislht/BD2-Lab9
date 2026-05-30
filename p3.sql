DROP TABLE IF EXISTS articles;

CREATE TABLE articles2 (
    n INTEGER,
    id INTEGER,
    title TEXT,
    publication TEXT,
    author TEXT,
    article_date DATE,
    year NUMERIC,
    month NUMERIC,
    url TEXT,
    content TEXT
);


SELECT COUNT(*) FROM articles2;

--Crea atributo indexado 
ALTER TABLE articles2
DROP COLUMN IF EXISTS full_text_idx;

ALTER TABLE articles2
ADD COLUMN full_text_idx tsvector;

--Generar contenido del nuevo atributo
UPDATE articles2
SET full_text_idx =
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(content, '')), 'B');


--Crear versiones de las tablas con diferentes volumenes de datos aleatorios
-- Crear subconjunto aleatorio de 10 mil registros
CREATE TABLE articles_2_10mil AS
SELECT *
FROM articles2
ORDER BY random()
LIMIT 10000;

-- Crear subconjunto aleatorio de 20 mil registros
CREATE TABLE articles_2_20mil AS
SELECT *
FROM articles2
ORDER BY random()
LIMIT 20000;

-- Crear subconjunto aleatorio de 30 mil registros
CREATE TABLE articles_2_30mil AS
SELECT *
FROM articles2
ORDER BY random()
LIMIT 30000;


--Crear Indices para las tablas 
-- Índice para tabla de 10 mil
CREATE INDEX articles_2_10mil_gin
ON articles_2_10mil
USING GIN (full_text_idx);

-- Índice para tabla de 20 mil
CREATE INDEX articles_2_20mil_gin
ON articles_2_20mil
USING GIN (full_text_idx);

-- Índice para tabla de 30 mil
CREATE INDEX articles_2_30mil_gin
ON articles_2_30mil
USING GIN (full_text_idx);

-- Verificar Tamaños
SELECT COUNT(*) AS total_10mil FROM articles_2_10mil;
SELECT COUNT(*) AS total_20mil FROM articles_2_20mil;
SELECT COUNT(*) AS total_30mil FROM articles_2_30mil;



--Consultas de los top k mejores (Por cada pasada se fue cambiando el nombre
--de la tabla articles2_xmil) segun se rteigstraban los duiferentes tamaños

--Consultas con Indice 
--Top 50 mejores
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'trump | health | police')) AS rank
FROM articles_2_30mil
WHERE full_text_idx @@ to_tsquery('english', 'trump | health | police')
ORDER BY rank DESC
LIMIT 50;

--Top 100 mejores
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'trump | health | police')) AS rank
FROM articles_2_30mil
WHERE full_text_idx @@ to_tsquery('english', 'trump | health | police')
ORDER BY rank DESC
LIMIT 100;

--Top 200 mejores
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'trump | health | police')) AS rank
FROM articles_2_30mil
WHERE full_text_idx @@ to_tsquery('english', 'trump | health | police')
ORDER BY rank DESC
LIMIT 200;


--Consultas sin Indice
--Top 50 sin indice
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(
        (
            setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
            setweight(to_tsvector('english', coalesce(content, '')), 'B')
        ),
        to_tsquery('english', 'trump | health | police')
    ) AS rank
FROM articles_2_30mil
WHERE (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(content, '')), 'B')
) @@ to_tsquery('english', 'trump | health | police')
ORDER BY rank DESC
LIMIT 50;


--Top 100 sin indice
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(
        (
            setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
            setweight(to_tsvector('english', coalesce(content, '')), 'B')
        ),
        to_tsquery('english', 'trump | health | police')
    ) AS rank
FROM articles_2_30mil
WHERE (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(content, '')), 'B')
) @@ to_tsquery('english', 'trump | health | police')
ORDER BY rank DESC
LIMIT 100;

--Top 200 sin indice
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(
        (
            setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
            setweight(to_tsvector('english', coalesce(content, '')), 'B')
        ),
        to_tsquery('english', 'trump | health | police')
    ) AS rank
FROM articles_2_30mil
WHERE (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(content, '')), 'B')
) @@ to_tsquery('english', 'trump | health | police')
ORDER BY rank DESC
LIMIT 200;
