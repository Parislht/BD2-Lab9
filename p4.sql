--Trabajando con la tabla con el campo de texto completo articles2 del punto anterior

--Crear copia idéntica de articles2
CREATE TABLE articles2_gist AS
SELECT *
FROM articles2;

--Eliminar índices previos si existían
DROP INDEX IF EXISTS articles2_gin_idx;
DROP INDEX IF EXISTS articles2_gist_idx;

--Crear índice GIN sobre articles2
CREATE INDEX articles2_gin_idx
ON articles2
USING GIN (full_text_idx);

--Crear índice GiST sobre articles2_gist
CREATE INDEX articles2_gist_idx
ON articles2_gist
USING GIST (full_text_idx);

-- Actualizar estadísticas
ANALYZE articles2;
ANALYZE articles2_gist;



SELECT COUNT(*) AS total_articles2
FROM articles2;

SELECT COUNT(*) AS total_articles2_gist
FROM articles2_gist;


--Inserciones 

--Insercion de 100 registros sinteticos en articles2 con GIN 

EXPLAIN ANALYZE
INSERT INTO articles2 (
    n,
    id,
    title,
    publication,
    author,
    article_date,
    year,
    month,
    url,
    content,
    full_text_idx
)
SELECT
    910000 + gs AS n,
    910000 + gs AS id,
    'Synthetic GIN Article ' || gs || ' about neural retrieval, quantum finance and climate risk' AS title,
    'Synthetic News Lab' AS publication,
    'Generated Author' AS author,
    DATE '2026-05-29' AS article_date,
    2026 AS year,
    5 AS month,
    'https://synthetic.example.com/gin-test-' || gs AS url,
    'This synthetic document contains complex terms about artificial intelligence, information retrieval, vector databases, quantum computing, financial markets, cybersecurity, climate policy, renewable energy, ranking algorithms, PostgreSQL indexing, full text search, GIN indexes, GiST indexes and large scale search systems.' AS content,
    setweight(to_tsvector('english', 'Synthetic GIN Article ' || gs || ' about neural retrieval, quantum finance and climate risk'), 'A') ||
    setweight(to_tsvector('english', 'This synthetic document contains complex terms about artificial intelligence, information retrieval, vector databases, quantum computing, financial markets, cybersecurity, climate policy, renewable energy, ranking algorithms, PostgreSQL indexing, full text search, GIN indexes, GiST indexes and large scale search systems.'), 'B') AS full_text_idx
FROM generate_series(1, 100) AS gs;

--Insercion de 100 registros sinteticos en articles2_gin con GIST
EXPLAIN ANALYZE
INSERT INTO articles2_gist (
    n,
    id,
    title,
    publication,
    author,
    article_date,
    year,
    month,
    url,
    content,
    full_text_idx
)
SELECT
    910000 + gs AS n,
    910000 + gs AS id,
    'Synthetic GIN Article ' || gs || ' about neural retrieval, quantum finance and climate risk' AS title,
    'Synthetic News Lab' AS publication,
    'Generated Author' AS author,
    DATE '2026-05-29' AS article_date,
    2026 AS year,
    5 AS month,
    'https://synthetic.example.com/gist-test-' || gs AS url,
    'This synthetic document contains complex terms about artificial intelligence, information retrieval, vector databases, quantum computing, financial markets, cybersecurity, climate policy, renewable energy, ranking algorithms, PostgreSQL indexing, full text search, GIN indexes, GiST indexes and large scale search systems.' AS content,
    setweight(to_tsvector('english', 'Synthetic GIN Article ' || gs || ' about neural retrieval, quantum finance and climate risk'), 'A') ||
    setweight(to_tsvector('english', 'This synthetic document contains complex terms about artificial intelligence, information retrieval, vector databases, quantum computing, financial markets, cybersecurity, climate policy, renewable energy, ranking algorithms, PostgreSQL indexing, full text search, GIN indexes, GiST indexes and large scale search systems.'), 'B') AS full_text_idx
FROM generate_series(1, 100) AS gs;



--Consultas de búsquedas textuales

--GIN 

--1
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'trump & health')) AS rank
FROM articles2
WHERE full_text_idx @@ to_tsquery('english', 'trump & health')
ORDER BY rank DESC
LIMIT 100;


--2
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'police & crime | violence')) AS rank
FROM articles2
WHERE full_text_idx @@ to_tsquery('english', 'police & crime | violence')
ORDER BY rank DESC
LIMIT 100;


--3
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'technology | artificial & intelligence | data')) AS rank
FROM articles2
WHERE full_text_idx @@ to_tsquery('english', 'technology | artificial & intelligence | data')
ORDER BY rank DESC
LIMIT 100;

--GIST

--1
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'trump & health')) AS rank
FROM articles2_gist
WHERE full_text_idx @@ to_tsquery('english', 'trump & health')
ORDER BY rank DESC
LIMIT 100;


--2
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'police & crime | violence')) AS rank
FROM articles2_gist
WHERE full_text_idx @@ to_tsquery('english', 'police & crime | violence')
ORDER BY rank DESC
LIMIT 100;


--3
EXPLAIN ANALYZE
SELECT
    id,
    title,
    publication,
    author,
    ts_rank(full_text_idx, to_tsquery('english', 'technology | artificial & intelligence | data')) AS rank
FROM articles2_gist
WHERE full_text_idx @@ to_tsquery('english', 'technology | artificial & intelligence | data')
ORDER BY rank DESC
LIMIT 100;


--comparacion de tamaños

SELECT
    'GIN' AS tipo_indice,
    pg_size_pretty(pg_relation_size('articles2_gin_idx')) AS tamaño_indice
UNION ALL
SELECT
    'GiST' AS tipo_indice,
    pg_size_pretty(pg_relation_size('articles2_gist_idx')) AS tamaño_indice;
