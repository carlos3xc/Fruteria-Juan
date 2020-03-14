ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
CREATE OR REPLACE FUNCTION ASSERT_EQUALS
    (salida BOOLEAN, salidaEsperada BOOLEAN) RETURN VARCHAR2 AS
    BEGIN
    IF(salida=salidaEsperada) THEN 
        RETURN 'EXITO';
    ELSE 
        RETURN 'FALLO';
        END IF;
END ASSERT_EQUALS;
/
/**************************************
PRUEBAS DE APROVISIONAMIENTO Y PEDIDOS
***************************************/
/****PRODUCTOS*****/
CREATE OR REPLACE PACKAGE pruebas_productos AS 
    PROCEDURE inicializar;
   
    PROCEDURE insertar(nombre_prueba VARCHAR2, 
        TEST_NOMBRE IN PRODUCTOS.nombre%TYPE,
        TEST_CADUCIDAD IN PRODUCTOS.Caducidad%TYPE,
        TEST_STOCK IN PRODUCTOS.StockMinKg%TYPE,
            salidaEsperada BOOLEAN);
    
    PROCEDURE modificar
        (nombre_prueba VARCHAR2,
        TEST_ID IN PRODUCTOS.ID_PRO%TYPE,
        TEST_NOMBRE IN PRODUCTOS.Nombre%TYPE,
        TEST_CADUCIDAD IN PRODUCTOS.Caducidad%TYPE,
        TEST_STOCK IN PRODUCTOS.StockMinKg%TYPE,
            salidaEsperada BOOLEAN);

    PROCEDURE eliminar(nombre_prueba VARCHAR2,
        TEST_ID_Eliminar IN PRODUCTOS.ID_PRO%TYPE,
            salidaEsperada BOOLEAN); 
        
END pruebas_productos;
/
CREATE OR REPLACE PACKAGE BODY pruebas_productos AS 
    
    PROCEDURE inicializar IS
        BEGIN
        DELETE FROM PRODUCTOS;
    END inicializar;
    
    PROCEDURE insertar(nombre_prueba VARCHAR2, 
        TEST_NOMBRE IN PRODUCTOS.Nombre%TYPE,
        TEST_CADUCIDAD IN PRODUCTOS.Caducidad%TYPE,
        TEST_STOCK IN PRODUCTOS.StockMinKg%TYPE,
            salidaEsperada BOOLEAN) IS
        salida BOOLEAN:= TRUE;
        aux_producto PRODUCTOS%ROWTYPE;
        aux_ID NUMBER;
        BEGIN
        /*******Ejecutar prueba*******/
        p_productos.crear(TEST_NOMBRE,TEST_CADUCIDAD,TEST_STOCK);
        /*******Comprobar resultado*******/
        aux_ID:= SEC_PRODUCTOS.CURRVAL;
        SELECT * INTO aux_PRODUCTO FROM PRODUCTOS 
            WHERE ID_PRO=aux_ID;
        IF(TEST_NOMBRE<>aux_PRODUCTO.nombre) OR
         (TEST_CADUCIDAD<>aux_PRODUCTO.caducidad)OR
         (TEST_STOCK<>aux_PRODUCTO.stockMinKg) THEN
         SALIDA:=FALSE;
         END IF;
         COMMIT WORK;
         /******Resultado de la Prueba******/
             DBMS_OUTPUT.PUT_LINE(nombre_prueba||': '||
                    ASSERT_EQUALS(salida, salidaEsperada));
         EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(nombre_prueba||': '||
                ASSERT_EQUALS(FALSE, salidaEsperada));
            ROLLBACK;
    END insertar;
    
    PROCEDURE modificar
        (nombre_prueba VARCHAR2,
        TEST_ID IN PRODUCTOS.ID_PRO%TYPE,
        TEST_NOMBRE IN PRODUCTOS.Nombre%TYPE,
        TEST_CADUCIDAD IN PRODUCTOS.Caducidad%TYPE,
        TEST_STOCK IN PRODUCTOS.StockMinKg%TYPE,
            salidaEsperada BOOLEAN)IS
        salida BOOLEAN:= TRUE;
        aux_PRODUCTO PRODUCTOS%ROWTYPE;
        BEGIN
        /*******Ejecutar prueba*******/
        p_productos.modificar(TEST_ID,TEST_NOMBRE,TEST_CADUCIDAD,TEST_STOCK);
        /*******Comprobar resultado*******/
        SELECT * INTO aux_PRODUCTO FROM PRODUCTOS 
            WHERE ID_PRO=TEST_ID;
        IF(TEST_NOMBRE<>aux_PRODUCTO.nombre) OR
         (TEST_CADUCIDAD<>aux_PRODUCTO.caducidad)OR
         (TEST_STOCK<>aux_PRODUCTO.stockMinKg) THEN
         SALIDA:=FALSE;
         END IF;
         COMMIT WORK;
         /******Resultado de la Prueba******/
             DBMS_OUTPUT.PUT_LINE(nombre_prueba||': '||
                    ASSERT_EQUALS(salida, salidaEsperada));
         EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(nombre_prueba||': '||
                ASSERT_EQUALS(FALSE, salidaEsperada));
            ROLLBACK;
    END modificar;

    PROCEDURE eliminar(nombre_prueba VARCHAR2,
        TEST_ID_Eliminar IN PRODUCTOS.ID_PRO%TYPE,
            salidaEsperada BOOLEAN)IS
        salida BOOLEAN:= TRUE;
        aux_counter INTEGER;
        BEGIN
        /*******Ejecutar prueba*******/
        p_productos.eliminar(TEST_ID_Eliminar);
        /*******Comprobar resultado*******/
        SELECT COUNT(*) INTO aux_counter FROM PRODUCTOS 
            WHERE ID_PRO=TEST_ID_Eliminar;
        IF(aux_counter<>0)THEN
         SALIDA:=FALSE;
         END IF;
         COMMIT WORK;
         /******Resultado de la Prueba******/
             DBMS_OUTPUT.PUT_LINE(nombre_prueba||': '||
                    ASSERT_EQUALS(salida, salidaEsperada));
         EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(nombre_prueba||': '||
                ASSERT_EQUALS(FALSE, salidaEsperada));
            ROLLBACK;
    END eliminar;
        
END pruebas_productos;
/
/**************************************
PRUEBAS DE ORGANIZACIÓN Y HORARIO
***************************************/
SET SERVEROUTPUT ON;
DECLARE
aux_ID1 NUMBER;
aux_ID2 NUMBER;
BEGIN
/**************************************
        EJECUCION DE PRUEBAS
***************************************/
/**** PRUEBAS PRODUCTOS*****/
PRUEBAS_PRODUCTOS.inicializar;
PRUEBAS_PRODUCTOS.insertar('Prueba 1 - Producto válido', 
    'manzana', 5, 50.8, true);
PRUEBAS_PRODUCTOS.insertar('Prueba 2 - Producto no válido', 
    'pera', -7, 50.8, false);
END;