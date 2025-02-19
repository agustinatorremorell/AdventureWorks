		-- Agustina Torremorell - Ejercicios de práctica SQL --
		-- Base de datos: AdventureWorks --

USE AdventureWorksDW2019


										-- Consultas Básicas --

-- Selección básica.
SELECT
	FirstName,
	LastName,
	EmployeeKey
FROM DimEmployee

-- Filtrado con WHERE.
SELECT
	FirstName,
	LastName,
	EmployeeKey
FROM DimEmployee
WHERE LastName = 'Smith'

-- Ordenar resultados.
SELECT
	FirstName,
	LastName,
	EmployeeKey
FROM DimEmployee
ORDER BY LastName ASC;

-- Uso de JOIN.
SELECT
	FirstName AS 'Nombre',
	LastName AS 'Apellido',
	DepartmentName AS 'Nombre Departamento',
	ST.SalesTerritoryKey
FROM DimEmployee AS E
INNER JOIN DimSalesTerritory ST
	ON ST.SalesTerritoryKey = E.SalesTerritoryKey

--Agregación con COUNT.
SELECT 
	FRS.EmployeeKey,
	E.FirstName,
	E.LastName,
	COUNT(OrderQuantity) AS CantidadOrdenes
FROM FactResellerSales AS FRS
LEFT JOIN DimEmployee AS E
	 ON FRS.EmployeeKey=E.EmployeeKey
GROUP BY FRS.EmployeeKey, E.FirstName, E.LastName
ORDER BY CantidadOrdenes ASC;


-- Creación de una tabla bridge entre DimDepartmentGroup y DimEmployee para generar una clave basada en DepartmentName y utilizarla como tabla intermedia en un JOIN que relacione las tres tablas.

	-- Creación de la tabla bridge.
CREATE TABLE TablaBridge_DepartmentGroupEmployee (
    BridgeKey INT IDENTITY(1,1) PRIMARY KEY, 
    DepartmentGroupKey INT NOT NULL, 
    EmployeeKey INT NOT NULL,
    DepartmentGroupName NVARCHAR(255),
    FOREIGN KEY (DepartmentGroupKey) REFERENCES DimDepartmentGroup(DepartmentGroupKey),
    FOREIGN KEY (EmployeeKey) REFERENCES DimEmployee(EmployeeKey)
);
INSERT INTO TablaBridge_DepartmentGroupEmployee (DepartmentGroupKey, EmployeeKey)
SELECT D.DepartmentGroupKey, E.EmployeeKey
FROM DimEmployee E
JOIN DimDepartmentGroup D 
ON E.EmployeeKey = D.DepartmentGroupKey;
	-- JOIN entre las 3 tablas.
SELECT D.DepartmentGroupName, E.EmployeeKey, E.FirstName, E.LastName
FROM DimDepartmentGroup D
JOIN TablaBridge_DepartmentGroupEmployee B ON D.DepartmentGroupKey = B.DepartmentGroupKey
JOIN DimEmployee E ON B.EmployeeKey = E.EmployeeKey;


										-- Ventas --

-- Total de Ventas por Año (Resellers).
SELECT YEAR(OrderDate) AS Año, SUM(OrderQuantity) AS Total_Ventas_Anuales
FROM FactResellerSales
GROUP BY YEAR(OrderDate)
ORDER BY Año;

-- Cantidad de Ventas de Intenet por Región.
SELECT t.SalesTerritoryRegion AS Región, t.SalesTerritoryCountry AS Pais, SUM(s.OrderQuantity) AS Cantidad_Ventas_Internet
FROM FactInternetSales s
JOIN DimSalesTerritory t ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion, t.SalesTerritoryCountry
ORDER BY Cantidad_Ventas_Internet DESC;

