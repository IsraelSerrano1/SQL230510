--función sin parametro de entrada para devolver el precio máximo
CREATE OR REPLACE FUNCTION precio_maximo()
RETURNS NUMERIC AS $$
DECLARE precio NUMERIC;
	BEGIN
	 SELECT MAX(unit_price) INTO precio FROM products;
	 RETURN precio;
END $$ LANGUAGE 'plpgsql';

SELECT precio_maximo();

--parametro de entrada
--Obtener el numero de ordenes por empleado
CREATE OR REPLACE FUNCTION orders_employee(employeeid NUMERIC)
RETURNS NUMERIC AS $$
DECLARE orders_num NUMERIC;
	BEGIN
		SELECT count(order_id) INTO orders_num from orders where employee_id = employeeid;
		RETURN orders_num;
END $$ LANGUAGE 'plpgsql';

SELECT orders_employee(1);

--Obtener la venta de un empleado con un determinado producto
CREATE OR REPLACE FUNCTION sales(employeeid NUMERIC, productid NUMERIC)
RETURNS NUMERIC AS $$
DECLARE resultado NUMERIC;
	BEGIN
		SELECT SUM(od.quantity) INTO resultado 
		FROM order_details od INNER JOIN orders o on od.order_id = o.order_id
		AND o.employee_id = employeeid AND od.product_id = productid;
		RETURN resultado;
END $$ LANGUAGE 'plpgsql';
SELECT sales(4,1);

--Crear una funcion para devolver una tabla con producto_id, nombre, precio y unidades en strock, 
--debe obtener los productos terminados en n

CREATE OR REPLACE FUNCTION devolucion_tabla()
	RETURNS TABLE(productid SMALLINT, productname character varying, unitprice real, unitsinstock SMALLINT)
	AS $$
	BEGIN
		RETURN QUERY
			SELECT product_id,product_name,unit_price,units_in_stock FROM products where product_name LIKE '%n';
END $$ LANGUAGE 'plpgsql';	
SELECT * FROM devolucion_tabla();

-- Creamos la función contador_ordenes_anio()
--QUE CUENTE LAS ORDENES POR AÑO devuelve una tabla con año y contador
CREATE OR REPLACE FUNCTION contador_ordenes_anio() 
	RETURNS TABLE(anio NUMERIC, cont BIGINT)
	AS $$
	BEGIN
		RETURN QUERY
			SELECT EXTRACT (YEAR FROM order_date) as anio, count (order_id) as cont 
			FROM orders GROUP BY anio;
END $$ LANGUAGE 'plpgsql';
SELECT * FROM contador_ordenes_anio();

--3. Lo mismo que el ejemplo anterior pero con un parametro de entrada que sea el año
CREATE OR REPLACE FUNCTION contador_ordenes_anio_param(anio_param NUMERIC) 
	RETURNS TABLE(anio NUMERIC, cont BIGINT)
	AS $$
	BEGIN
	RETURN QUERY
	 SELECT EXTRACT (YEAR FROM order_date) as anio, count (order_id) as cont 
	 FROM orders where EXTRACT (YEAR FROM order_date) = anio_param GROUP BY anio;
END $$ LANGUAGE 'plpgsql';
SELECT * FROM contador_ordenes_anio_param(1996);	

--4. PROCEDIMIENTO ALMACENADO PARA OBTENER PRECIO PROMEDIO Y SUMA DE 
--UNIDADES EN STOCK POR CATEGORIA

CREATE OR REPLACE FUNCTION obtener(categoria_param INTEGER)
	RETURNS TABLE(categoria SMALLINT, promedio DOUBLE PRECISION, unidades BIGINT)
	AS $$
	BEGIN
	RETURN QUERY
		SELECT category_id, AVG(unit_price), SUM(units_in_stock) FROM products 
		WHERE category_id = categoria_param GROUP BY category_id;
END $$ LANGUAGE 'plpgsql';	
SELECT * FROM obtener(2);
		
