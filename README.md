# Proyecto: Adventure Works
Este es un proyecto personal de práctica de análisis de datos del DW: AdventureWorks.


## Descripción
El objetivo es analizar los datos y obtener información detallada de las ventas, productos, clientes, empleados y revendedores, de la empresa ficticia *AdventureWorks*. Y así facilitar la toma de decisiones basadas en datos.
Se incluyen consultas de *SQL* para manipular y extraer datos, así como un tablero de *Power BI* que permite visualizar y analizar KPIs, gráficos, relaciones, etc.
1. **Consultas SQL**: Scripts que extraen, transforman y cargan los datos necesarios desde la base de datos.

2. **Tablero en Power BI**: Un informe interactivo que incluye visualizaciones de ventas, productos y clientes.


## Uso
El tablero de Power BI presenta visualizaciones como:
- **KPIs o Tarjetas** que muestran ingresos totales,ingreso promedio, unidades vendidas, cantidad de clientes, total de productos vendidos, etc.
- **Gráficos** que relacionan la cantidad de ventas y los montos de ventas con los productos y los clientes, o la evolución de las cantidad de ventas a lo largo de los años, etc.
- **Mapas** que muestran las regiones con mayor cantidad de ventas y de ingresos.
- **Gráficos de anillos** para visualizar cuáles son las categorías de productos que mas venden, la cantidad de productos por categoria, que género de cliente es predominante en el negocio, etc.

## Consultas SQL
El archivo `Consultas DW AdventureWorks.sql` contiene una serie de consultas SQL que permiten analizar los datos desde la base de datos. 
Algunas de las consultas son:
- *Consultas básicas*,
- *Consultas sobre ventas*, 
- *Consultas sobre productos*,
- *Consultas sobre clientes*,
- *etc.*

### Ejemplo de uso de consultas:
A continuación, se presentan algunas consultas SQL de ejemplo utilizadas en el análisis de AdventureWorks.
```sql
-- Cantidad de Ventas de Intenet por Región.
SELECT t.SalesTerritoryRegion AS Región, t.SalesTerritoryCountry AS Pais, SUM(s.OrderQuantity) AS Cantidad_Ventas_Internet
FROM FactInternetSales s
JOIN DimSalesTerritory t ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion, t.SalesTerritoryCountry
ORDER BY Cantidad_Ventas_Internet DESC;
```
```sql
-- Nombres y Apellidos de los clientes que realizaron las ventas de internet cuya orden fue realizada en Enero 2011.
SELECT  c.FirstName AS 'Nombre', c.LastName AS 'Apellido',s.CustomerKey AS 'Clave de Cliente', s.ProductKey AS 'ClavedeProducto', s.SalesOrderNumber AS 'NumerodeVenta', s.UnitPrice AS 'Precio', s.OrderDate AS 'Fecha'
FROM DimCustomer c
INNER JOIN FactInternetSales s
ON c.CustomerKey = s.CustomerKey
WHERE OrderDate >= '2011-01-01' 
AND OrderDate < '2011-02-01';
```
```sql
-- Ventas de productos que contienen 'Red' en su nombre, y que fueron realizadas en Estados Unidos en 2012.
SELECT p.ProductKey, p.EnglishProductName, t.SalesTerritoryCountry, v.OrderDate
FROM DimProduct p
INNER JOIN FactInternetSales v ON p.ProductKey = v.ProductKey
INNER JOIN DimSalesTerritory t ON v.SalesTerritoryKey = t.SalesTerritoryKey
WHERE p.EnglishProductName LIKE '%Red%'
  AND t.SalesTerritoryCountry = 'United States'
  AND v.OrderDate BETWEEN '2012-01-01' AND '2012-12-31';
```
```sql
--  Crecimiento de Ventas por Año.
SELECT dt.CalendarYear AS Año, SUM(s.OrderQuantity) AS Cantidad_Ventas,
       LAG(SUM(s.OrderQuantity)) OVER (ORDER BY dt.CalendarYear) AS Ventas_Año_Anterior,
       (SUM(s.OrderQuantity) - LAG(SUM(s.OrderQuantity)) OVER (ORDER BY dt.CalendarYear)) / 
       LAG(SUM(s.OrderQuantity)) OVER (ORDER BY dt.CalendarYear) * 100 AS Crecimiento
FROM FactInternetSales s
JOIN DimDate dt ON s.OrderDateKey = dt.DateKey
GROUP BY dt.CalendarYear
ORDER BY dt.CalendarYear;
```


## Contenido del Repositorio
- 📁 **Consultas SQL**: `Consultas DW AdventureWorks.sql` 
- 📊 **Reporte de Power BI**: `AdventureWorks.pbix` - Archivo del tablero de Power BI, e imagenes JPG de las diapositivas del tablero.
- 📄 **README.md**: Documentación del proyecto.


## Instalación
1. Clonar el repositorio:
    ```bash
    git clone https://github.com/agustinatorremorell/AdventureWorks.git
    ```
2. Entrar al directorio del proyecto:
    ```bash
    cd AdventureWorks
    ```
3. *Power BI*:
   - Abrir el archivo `AdventureWorks.pbix` en **Power BI** para ver el tablero interactivo. (Asegúrate de tener los datos de ventas y productos cargados en el mismo formato que se encuentra en el repositorio).
4. *Base de datos*:
   - Descargar e instalar AdventureWorks: [AdventureWorks Database on GitHub](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks) (en mi caso utilicé la versión AdventureWorks2019)
   - Restaurar la base de datos en SQL Server: Abrir SQL Server Management Studio (SSMS) y seguir estos pasos:
        - Hacé click derecho en "Bases de datos" y selecciona "Restaurar base de datos".
        - En la sección "Origen" elegí la opción "Dispositivo" y selecciona el archivo `.bak` descargado.
        - Haz clic en "Aceptar" y espera a que la restauración se complete.
   - Una vez instalada la base de datos ya podes ejecutar los scripts de `Consultas DW AdventureWorks.sql`.
 💡 **Nota:** Si tienes problemas al restaurar la base de datos en SQL Server, asegúrate de que tu usuario tiene permisos suficientes y que el archivo `.bak` está ubicado en un directorio accesible (ejemplo: `C:\backups`).
