
--done V 1----------------------------------------------------------------------------- done V 1-------------
WITH YearlyData
AS (
	SELECT YEAR(O.OrderDate) AS 'Year', 
       SUM(OL.UnitPrice * OL.Quantity) AS 'IncomePerYear',
       COUNT(DISTINCT MONTH(O.OrderDate)) AS 'NumOfDistinctMonths'
	FROM Sales.Orders O
	INNER JOIN Sales.OrderLines OL ON O.OrderID = OL.OrderID
	JOIN Sales.Invoices I ON I.OrderID = O.OrderID
	GROUP BY YEAR(O.OrderDate)
),
YearlyLinearIncome AS (
    SELECT
        Year,
        IncomePerYear,
        NumOfDistinctMonths,
        (IncomePerYear / NumOfDistinctMonths) * 12 AS YearlyLinearIncome -- חישוב ההכנסה הלינארית
    FROM YearlyData
),
YearlyGrowth AS (
    SELECT
        Year,
        IncomePerYear,
        NumOfDistinctMonths,
        YearlyLinearIncome,
        LAG(YearlyLinearIncome) OVER (ORDER BY Year) AS PreviousYearLinearIncome -- הכנסה לינארית לשנה הקודמת
    FROM YearlyLinearIncome
)
SELECT
    Year,
    FORMAT(IncomePerYear, 'N0') AS IncomePerYear, 
    NumOfDistinctMonths,
    FORMAT(YearlyLinearIncome, 'N0') AS YearlyLinearIncome,
CASE 
    WHEN PreviousYearLinearIncome IS NULL THEN NULL
	ELSE ( FORMAT(((YearlyLinearIncome - PreviousYearLinearIncome) * 100.0) / PreviousYearLinearIncome,'N2')) 
    END AS GrowthRate --  שיעור הצמיחה
FROM YearlyGrowth
ORDER BY Year

--done V 2--------------------------------------------------------------------------------------
WITH RankedCustomers AS (
    SELECT
        YEAR(O.OrderDate) AS SalesYear,  -- שנה
        DATEPART(QUARTER, O.OrderDate) AS SalesQuarter,  -- רבעון
        C.CustomerName,  -- שם הלקוח
        SUM(IL.UnitPrice * IL.Quantity) AS IncomePerYear,  -- הכנסה נטו
        DENSE_RANK() OVER (PARTITION BY YEAR(O.OrderDate), DATEPART(QUARTER, O.OrderDate) ORDER BY SUM(IL.UnitPrice * IL.Quantity) DESC) AS RankOrder  -- דירוג
    FROM Sales.Orders O
    INNER JOIN Sales.Customers C ON O.CustomerID = C.CustomerID
	INNER JOIN Sales.invoices inv ON O.orderID= inv.orderID
	INNER JOIN sales.invoicelines IL ON inv.invoiceID= IL.invoiceID

    GROUP BY YEAR(O.OrderDate), DATEPART(QUARTER, O.OrderDate), C.CustomerName
)
SELECT
    SalesYear,
    SalesQuarter,
    CustomerName,
    IncomePerYear,
    RankOrder AS DNR  
FROM RankedCustomers
WHERE RankOrder <= 5  -- חמשת הלקוחות המובילים בכל רבעון
ORDER BY SalesYear, SalesQuarter, RankOrder


---done V3--3--------------------------------------------------------------------------
-- עשרת המוצרים שהניבו את הרווח הכולל הגבוה ביותר על בסיס השורות שנמכרו
--דרג את המוצרים לפי הרווח הכולל ושליפה של מזהה הפריט, שם הפריט,
--והרווח הכולל שלהם

SELECT TOP 10
	SI.StockItemID, 
	SI.StockItemName, 
	SUM(IL.ExtendedPrice - IL.TaxAmount) AS TotalProfit  
FROM Sales.InvoiceLines IL
JOIN 
			Warehouse.StockItems SI ON IL.StockItemID = SI.StockItemID
GROUP BY 
	SI.StockItemID, 
	SI.StockItemName
ORDER BY 
	TotalProfit DESC


