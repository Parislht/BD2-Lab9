--Crear Tablas
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    body TEXT,
    body_indexed TEXT
);

--Extension para Trigramas
CREATE EXTENSION IF NOT EXISTS pg_trgm;

--Bloque para limpiar registros
TRUNCATE TABLE articles RESTART IDENTITY;

--Inserción de datos aleatorios
INSERT INTO articles (body, body_indexed)
SELECT txt, txt
FROM (
    SELECT md5(random()::text) || ' ' || md5(random()::text) AS txt
    FROM generate_series(1, 10000000)
) AS data;

--Crear índices GIN
CREATE INDEX articles_search_idx 
ON articles 
USING GIN (body_indexed gin_trgm_ops);


--Consulta con EXPLAIN ANALYZE

--Consulta CON indice
EXPLAIN ANALYZE
SELECT count(*) 
FROM articles 
WHERE body_indexed ILIKE '%abc%';

--Consulta SIN indice 
EXPLAIN ANALYZE
SELECT count(*) 
FROM articles 
WHERE body ILIKE '%abc%';
