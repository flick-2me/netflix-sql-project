# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/flick-2me/netflix-sql-project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    [type], 
    COUNT(*) AS total_count  
FROM dbo.netflix 
GROUP BY [type];

```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT title 
FROM dbo.netflix 
WHERE [type] = 'Movie' 
  AND release_year = 2020;

```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5 
    TRIM(value) AS country_name, 
    COUNT(*) AS total_content
FROM dbo.netflix
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    title,
    duration,
    CAST(REPLACE(duration, ' min', '') AS INT) AS duration_minutes
FROM dbo.netflix 
WHERE [type] = 'Movie' 
  AND duration IS NOT NULL
ORDER BY duration_minutes DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT * FROM dbo.netflix 
WHERE TRY_CAST(TRIM(date_added) AS DATE) >= DATEADD(year, -5, GETDATE());

```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT title 
FROM dbo.netflix 
WHERE director LIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT 
    [type], 
    title 
FROM dbo.netflix 
WHERE [type] = 'TV Show' 
  AND TRY_CAST(REPLACE(duration, ' Seasons', '') AS INT) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    TRIM(value) AS genre, 
    COUNT(*) AS total_items
FROM dbo.netflix 
CROSS APPLY STRING_SPLIT(listed_in, ',') 
GROUP BY TRIM(value);
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    YEAR(date_added) AS release_year, 
    COUNT(*) AS yearly_count, 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM dbo.netflix WHERE country LIKE '%india%') AS percentage_of_india_total
FROM dbo.netflix 
WHERE YEAR(date_added) IS NOT NULL 
  AND country LIKE '%india%'
GROUP BY YEAR(date_added)
ORDER BY yearly_count DESC;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT title 
FROM dbo.netflix 
WHERE [type] = 'Movie' 
  AND listed_in LIKE '%documentaries%';

```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT COUNT(*) AS total_missing_directors
FROM dbo.netflix 
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * FROM dbo.netflix 
WHERE [type] = 'Movie' 
  AND [cast] LIKE '%Salman Khan%' 
  AND CAST(release_year AS INT) >= YEAR(DATEADD(year, -15, GETDATE()));
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.


