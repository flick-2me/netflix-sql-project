-- Create and switch to the database
CREATE DATABASE netflix_db1;
GO

USE netflix_db1;
GO

-- ==========================================
-- Netflix Data Analysis Project
-- ==========================================

CREATE TABLE dbo.netflix 
(
    show_id       VARCHAR(6),
    [type]        VARCHAR(10),
    title         VARCHAR(150),
    director      VARCHAR(208),
    [cast]        VARCHAR(1000),
    country       VARCHAR(150),
    date_added    VARCHAR(100),
    release_year  INT,
    rating        VARCHAR(10),
    duration      VARCHAR(15),
    listed_in     VARCHAR(25),
    description   VARCHAR(250)
);
GO

SELECT * FROM dbo.netflix;

SELECT DISTINCT [type] 
FROM dbo.netflix;

-- ==========================================
-- 1. Count the number of Movies vs TV Shows
-- ==========================================
SELECT 
    [type], 
    COUNT(*) AS total_count  
FROM dbo.netflix 
GROUP BY [type];

-- ==========================================
-- 2. Find the most common rating for movies and TV shows
-- ==========================================
WITH RankedRatings AS (
    SELECT 
        [type], 
        rating, 
        COUNT(*) AS total_number,
        DENSE_RANK() OVER (PARTITION BY [type] ORDER BY COUNT(*) DESC) AS rank_order
    FROM dbo.netflix 
    GROUP BY [type], rating
)
SELECT 
    [type], 
    rating, 
    total_number 
FROM RankedRatings 
WHERE rank_order = 1;

-- ==========================================
-- 3. List all movies released in a specific year (e.g., 2020)
-- ==========================================
SELECT title 
FROM dbo.netflix 
WHERE [type] = 'Movie' 
  AND release_year = 2020;

-- ==========================================
-- 4. Find the top 5 countries with the most content on Netflix
-- ==========================================
SELECT TOP 5 
    TRIM(value) AS country_name, 
    COUNT(*) AS total_content
FROM dbo.netflix
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC;

-- ==========================================
-- 5. Identify the longest movie
-- ==========================================
SELECT 
    title,
    duration,
    CAST(REPLACE(duration, ' min', '') AS INT) AS duration_minutes
FROM dbo.netflix 
WHERE [type] = 'Movie' 
  AND duration IS NOT NULL
ORDER BY duration_minutes DESC;

-- ==========================================
-- 6. Find content added in the last 5 years
-- ==========================================
SELECT * FROM dbo.netflix 
WHERE TRY_CAST(TRIM(date_added) AS DATE) >= DATEADD(year, -5, GETDATE());

-- ==========================================
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
-- ==========================================
SELECT title 
FROM dbo.netflix 
WHERE director LIKE '%Rajiv Chilaka%';

-- ==========================================
-- 8. List all TV shows with more than 5 seasons
-- ==========================================
SELECT 
    [type], 
    title 
FROM dbo.netflix 
WHERE [type] = 'TV Show' 
  AND TRY_CAST(REPLACE(duration, ' Seasons', '') AS INT) > 5;

-- ==========================================
-- 9. Count the number of content items in each genre
-- ==========================================
SELECT 
    TRIM(value) AS genre, 
    COUNT(*) AS total_items
FROM dbo.netflix 
CROSS APPLY STRING_SPLIT(listed_in, ',') 
GROUP BY TRIM(value);

-- ==========================================
-- 10. Find each year and the average numbers of content release in India on netflix
-- ==========================================
SELECT 
    YEAR(date_added) AS release_year, 
    COUNT(*) AS yearly_count, 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM dbo.netflix WHERE country LIKE '%india%') AS percentage_of_india_total
FROM dbo.netflix 
WHERE YEAR(date_added) IS NOT NULL 
  AND country LIKE '%india%'
GROUP BY YEAR(date_added)
ORDER BY yearly_count DESC;

-- ==========================================
-- 11. List all movies that are documentaries
-- ==========================================
SELECT title 
FROM dbo.netflix 
WHERE [type] = 'Movie' 
  AND listed_in LIKE '%documentaries%';

-- ==========================================
-- 12. Find all content without a director
-- ==========================================
SELECT COUNT(*) AS total_missing_directors
FROM dbo.netflix 
WHERE director IS NULL;

-- ==========================================
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years
-- ==========================================
SELECT * FROM dbo.netflix 
WHERE [type] = 'Movie' 
  AND [cast] LIKE '%Salman Khan%' 
  AND CAST(release_year AS INT) >= YEAR(DATEADD(year, -15, GETDATE()));

-- ==========================================
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
-- ==========================================
SELECT TOP 10
    TRIM(value) AS actor_name, 
    COUNT(*) AS total_appearances  
FROM dbo.netflix 
CROSS APPLY STRING_SPLIT([cast], ',') 
WHERE country LIKE '%india%' 
  AND [cast] IS NOT NULL
  AND TRIM(value) <> ''
GROUP BY TRIM(value)  
ORDER BY total_appearances DESC;

-- ==========================================
-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence'
--     in the description field. Label content containing these keywords as 'Bad' and 
--     all other content as 'Good'. Count how many items fall into each category.
-- ==========================================
WITH CategorizedContent AS (
    SELECT 
        [type],
        title,
        description,
        CASE 
            WHEN description LIKE '%KILL%' 
              OR description LIKE '%VIOLENCE%' THEN 'BAD'  
            ELSE 'GOOD' 
        END AS content_rating
    FROM dbo.netflix
)
SELECT 
    content_rating, 
    COUNT(*) AS total_titles
FROM CategorizedContent
GROUP BY content_rating
ORDER BY total_titles DESC;