-- Monto de Ventas de Revendedores por Región.
SELECT t.SalesTerritoryRegion AS Región, t.SalesTerritoryCountry AS Pais, SUM(s.SalesAmount) AS Monto_Total_Revendedores
FROM FactResellerSales s
JOIN DimSalesTerritory t ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion, t.SalesTerritoryCountry
ORDER BY Monto_Total_Revendedores DESC;

-- Ventas por Cliente (Internet).
SELECT c.CustomerKey, c.FirstName, c.LastName, SUM(s.OrderQuantity) AS Cantidad_Ventas
FROM FactInternetSales s
JOIN DimCustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, c.FirstName, c.LastName
ORDER BY Cantidad_Ventas DESC;

-- Top 5 Productos Más Vendidos (Resellers).
SELECT TOP 5 p.EnglishProductName, SUM(s.OrderQuantity) AS CantidadVendida
FROM FactResellerSales s
JOIN DimProduct p ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY CantidadVendida DESC;

-- Ventas de internet cuya orden fue realizada en Enero 2011 (FactInternetSales).
SELECT *    
FROM FactInternetSales
WHERE OrderDate BETWEEN '2011-01-01' AND '2011-01-31';

-- Ventas de Internet cuyo precio unitario sea mayor 3500.
SELECT *  
FROM FactInternetSales
WHERE UnitPrice >= 3500

-- Eliminar todas las ventas de Internet cuyo importe total sea inferior a $100.
DELETE FROM FactInternetSales
WHERE SalesAmount < 100;

-- Ventas realizadas en Pesos Argentinos.
SELECT p.ProductKey, p.EnglishProductName, c.CurrencyID
FROM DimProduct p
INNER JOIN NewFactCurrencyRate c
ON p.ProductKey = c.CurrencyKey
WHERE c.CurrencyID = 'ARS'

-- Ventas realizadas en Dólares Norteamericanos.
SELECT p.ProductKey, p.EnglishProductName, c.CurrencyID
FROM DimProduct p
INNER JOIN NewFactCurrencyRate c
ON p.ProductKey = c.CurrencyKey
WHERE c.CurrencyID = 'USD'


										-- Clientes --

-- Nombres y Apellidos de los clientes que realizaron las ventas de internet cuya orden fue realizada en Enero 2011.
SELECT  c.FirstName AS 'Nombre', c.LastName AS 'Apellido',s.CustomerKey AS 'Clave de Cliente', s.ProductKey AS 'ClavedeProducto', s.SalesOrderNumber AS 'NumerodeVenta', s.UnitPrice AS 'Precio', s.OrderDate AS 'Fecha'
FROM DimCustomer c
INNER JOIN FactInternetSales s
ON c.CustomerKey = s.CustomerKey
WHERE OrderDate >= '2011-01-01' 
AND OrderDate < '2011-02-01';

-- Nombres y Apellidos de los clientes que NO hayan realizado una compra en Enero 2011.
SELECT  c.FirstName AS 'Nombre', c.LastName AS 'Apellido',s.CustomerKey AS 'Clave de Cliente'
FROM DimCustomer c
INNER JOIN FactInternetSales s
ON c.CustomerKey = s.CustomerKey
WHERE c.CustomerKey NOT IN (
    SELECT CustomerKey
    FROM FactInternetSales
    WHERE OrderDate BETWEEN '2011-01-01' AND '2011-01-31'
)

-- Cantidad de Clientes por País.
SELECT g.EnglishCountryRegionName, COUNT(c.CustomerKey) AS Cantidad_Clientes
FROM DimCustomer c
JOIN DimGeography g ON c.GeographyKey = g.GeographyKey
GROUP BY g.EnglishCountryRegionName
ORDER BY Cantidad_Clientes DESC;

-- Clientes con mayor cantidad de compras.
SELECT TOP 10 c.FirstName, c.LastName, SUM(s.OrderQuantity) AS CantidadCompras
FROM FactInternetSales s
JOIN DimCustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY c.FirstName, c.LastName
ORDER BY CantidadCompras DESC;

