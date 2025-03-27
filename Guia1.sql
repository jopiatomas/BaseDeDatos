CREATE DATABASE com4Jopia;
USE com4Jopia;

CREATE TABLE IF NOT EXISTS  ejemplo_tabla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE socios (
    id_socio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_nacimiento DATE,
    direccion VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE planes (
    id_plan INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    duracion INT,
    precio DECIMAL(10, 2),
    servicios TEXT
);

CREATE TABLE actividades (
    id_actividad INT AUTO_INCREMENT PRIMARY KEY,
    id_socio INT,
    id_plan INT,
    FOREIGN KEY (id_socio) REFERENCES socios(id_socio),
    FOREIGN KEY (id_plan) REFERENCES planes(id_plan)
);


-- Ejercicio 1
DELIMITER //
CREATE PROCEDURE insertarRegistroTablaInexistente()
BEGIN

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
BEGIN 

	SELECT 'Se ha producido un error pero la ejecucion continuara' AS Mensaje;

END;

	INSERT INTO tabla_inexistente (columna)	VALUES ('valor');
	SELECT 'Ahora la ejecucion del procedimiento continuara' AS Mensaje;

END //
DELIMITER ;

CALL insertarRegistroTablaInexistente(); -- Ejercicio 1
-- ------------------------------

DELIMITER //
CREATE PROCEDURE insertarRegistroTablaInexistente()
BEGIN

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
BEGIN 

	SELECT '1. Se ha producido un error pero la ejecucion continuara' AS Mensaje;

END;

	INSERT INTO tabla_inexistente (columna)	VALUES ('valor');
	SELECT 'Ahora la ejecucion del procedimiento continuara' AS Mensaje;

END //
DELIMITER ;

-- Ejercicio 2
DELIMITER //
CREATE PROCEDURE crearUnaTablaExistente()
BEGIN

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
BEGIN 
	SELECT 'Se ha 2 producido un error pero la ejecucion continuara' AS Mensaje;
END;
	CREATE TABLE ejemplo_tabla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)
	);

	SELECT 'Ahora la ejecucion del procedimiento dos continuara' AS Mensaje;

END //
DELIMITER ;
CALL crearUnaTablaExistente(); -- Ejercicio 2
-- -----------------------------------------

-- Ejercicio 3
DELIMITER //
CREATE PROCEDURE idInexistente()
BEGIN
DECLARE idABuscar INT; -- antes del handler
DECLARE EXIT HANDLER FOR NOT FOUND
BEGIN
	
	SELECT 'La id no fue encontrada' AS Mensaje;
END;

	SELECT id INTO idABuscar
    FROM ejemplo_tabla
    WHERE id = 4;
    
	SELECT 'No se encontro la id solicitada' AS Mensaje;

END //
DELIMITER ;

DROP PROCEDURE idInexistente;
CALL idInexistente(); -- Ejercicio 3
-- --------------------------------------------


-- Ejercicio 4 --
DELIMITER  // 
CREATE PROCEDURE manejoCombinado()
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		SELECT 'Primer mensaje qué se yo' AS Mensaje; -- esto se ejecuta dos veces porque está adentor del handler
	END;
    
	INSERT INTO ejemploError(columnaError) VALUES ('error');
    CREATE TABLE planes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)
	);--
    
    SELECT 'Segundo mensaje' AS Mensaje;
END //
DELIMITER ;
DROP PROCEDURE manejoCombinado;
CALL manejoCombinado(); -- Ejercicio 4
-- ---------------------------------- --------------------------------

-- Ejercicio 5 --
DELIMITER // 
CREATE PROCEDURE insertarActividad(
	id_socio INT,
    id_plan INT
    )
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        SELECT 'Error: id_socio o id_plan no existen' AS Mensaje;
    END;

    INSERT INTO actividades (id_socio, id_plan, descripcion)
    VALUES (p_id_socio, p_id_plan, p_descripcion);

    SELECT 'La actividad continuara' AS Mensaje;
    
END //
DELIMITER ;
CALL insertarActividad(1,2); -- Ejercicio 5
-- ------------------------------------------------------------------------

-- Ejercicio 6
DELIMITER //
CREATE PROCEDURE seleccionarSocio(idBuscada INT)
BEGIN
	DECLARE id_socio_aux INT; -- Esta variable es para manejar el NOT FOUND
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    BEGIN
		SELECT 'El socio no fue encontrado' AS Mensaje;
    END;

	SELECT id_socio INTO id_socio_aux
    FROM socios
    WHERE id_socio = idBuscada;
    
    SELECT 'El programa debe continuar' AS Mensaje;
END //
DELIMITER ;    

DROP PROCEDURE seleccionarSocio;
CALL seleccionarSocio(3); -- Ejercicio 6
-- ---------------------------------------------------------------------------

DELIMITER //
-- Ejercicio 7
CREATE PROCEDURE registrarSocioConPlan(
		IN p_nombre VARCHAR(50),
        IN p_apellido VARCHAR(50),
        IN p_fecha_nacimiento DATE,
        IN p_direccion VARCHAR(50),
        IN p_telefono VARCHAR(50),
        IN p_id_plan INT
)
BEGIN
	DECLARE v_id_socio INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; -- 
        SELECT 'Error: No se pudo registrar el socio o la actividad' AS Mensaje;
    END;
    
    START TRANSACTION;
    
    -- inserta nuevo socio
    INSERT INTO socios(nombre, apellido, fecha_nacimiento, direccion, telefono) 
    VALUES (p_nombre, p_apellido, p_fecha_nacimiento, p_direccion, p_telefono);
    
    -- id del socio recien insertado
    SET v_id_socio = LAST_INSERT_ID();
    INSERT INTO actividades (id_socio, id_plan) VALUES (idSocio, idPlan);
    
    COMMIT;
	SELECT "Exito" as Mensaje;
    
END //
DELIMITER ;
    

INSERT INTO planes (nombre, duracion, precio, servicios) 
VALUES 
('Plan Básico', 30, 1999.99, 'Acceso a gimnasio y piscina'),
('Plan Premium', 60, 3499.99, 'Gimnasio, piscina, clases grupales, spa'),
('Plan VIP', 90, 4999.99, 'Todos los servicios, entrenador personal, sauna');

CALL registrarSocioConPlan("tomas", "jopia", '2003-08-21', 'jorgio 112', '22355566', 1); -- Ejercicio 7

-- Ejercicio 8
DELIMITER //
CREATE PROCEDURE actualizarPlanYRegistrarActividad(
	IN p_id_plan INT,
    IN p_nuevoPrecio DECIMAL(10,2),
    IN p_id_socio INT,
    IN p_id_actividad INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN 
		ROLLBACK;
        SELECT 'Error: no se puede actualizar el plan o actividad' AS Mensaje;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM planes WHERE id_plan = p_id_plan) OR
       NOT EXISTS (SELECT 1 FROM socios WHERE id_socio = p_id_socio) THEN
		ROLLBACK;
        SELECT 'Error: El plan, socio o actividad no existen' AS Mensaje;
    END IF;    
	
     -- Actualizar el precio del plan
    UPDATE planes  
    SET precio = p_nuevo_precio  
    WHERE id_plan = p_id_plan;

    -- Insertar una nueva actividad para el socio y el plan
    INSERT INTO actividades (id_socio, id_plan)  
    VALUES (p_id_socio, p_id_plan);

    -- Confirmar la transacción si todo salió bien
    COMMIT;  
    SELECT 'Operación completada con éxito' AS Mensaje;
    
END // 
DELIMITER ;

