/**********************************************
VISTAS DE AUXILIARES PARA LAS REGLAS DE NEGOCIO
***********************************************/

/****Ventas*****/
/*ventas_DeLotesEnBuenEstado: Lista de ventas de lotes que aún no han caducado*/
CREATE OR REPLACE VIEW ventas_DeLotesEnBuenEstado AS
    SELECT ID_LV, FECHAREALIZACION, CANTIDADVENDIDA, ID_PRE, ID_L FROM (
        SELECT ID_LV, CANTIDADVENDIDA, ID_PRE, ID_L FROM LINEASVENTA 
        NATURAL JOIN (SELECT ID_L FROM lotes_enBuenEstado) ) 
    NATURAL JOIN (SELECT * FROM VENTAS)
    ORDER BY FECHAREALIZACION DESC;
    /
    
/****Lotes*****/
/*lotes_enBuenEstado: Lista los lotes de productos que aun no han caducado*/
CREATE OR REPLACE VIEW lotes_enBuenEstado AS
    SELECT * FROM 
        (SELECT ID_L FROM LOTES NATURAL JOIN PRODUCTOS 
        WHERE (TRUNC(SYSDATE,'DD')< TRUNC(FECHAENTRADA+CADUCIDAD,'DD'))
        ORDER BY ID_L) 
    NATURAL JOIN LOTES;
    /
    
/*lotesEnBuenEstado_ventasTotal: Lista los lotes en buen estado 
    con la cantidad total vendida de cada uno*/
CREATE OR REPLACE VIEW lotesEnBuenEstado_ventasTotal AS
    SELECT subT1.ID_L, subT1.ID_PRO, subT1.fechaEntrada, 
            subT1.cantidad, subT1.precioCoste AS precio_AlMayor, 
            subT2.totalKG_deVentas 
    FROM lotes_enBuenEstado subT1
    LEFT JOIN(SELECT ID_L, SUM(cantidadVendida) AS totalKG_deVentas
            FROM ventas_DeLotesEnBuenEstado GROUP BY ID_L) subT2 
     ON subT1.ID_L= subT2.ID_L
     ORDER BY ID_PRO;
     /

/****Productos*****/
/*productos_UltimosPrecios: Ver el precio actual de los productos*/
    CREATE OR REPLACE VIEW productos_UltimosPrecios AS
        SELECT PRODUCTOS.ID_PRO, PRODUCTOS.nombre,ID_PRE, precioUnitario 
        FROM PRODUCTOS LEFT JOIN
        (SELECT ID_PRO, fecha,ID_PRE, precioUnitario FROM
            (SELECT ID_PRO, fecha, precioUnitario, max(fecha) 
            OVER (PARTITION BY ID_PRO) LAST_DATE, ID_PRE FROM PRECIOS)
    WHERE fecha=LAST_DATE) t_Precio ON PRODUCTOS.ID_PRO=T_Precio.ID_PRO;
    /
    
/*productos_stockDeLotes: Ver el stock restante de cada
    lote no caducado con su respectivo producto*/
    CREATE OR REPLACE VIEW productos_stockDeLotes AS
    SELECT PRODUCTOS.ID_PRO, PRODUCTOS.NOMBRE, 
        PRODUCTOS.stockMin, subT1.totalKG_deLOTES
        FROM PRODUCTOS LEFT JOIN
            (SELECT ID_PRO, SUM(CANTIDAD) AS totalKG_deLOTES
            FROM lotes_enBuenEstado GROUP BY ID_PRO) subT1 
        ON subT1.ID_PRO=PRODUCTOS.ID_PRO
        ORDER BY ID_PRO;
        /
/*productos_StockRestante: Ver el stock restante de cada producto
    contando los lotes en buen estado*/      
    CREATE OR REPLACE VIEW productos_StockRestante AS
    SELECT 
    subT1.ID_PRO, subT1.nombre, subT1.stockMin, subT1.TotalKG_DeLotes,
    totalKG_deVentas,
    subT1.TotalKG_DeLotes-subT2.totalKG_deVentas AS stock_Restante 
    FROM productos_stockDeLotes subT1
        LEFT JOIN (SELECT ID_PRO, SUM(totalKG_deVentas) AS totalKG_deVentas
                FROM lotesEnBuenEstado_ventasTotal GROUP BY ID_PRO) 
    subT2 ON subT1.ID_PRO=subT2.ID_PRO;
    /
     