-- Clientes que generaron mayores ingresos.
SELECT TOP 10 c.FirstName, c.LastName, SUM(s.SalesAmount) AS MontoTotalVentas
FROM FactInternetSales s
JOIN DimCustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY c.FirstName, c.LastName
ORDER BY MontoTotalVentas DESC;

										-- Productos --

-- Actualizar el nombre del producto “Mountain-100 Black, 42” a “Mountain-100 Black Edition” en la tabla DimProduct.
UPDATE DimProduct 
SET EnglishProductName = 'Mountain-100 Black Edition'
WHERE ProductKey = 349;
	-- Comprobación
SELECT ProductKey, EnglishProductName
FROM DimProduct
WHERE ProductKey = 349;

-- Cantidad de productos vendidos en Internet durante el 2011.
SELECT SUM(v.OrderQuantity) AS TotalProductosVendidos
FROM DimProduct p
INNER JOIN FactInternetSales v
ON p.ProductKey = v.ProductKey
WHERE v.OrderDate BETWEEN '2011-01-01' AND '2011-12-31';

-- Productos vendidos en Mayo del 2011.
SELECT p.EnglishProductName, v.OrderDate
FROM DimProduct p
INNER JOIN FactInternetSales v
ON p.ProductKey = v.ProductKey
WHERE v.OrderDate BETWEEN '2011-05-01' AND '2011-05-31';

-- Ventas de productos que contienen 'Red' en su nombre, y que fueron realizadas en Estados Unidos en 2012.
SELECT p.ProductKey, p.EnglishProductName, t.SalesTerritoryCountry, v.OrderDate
FROM DimProduct p
INNER JOIN FactInternetSales v ON p.ProductKey = v.ProductKey
INNER JOIN DimSalesTerritory t ON v.SalesTerritoryKey = t.SalesTerritoryKey
WHERE p.EnglishProductName LIKE '%Red%'
  AND t.SalesTerritoryCountry = 'United States'
  AND v.OrderDate BETWEEN '2012-01-01' AND '2012-12-31';

-- Productos con su Precio Promedio de Venta.
SELECT p.EnglishProductName, AVG(s.UnitPrice) AS Precio_Promedio
FROM FactInternetSales s
JOIN DimProduct p ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Precio_Promedio DESC;

-- Stock Disponible.
SELECT 
    p.EnglishProductName, 
    SUM(i.UnitsBalance) AS Stock
FROM FactProductInventory i
JOIN DimProduct p ON i.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Stock DESC;


										-- Fechas --

-- Ventas por Año y Mes.
SELECT dt.CalendarYear AS Año, dt.EnglishMonthName AS Mes, SUM(s.OrderQuantity) AS Cantidad_Ventas
FROM FactInternetSales s
JOIN DimDate dt ON s.OrderDateKey = dt.DateKey
GROUP BY dt.CalendarYear, dt.EnglishMonthName
ORDER BY dt.CalendarYear;

--  Crecimiento de Ventas por Año.
SELECT dt.CalendarYear AS Año, SUM(s.OrderQuantity) AS Cantidad_Ventas,
       LAG(SUM(s.OrderQuantity)) OVER (ORDER BY dt.CalendarYear) AS Ventas_Año_Anterior,
       (SUM(s.OrderQuantity) - LAG(SUM(s.OrderQuantity)) OVER (ORDER BY dt.CalendarYear)) / 
       LAG(SUM(s.OrderQuantity)) OVER (ORDER BY dt.CalendarYear) * 100 AS Crecimiento
FROM FactInternetSales s
JOIN DimDate dt ON s.OrderDateKey = dt.DateKey
GROUP BY dt.CalendarYear
ORDER BY dt.CalendarYear;


										-- Empleados --

-- Empleados que tienen más de 5 años de antigüedad en la empresa, mostrando nombre, apellido y fecha de inicio.
SELECT FirstName, LastName, StartDate
FROM DimEmployee
WHERE DATEDIFF(YEAR, StartDate, GETDATE()) > 5;