--done v4---------4---------------------------------------------------------------------------
--פריטי המלאי שתוקפם עדיין בתוקף,תחשב את הרווח
--הנומינלי של כל פריט )ההפרש בין המחיר המומלץ לצרכן למחיר ליחידה(, ותדרג את הפריטים לפי
--הרווח הנומינלי בסדר יורד. הציגו גם את המספר הסידורי של כל פריט בסדר זה.

WITH NominalProfits
AS	(SELECT 
			StockItemID, StockItemName,unitprice,RecommendedRetailPrice
			,(RecommendedRetailPrice-unitprice) AS NominalProductProfit  -- רווח נומינלי
	 FROM warehouse.StockItems 
	 WHERE GETDATE() BETWEEN ValidFrom AND ValidTo -
)

SELECT 
ROW_NUMBER() OVER (ORDER BY RecommendedRetailPrice DESC) AS RN 
,StockItemID, StockItemName,unitprice,RecommendedRetailPrice,NominalProductProfit,
DENSE_RANK() OVER (order by NominalProductProfit DESC) AS DNR -- דירוג לפי רווח נומינלי בסדר יורד

FROM
	NominalProfits
Order BY  RN
---------------------------------------------------------------------------

--שאילתה המציגה עבור כל קוד ספק ושם ספק את רשימת המוצרים במלאי עבור אותו
--ספק, כשהרשימה מופרדת באמצעות ' , / '. יש לכלול בפרטי המוצר את קוד המוצר ושם המוצר ממלאי
--המוצרים.
--5 done v5 ----------------------------------------------------------------------------
SELECT 
CONCAT (S.SupplierID,' - ', S.SupplierName) AS SupplierDetails,
STRING_AGG(CONCAT(SI.StockItemID,' ', SI.StockItemName), ' , / ') AS ProductDetails
FROM 
    purchasing.Suppliers S
JOIN 
    warehouse.StockItems SI ON S.SupplierID = SI.SupplierID 
GROUP BY 
		S.SupplierID, S.SupplierName
ORDER BY
		S.SupplierID

-----------------------------------------------------------------------------
--done v6------6---------------------------------------------------------------------

SELECT TOP 5
c.CustomerID
,city.CityName
,country.CountryName 
,country.Continent
,country.region
,FORMAT(SUM(IL.ExtendedPrice),'N2') AS TotalExtendedPrice


FROM Sales.Customers C

JOIN application.cities city ON c.deliverycityID = city.cityID --חיבור עיר 
JOIN application.StateProvinces SP ON city.StateProvinceID = SP.StateProvinceID -- חיבור למדינה  
JOIN application.countries Country ON SP.countryID = Country.countryID -- חיבור מדינה ויבשת
JOIN Sales.Orders orders ON C.CustomerID = orders.CustomerID -- חיבור הזמנות לפי מס לקוח
JOIN Sales.Invoices invoice ON  Orders.OrderID= invoice.OrderID -- חיבור חשבוניות להזמנות
JOIN Sales.InvoiceLines IL ON invoice.invoiceID = IL.InvoiceID -- חישוב הוצאה טוטאלי

GROUP BY 
        C.CustomerID, City.CityName, Country.CountryName, Country.Continent, Country.Region

ORDER BY 
		SUM(IL.ExtendedPrice) DESC


--7 DoneV----------------------------------------------------------------------------------------------------------------------
WITH MonthlyData AS (
SELECT 
        YEAR(O.OrderDate) AS OrderYear,
        MONTH(O.OrderDate) AS OrderMonth,
        SUM(OL.pickedQuantity * OL.UnitPrice) AS MonthlyTotal
FROM 
        Sales.Orders AS O
JOIN 
        Sales.OrderLines AS OL ON O.OrderID = OL.OrderID
GROUP BY 
        YEAR(O.OrderDate), MONTH(O.OrderDate)
),
CumulativeData AS (
SELECT 
        OrderYear,
        OrderMonth,
        MonthlyTotal,
        SUM(MonthlyTotal) OVER (PARTITION BY OrderYear ORDER BY OrderMonth) AS CumulativeTotal
FROM 
        MonthlyData
),

FinalData AS (
SELECT 
        OrderYear,
        OrderMonth,
        MonthlyTotal,
        CumulativeTotal

FROM  CumulativeData

UNION ALL

SELECT 
        OrderYear,
        13 AS OrderMonth, -- שורת סיכום תופיע לאחר 12 החודשים
         SUM(MonthlyTotal) AS MonthlyTotal,
         SUM(MonthlyTotal) AS CumulativeTotal
FROM 
        MonthlyData
GROUP BY 
        OrderYear
)

SELECT 
    OrderYear,
CASE 
    WHEN OrderMonth = 13 THEN 'GrandTotal'
    ELSE CAST(OrderMonth AS VARCHAR)
    END AS OrderMonth,
    FORMAT(MonthlyTotal,'N0') AS MonthlyTotal ,
    FORMAT(CumulativeTotal,'N0') AS CumulativeTotal
FROM 
    FinalData
ORDER BY 
    OrderYear

--הציגו באמצעות מטריצה את מספר ההזמנות שנעשו בכל חודש בשנה
--8--------------------------------------------------------------------
-----------------------------------------------------------------------------------------
WITH OrdersPerMonth AS (
    SELECT
        YEAR(OrderDate) AS OrderYear,     
        MONTH(OrderDate) AS OrderMonth,  
        COUNT(OrderID) AS OrderCount     
    FROM 
        Sales.Orders
    GROUP BY 
        YEAR(OrderDate), MONTH(OrderDate)
)
SELECT 
    OrderMonth,                          
    ISNULL([2013], 0) AS [2013],      
    ISNULL([2014], 0) AS [2014],      
    ISNULL([2015], 0) AS [2015],      
    ISNULL([2016], 0) AS [2016]       
FROM 
    OrdersPerMonth
PIVOT (
    SUM(OrderCount)                     
    FOR OrderYear IN ([2013], [2014], [2015], [2016]) 
) AS PivotTable
ORDER BY 
    OrderMonth  

------------------------------------------------------------------------------------
--זהו לקוחות פוטנציאליים לנטישה על סמך דפוסי ההזמנות שלהם. לקוח נחשב כ"פוטנציאל
--לנטישה" אם הזמן שחלף מאז ההזמנה האחרונה שלו גדול מפי שניים מהזמן הממוצע בין ההזמנות
--שלו. הציגו עבור כל לקוח את מזהה הלקוח, שם הלקוח, תאריך ההזמנה האחרונה, מספר הימים
--שחלפו מאז ההזמנה האחרונה, הזמן הממוצע בין ההזמנות )בימים(, וסטטוס הלקוח )"פוטנציאל
--לנטישה" או "פעיל"(.
--9-done v-----------------------------------------------------------------------------
WITH T AS (
    SELECT 
        C.CustomerID,
        C.CustomerName,
        O.OrderDate,
        MAX(O.OrderDate) OVER (PARTITION BY C.CustomerID) AS LastOrder,
        LAG(O.OrderDate, 1) OVER (PARTITION BY C.CustomerID ORDER BY O.OrderDate) AS PreviousOrderDate,
        DATEDIFF(DAY, LAG(O.OrderDate, 1) OVER (PARTITION BY C.CustomerID ORDER BY O.OrderDate), O.OrderDate) AS DaysSinceLastOrder1
    FROM Sales.Orders O
    JOIN Sales.Customers C
        ON O.CustomerID = C.CustomerID
)
SELECT 
    T.CustomerID,
    T.CustomerName,
    T.OrderDate,
    T.PreviousOrderDate,
    DATEDIFF(DAY, LastOrder, '2016-05-31') AS DaysSinceLastOrder,
    AVG(DATEDIFF(DAY, PreviousOrderDate, OrderDate)) OVER (PARTITION BY CustomerID) AS AvgDaysBetweenOrders,
    IIF(
        AVG(DATEDIFF(DAY, PreviousOrderDate, OrderDate)) OVER (PARTITION BY CustomerID) * 2 > DATEDIFF(DAY, LastOrder, '2016-05-31'),
        'Active',
        'Potential churn'
    ) AS CustomerStatus
