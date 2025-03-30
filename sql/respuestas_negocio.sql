/*
1. Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500. 

*/

SELECT 
  c.first_name, 
  c.last_name,
  c.birth_date,
  c.email,
  SUM(o.value) AS total_value

FROM 
  `project.schema.customer` AS c

INNER JOIN 
  `project.schema.orders` AS o 
  ON c.customer_id = o.customer_seller_id

WHERE 
  FORMAT_DATE('%m-%d', c.birth_date)  = FORMAT_DATE('%m-%d', CURRENT_DATE())
AND o.created_at BETWEEN '2020-01-01' AND '2020-01-31'

GROUP BY 
  c.first_name, 
  c.last_name,
  c.birth_date,
  c.email

HAVING SUM(o.value) > 1500;

/*
2. Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. 
Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, cantidad 
de productos vendidos y el monto total transaccionado. 
*/

WITH sallers AS (

  SELECT
    EXTRACT(YEAR FROM o.created_at) AS year,
    EXTRACT(MONTH FROM o.created_at) AS month,
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS total_items,
    SUM(o.value) AS total_amount_transacted,
    ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM o.created_at), EXTRACT(MONTH FROM o.created_at) ORDER BY SUM(o.value) DESC) AS ranking
  
  FROM `project.schema.orders` AS o
 
  INNER JOIN `project.schema.customer` AS c 
    ON o.customer_id = c.customer_id

  INNER JOIN `project.schema.item` AS i 
    ON o.item_id = i.item_id

  INNER JOIN `project.schema.category` AS cat 
    ON i.category_id = cat.category_id

  WHERE 
    EXTRACT(YEAR FROM p.created_at) = 2020
  AND cat.category_name = 'Celulares'
  
  GROUP BY 
    EXTRACT(YEAR FROM o.created_at),
    EXTRACT(MONTH FROM o.created_at),
    c.customer_id,
    c.first_name,
    c.last_name

)
SELECT 
  year,
  month,
  customer_id,
  first_name,
  last_name,
  total_orders,
  total_items,
  total_amount_transacted

FROM sallers
WHERE ranking <= 5
ORDER BY 
  year, 
  month, 
  total_amount_transacted DESC;

/*
3. Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. 
Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item, vamos a tener 
únicamente el último estado informado por la PK definida. (Se puede resolver a través de StoredProcedure) 
*/

CREATE TABLE item_status (
    item_id INT64,
    updated_at DATETIME,
    price FLOAT64
    status STRING
    PRIMARY KEY (item_id, data_atualizacao),
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);

CREATE OR REPLACE PROCEDURE `project.schema.prc_update_status`(update_date DATE)
BEGIN

  MERGE `project.schema.item_status` AS target

  USING (
    SELECT
      item_id,
      price,
      status,
      CURRENT_DATE() AS created_at
    FROM
      `project.schema.item`
  ) AS source
    ON target.item_id = source.item_id AND target.created_at = source.created_at
  
  WHEN MATCHED THEN --update item if exists
    UPDATE SET
      target.price = source.price,
      target.status = source.status
  
  WHEN NOT MATCHED THEN --insert new item
    INSERT (item_id, price, status, created_at)
    VALUES (source.item_id, source.price, source.status, source.created_at);

END;

--execute procedure
CALL `project.schema.update_item_status`(CURRENT_DATE());