-- Empleados que se encuentren en el departamento de Manufactura y de Aseguramiento de Calidad.
SELECT e.FirstName, e.LastName, d.DepartmentGroupName 
FROM DimEmployee e
INNER JOIN DimDepartmentGroup d
ON e.EmployeeKey = d.ParentDepartmentGroupKey
WHERE (d.DepartmentGroupName IN ('Manufacturing', 'Quality Assurance'))

-- Empleados que se encuentren en el departamento 'Executive General and Administration' y que sean Hombres o se encuentren Solteros.
SELECT e.FirstName, e.LastName, d.DepartmentGroupName 
FROM DimEmployee e
INNER JOIN DimDepartmentGroup d
ON e.EmployeeKey = d.ParentDepartmentGroupKey
WHERE (d.DepartmentGroupName IN ('Executive General and Administration'))
AND (Gender = 'M' OR MaritalStatus = 'S')

-- Empleados cuyo apellido empiece con S o su Nombre termine con A.
SELECT FirstName, LastName, EmployeeKey
FROM DimEmployee
WHERE LastName LIKE 'S%' OR FirstName LIKE '%a'

-- Empleados cuya edad es mayor que 40 (Nombre, Apellido, Sexo, Fecha de Nacimiento, Edad).
SELECT FirstName AS Nombre, 
       LastName AS Apellido, 
       Gender AS Sexo, 
       BirthDate AS FechaNacimiento, 
       DATEDIFF(YEAR, BirthDate, GETDATE()) 
       - CASE 
           WHEN DATEADD(YEAR, DATEDIFF(YEAR, BirthDate, GETDATE()), BirthDate) > GETDATE() 
           THEN 1 
           ELSE 0 
         END AS Edad
FROM DimEmployee
WHERE (DATEDIFF(YEAR, BirthDate, GETDATE()) 
       - CASE 
           WHEN DATEADD(YEAR, DATEDIFF(YEAR, BirthDate, GETDATE()), BirthDate) > GETDATE() 
           THEN 1 
           ELSE 0 
         END) > 40;


										-- Revendedores --

-- Revendedores que han realizado ventas por más de $500,000 en total, y cuyas ventas unitarias promedio (UnitPrice) sean mayores a $500.
SELECT ResellerKey, SUM(TotalProductCost) AS 'Precio de Ventas Total', AVG(UnitPrice) AS 'Precio Unitario Promedio'
FROM FactResellerSales 
GROUP BY ResellerKey
HAVING SUM(TotalProductCost) > 500000
   AND AVG(UnitPrice) > 500;

-- Total vendido por el Reseller "Bike Dealers Association".
SELECT r.ResellerName, SUM(s.SalesAmount) AS TotalVendido
FROM FactResellerSales s
JOIN DimReseller r ON s.ResellerKey = r.ResellerKey
GROUP BY r.ResellerName
HAVING r.ResellerName = 'Bike Dealers Association';

-- Monto vendido por año para el Reseller "Bike Dealers Association".
SELECT YEAR(FRS.OrderDate) AS Año, 
       SUM(FRS.SalesAmount) AS TotalVendido
FROM FactResellerSales FRS
JOIN DimReseller DR ON FRS.ResellerKey = DR.ResellerKey
WHERE DR.ResellerName = 'Bike Dealers Association'
GROUP BY YEAR(FRS.OrderDate)
ORDER BY Año;

-- Top 10 de Productos vendidos por Reseller.
SELECT TOP 10 P.EnglishProductName AS Producto, 
              R.ResellerName AS Reseller, 
              SUM(S.OrderQuantity) AS CantidadVendida
FROM FactResellerSales S
JOIN DimReseller R ON S.ResellerKey = R.ResellerKey
JOIN DimProduct P ON S.ProductKey = P.ProductKey
GROUP BY P.EnglishProductName, R.ResellerName
ORDER BY CantidadVendida DESC;