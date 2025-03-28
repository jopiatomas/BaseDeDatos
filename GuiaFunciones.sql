CREATE DATABASE IF NOT EXISTS funcionesJopia;
USE funcionesJopia;

CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    ciudad VARCHAR(50),
    email VARCHAR(50)
);

CREATE TABLE Libros (
    libro_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_libro VARCHAR(100),
    autor VARCHAR(100),
    precio DECIMAL(10, 2)
);

CREATE TABLE Ventas (
    venta_id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    fecha_venta DATE,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

CREATE TABLE Detalle_Venta (
    detalle_venta_id INT PRIMARY KEY AUTO_INCREMENT,
    venta_id INT,
    libro_id INT,
    cantidad INT,
    FOREIGN KEY (venta_id) REFERENCES Ventas(venta_id),
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id)
);

INSERT INTO Clientes (nombre, apellido, ciudad, email)
VALUES 
('Carlos', 'Gomez', 'Madrid', 'carlos.gomez@email.com'),
('Ana', 'Martinez', 'Barcelona', 'ana.martinez@email.com'),
('Juan', 'Lopez', 'Sevilla', 'juan.lopez@email.com'),
('Maria', 'Perez', 'Valencia', 'maria.perez@email.com');

INSERT INTO Libros (nombre_libro, autor, precio)
VALUES
('Cien años de soledad', 'Gabriel García Márquez', 15.99),
('Don Quijote de la Mancha', 'Miguel de Cervantes', 12.50),
('La sombra del viento', 'Carlos Ruiz Zafón', 18.75),
('El código Da Vinci', 'Dan Brown', 20.99),
('Harry Potter y la piedra filosofal', 'J.K. Rowling', 25.00);

INSERT INTO Ventas (cliente_id, fecha_venta)
VALUES
(1, '2025-03-10'),
(2, '2025-03-12'),
(3, '2025-03-15'),
(4, '2025-03-17'),
(1, '2025-03-20'),
(2, '2025-03-22'),
(3, '2025-03-25'),
(4, '2025-03-28'),
(1, '2025-03-30'),
(2, '2025-04-01');

INSERT INTO Detalle_Venta (venta_id, libro_id, cantidad)
VALUES
(1, 1, 2),  -- Carlos compra 2 copias de "Cien años de soledad" (venta 1)
(1, 2, 1),  -- Carlos compra 1 copia de "Don Quijote de la Mancha" (venta 1)
(2, 3, 1),  -- Ana compra 1 copia de "La sombra del viento" (venta 2)
(3, 4, 3),  -- Juan compra 3 copias de "El código Da Vinci" (venta 3)
(4, 5, 2),  -- Maria compra 2 copias de "Harry Potter y la piedra filosofal" (venta 4)
(5, 3, 1),  -- Carlos compra 1 copia de "La sombra del viento" (venta 5)
(6, 4, 2),  -- Ana compra 2 copias de "El código Da Vinci" (venta 6)
(7, 1, 1),  -- Juan compra 1 copia de "Cien años de soledad" (venta 7)
(8, 2, 1),  -- Maria compra 1 copia de "Don Quijote de la Mancha" (venta 8)
(9, 5, 1),  -- Carlos compra 1 copia de "Harry Potter y la piedra filosofal" (venta 9)
(10, 4, 3); -- Ana compra 3 copias de "El código Da Vinci" (venta 10)


-- Ejercicio 1: Obtener el Nombre Completo de un Cliente
-- Ejercicio 2: Obtener el Total Vendido de un Libro
-- Ejercicio 3: Obtener el Cliente que Más Ha Gastado
-- Ejercicio 4: Obtener el Libro Más Vendido en un Año
-- Ejercicio 5: Verificar si un Cliente Comprado un Libro en Particular

-- Ejercicio 1
DELIMITER // 
CREATE FUNCTION devolverNombre(id_cliente INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE v_nombre VARCHAR(50);
    DECLARE v_apellido VARCHAR(50);
	DECLARE nombreCompleto VARCHAR(50);
    
    SELECT nombre, apellido
    INTO v_nombre, v_apellido
    FROM Clientes
    WHERE cliente_id = id_cliente;	

	SET nombreCompleto = CONCAT(v_nombre, ' ', v_apellido)	;
    
    RETURN nombreCompleto;		
END
// DELIMITER ;

SELECT devolverNombre(1); -- Ejercicio 1


-- Ejercicio 2
DELIMITER //
CREATE FUNCTION totalVendido(id_libro INT)
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC
BEGIN
	DECLARE montoFinal DECIMAL(10,2);
    
    SELECT SUM(dv.cantidad * l.precio)
    INTO montoFinal
    FROM Detalle_Venta dv
    JOIN Libros l ON dv.libro_id = l.libro_id
    WHERE l.libro_id = id_libro; 
    
	RETURN montoFinal;
END // 
DELIMITER ;

SELECT totalVendido(1);	


-- Ejercicio 3
DELIMITER //
CREATE FUNCTION clienteQueMasGasto()
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE idBuscado INT;
    
    SELECT cl.cliente_id
    INTO idBuscado
    FROM Libros l
    JOIN Detalle_Venta dv ON l.libro_id = dv.libro_id
    JOIN Ventas v ON dv.venta_id = v.venta_id
    JOIN Clientes cl ON v.cliente_id = cl.cliente_id
    GROUP BY cl.cliente_id
    ORDER BY SUM(dv.cantidad * l.precio) DESC
    LIMIT 1;
    
    
    -- SELECT SUM(dv.cantidad * l.precio) -- el mayor gasto
    -- INTO montoFinal
    -- FROM Detalle_Venta dv
    -- JOIN Libros l ON dv.libro_id = l.libro_id
    -- JOIN Venta v ON v.venta_id = dv.venta_id
    -- WHERE v.cliente_id = cliente_id; -- triple join y limit 1
    
	RETURN idBuscado;
END // 
DELIMITER ;

DROP FUNCTION clienteQueMasGasto;
SELECT clienteQueMasGasto();


-- Ejercicio 4: Obtener el Libro Más Vendido en un Año
DELIMITER //
CREATE FUNCTION obtenerLibroMasVendido(año INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE nombreLibro VARCHAR(50);
   
   SELECT l.nombre_libro
   INTO nombreLibro
   FROM Detalle_Venta dv
   JOIN Libros l ON l.libro_id = dv.libro_id -- aca tendria que buscar por el año corregir eso
   GROUP BY l.nombre_libro
	ORDER BY SUM(dv.cantidad * l.precio) DESC
    LIMIT 1;
   
   
   RETURN nombreLibro;
END
// DELIMITER ;


