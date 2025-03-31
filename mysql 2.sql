use mydb;

-- Identify drop-off points
SELECT 
    Stage, 
    COUNT(*) AS users, 
    COUNT(*) / (SELECT COUNT(*) FROM journey) * 100 AS percentage
FROM journey
GROUP BY Stage
ORDER BY Stage;

-- First check if purchases exist

SELECT COUNT(*) FROM journey WHERE Action = 'Purchase';

-- Then check if there are events before purchases
SELECT COUNT(*) 
FROM journey j1
JOIN journey j2 ON j1.CustomerID = j2.CustomerID AND j1.ProductID = j2.ProductID
WHERE j2.Action = 'Purchase' AND j1.VisitDate < j2.VisitDate;

-- Average Duration per Stage
SELECT 
    Stage, 
    AVG(Duration) as AvgDuration
FROM journey
WHERE Duration IS NOT NULL
GROUP BY Stage;

-- Highest and Lowest Rated Products

SELECT 
    p.productname, 
    AVG(r.rating) as AvgRating, 
    COUNT(r.reviewid) as ReviewCount
FROM product p
JOIN review r ON p.productid = r.productid
GROUP BY p.productname
ORDER BY AvgRating DESC, ReviewCount DESC;

-- Customer Retention Rate

WITH RepeatCustomers AS (
    SELECT 
        CustomerID, 
        COUNT(DISTINCT journeyid) as Journeys
    FROM journey
    WHERE Action = 'Purchase'
    GROUP BY CustomerID
    HAVING Journeys > 1
)
SELECT 
    (COUNT(DISTINCT rc.CustomerID) * 1.0 / (SELECT COUNT(DISTINCT CustomerID) FROM Journey WHERE Action = 'Purchase')) * 100 as RetentionRate
FROM RepeatCustomers rc;


-- Repeat vs. First-Time Buyers


SELECT 
    BuyerType,
    COUNT(DISTINCT CustomerID) as CustomerCount
FROM (
    SELECT 
        CustomerID,
        CASE 
            WHEN COUNT(DISTINCT journeyid) > 1 THEN 'Repeat'
            ELSE 'First-Time'
        END as BuyerType
    FROM journey
    WHERE Action = 'Purchase'
    GROUP BY CustomerID
) AS CustomerCategories
GROUP BY BuyerType;

-- Best-Performing Products per Region

SELECT 
    g.Country, 
    p.productname, 
    COUNT(j.journeyid) as PurchaseCount
FROM journey j
JOIN customer c ON j.CustomerID = c.customerid
JOIN geography g ON c.geographyid = g.geographyid
JOIN product p ON j.ProductID = p.productid
WHERE j.Action = 'Purchase'
GROUP BY g.Country, p.productname
ORDER BY PurchaseCount DESC;


-- Recommendations

-- Drop-off Points:= High drop-offs at Checkout suggest improving the checkout process (e.g., simplifying forms, offering more payment options).
-- Successful Conversions:= Homepage clicks often lead to purchases—enhance homepage Actions and product visibility.
-- Reviews:= Focus on improving low-rated products  and promote high-rated ones 
-- Retention:= Low retention rates indicate a need for loyalty programs or follow-up campaigns.
-- Regional Performance:= Tailor marketing to promote top products in specific regions.

