FROM T

--10--done v-------------------------------------------------------
WITH CategorizedCustomers AS (
    
	SELECT
	CASE
            WHEN CustomerName LIKE 'Wingtip%' THEN 'Wingtip Customers'
            WHEN CustomerName LIKE 'Tailspin%' THEN 'Tailspin Customers'
            ELSE CustomerName
		    END AS GeneralizedCustomerName,
            cc.CustomerCategoryName AS CustomerCategoryName
	FROM Sales.Customers c
	JOIN Sales.CustomerCategories cc
    ON c.CustomerCategoryID = cc.CustomerCategoryID
),
CategoryCustomerCount AS (
    SELECT
        CustomerCategoryName,
        COUNT(DISTINCT GeneralizedCustomerName) AS CustomerCount
    FROM CategorizedCustomers
    GROUP BY CustomerCategoryName
),
TotalCustomers AS (
    SELECT
        SUM(CustomerCOUNT) AS TotalCustCount
    FROM CategoryCustomerCount
)
SELECT
    c.CustomerCategoryName,
    c.CustomerCount,
    t.TotalCustCount,
    CONCAT(ROUND(CAST(c.CustomerCount AS FLOAT) / t.TotalCustCount * 100, 2),'%') AS DistributionFactor
FROM CategoryCustomerCount c
CROSS JOIN TotalCustomers t
ORDER BY  CustomerCategoryName