/*lotes_enBuenEstado: Lista el stock restante de los lotes en buen estado*/     
CREATE OR REPLACE VIEW lotesEnBuenEstado_Stock AS
SELECT ID_L, ID_PRO, FECHAENTRADA, CANTIDAD, TOTALKG_DEVENTAS,
    (CANTIDAD-totalKG_deVentas) AS stock_Restante 
    FROM lotesEnBuenEstado_ventasTotal ORDER BY ID_PRO;
    /
    
/*########################################################*/
/*********************************************************
TRIGGERS DE RECLAS DE NEGOCIO SOBRE  APROVISIONAMIENTO Y PEDIDOS
**********************************************************/

/*RN1: 
No se pueden hacer ventas de productos caducados*/

CREATE OR REPLACE TRIGGER VENTA_PRODUCTO_CADUCADO
BEFORE INSERT OR UPDATE ON LINEASVENTA
FOR EACH ROW
DECLARE
ex_Venta EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Venta, -40001);
is_lote_buen_estado NUMBER;
BEGIN

    SELECT COUNT(*) INTO is_lote_buen_estado FROM LOTES_ENBUENESTADO WHERE :NEW.ID_L = ID_L;
        
    IF is_lote_buen_estado = 0 THEN
    RAISE_APPLICATION_ERROR
        (-40001, 'No se pueden hacer ventas de productos caducados.');
    END IF;
END;
/

/*RN2: 
No se pueden efectuar ventas que excedan la cantidad restante de un producto*/

CREATE OR REPLACE TRIGGER VENTA_EXCEDE_STOCK
BEFORE INSERT OR UPDATE ON LINEASVENTA
FOR EACH ROW
DECLARE
ex_Venta EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Venta, -40001);
existenciasActuales NUMBER;
BEGIN
    SELECT stock_Restante INTO existenciasActuales FROM lotesEnBuenEstado_Stock
    WHERE ID_L=(:NEW.ID_L);

    IF existenciasActuales<:NEW.cantidadVendida THEN
    RAISE_APPLICATION_ERROR(-40001, 'La cantidad de producto que se pretende 
    vender excede las existencias restantes del lote.');
    END IF;
END;
/

/*RN3: 
Pedidos con al menos tres horas de antelación*/
CREATE OR REPLACE TRIGGER VENTA_SIN_ANTELACION
BEFORE INSERT ON VENTAS
FOR EACH ROW
DECLARE
ex_Venta_Pedido EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Venta_Pedido, -60001);
BEGIN
    IF :NEW.estadoVenta='PENDIENTE' AND :NEW.fechaRecogida < SYSDATE+(3*(1/24))
    THEN RAISE_APPLICATION_ERROR(-60001, 'Los pedidos deben hacerse por lo menos 
        con 3 horas de antelación');
    END IF;
END;
/

/*RN4: 
Pedidos especiales con al menos 2 días de antelación*/
CREATE OR REPLACE TRIGGER VENTA_ESPECIAL_SIN_ANTELACION
BEFORE INSERT ON LineasVentaEspecial
FOR EACH ROW
DECLARE
ex_Venta_Pedido_Especial EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Venta_Pedido_Especial, -70002);
venta_reference Ventas%ROWTYPE;
BEGIN

    SELECT * INTO venta_reference FROM Ventas 
    WHERE ID_V = :NEW.ID_V;
    
    IF venta_reference.estadoVenta='PENDIENTE' 
        AND venta_reference.fechaRecogida < SYSDATE+(2)  THEN
    RAISE_APPLICATION_ERROR
    (-70002, 'Los pedidos especiales deben hacerse por lo menos con 2 días de antelación');
    END IF;
END;
/
