/*************************************
VISTAS DE APROVISIONAMIENTO Y PEDIDOS
*************************************/
/****Ventas*****/
/*ventas_DeLotesEnBuenEstado: Lista de ventas de lotes que aún no han caducado*/
CREATE OR REPLACE VIEW ventas_DeLotesEnBuenEstado AS
    SELECT ID_LV, FECHAREALIZACION, CANTIDADVENDIDA, ID_PRE, ID_L FROM (
        SELECT ID_LV, CANTIDADVENDIDA, ID_PRE, ID_L FROM LINEASVENTA 
        NATURAL JOIN (SELECT ID_L FROM lotes_enBuenEstado) ) 
    NATURAL JOIN (SELECT * FROM VENTAS)
    ORDER BY FECHAREALIZACION DESC;
    /
/*ventas_aPrecio: Lista de ventas con su precio y producto*/
CREATE OR REPLACE VIEW ventas_aPrecio AS
    SELECT ID_V, ID_LV, cantidadVendida, 
        ID_PRE, precioUnitario, ID_L, ID_PRO, NOMBRE
    FROM LINEASVENTA 
        NATURAL JOIN 
            (SELECT ID_PRE, precioUnitario, ID_PRO FROM PRECIOS) 
        NATURAL JOIN
            (SELECT ID_PRO, NOMBRE FROM PRODUCTOS)
        NATURAL JOIN 
            (SELECT * FROM VENTAS)
    ORDER BY FECHAREALIZACION;
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
            subT1.cantidad, subT1.precioUnitarioAlMayor AS precio_AlMayor, 
            subT2.totalKG_deVentas 
    FROM lotes_enBuenEstado subT1
    LEFT JOIN(SELECT ID_L, SUM(cantidadVendida) AS totalKG_deVentas
            FROM ventas_DeLotesEnBuenEstado GROUP BY ID_L) subT2 
     ON subT1.ID_L= subT2.ID_L
     ORDER BY ID_PRO;
     /
     
/*lotes_enBuenEstado: Lista el stock restante de los lotes en buen estado*/     
CREATE OR REPLACE VIEW lotesEnBuenEstado_Stock AS
SELECT ID_L, ID_PRO, FECHAENTRADA, CANTIDAD, TOTALKG_DEVENTAS,
    (CANTIDAD-totalKG_deVentas) AS stock_Restante 
    FROM lotesEnBuenEstado_ventasTotal ORDER BY ID_PRO;
    /

/*lotes_ventasTotal: Se obtiene la cantidad vendida de cada lote,
    incluso los ya caducados*/
CREATE OR REPLACE VIEW lotes_ventasTotal AS
    SELECT subT1.ID_L, subT1.ID_PRO, subT1.fechaEntrada, 
            subT1.cantidad, subT1.precioUnitarioAlMayor AS precio_AlMayor, 
            subT2.totalKG_deVentas 
    FROM LOTES subT1
    LEFT JOIN(SELECT ID_L, SUM(cantidadVendida) AS totalKG_deVentas
            FROM LINEASVENTA GROUP BY ID_L) subT2 
     ON subT1.ID_L= subT2.ID_L
     ORDER BY ID_PRO;
     /
/*lotes_stockRestante: Se obtiene el stock restante de todos los lotes,
    incluyendo los ya caducados*/
CREATE OR REPLACE VIEW lotes_stockRestante AS
SELECT ID_L, ID_PRO, FECHAENTRADA, CANTIDAD, TOTALKG_DEVENTAS,
    (CANTIDAD-totalKG_deVentas) AS stockRestante_Lote 
    FROM lotes_ventasTotal ORDER BY ID_PRO;
    /

/*lotes_Caducados: Se listan todos los lotes caducados*/
CREATE OR REPLACE VIEW lotes_Caducados AS
    SELECT * FROM 
        (SELECT ID_L FROM LOTES NATURAL JOIN PRODUCTOS 
        WHERE (TRUNC(FECHAENTRADA+CADUCIDAD,'DD')<TRUNC(SYSDATE,'DD')) 
        ORDER BY ID_L) 
    NATURAL JOIN LOTES;
    /
    
/*lotes_Caducados: Se obtiene el beneficio bruto de cada lote*/
CREATE OR REPLACE VIEW lotes_beneficioTotal AS 
    SELECT LOTES.ID_L,LOTES.FECHAENTRADA ,LOTES.CANTIDAD*LOTES.PRECIOUNITARIOALMAYOR AS coste_totalLote,
            SubT2.INGRESO_totalVentas, 
            (SubT2.INGRESO_totalVentas-(LOTES.CANTIDAD*LOTES.PRECIOUNITARIOALMAYOR)) 
                AS BENEFICIO 
            FROM LOTES LEFT JOIN 
            (SELECT ID_L, SUM(cantidadVendida*precioUnitario) 
            AS INGRESO_totalVentas 
            FROM ventas_aPrecio 
            GROUP BY ID_L) subT2 ON LOTES.ID_L=subT2.ID_L;
            /
    
/****Precios*****/


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
        PRODUCTOS.STOCKMINKG, subT1.totalKG_deLOTES
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
    subT1.ID_PRO, subT1.nombre, subT1.stockMinKG, subT1.TotalKG_DeLotes,
    totalKG_deVentas,
    subT1.TotalKG_DeLotes-subT2.totalKG_deVentas AS stock_Restante 
    FROM productos_stockDeLotes subT1
        LEFT JOIN (SELECT ID_PRO, SUM(totalKG_deVentas) AS totalKG_deVentas
                FROM lotesEnBuenEstado_ventasTotal GROUP BY ID_PRO) 
    subT2 ON subT1.ID_PRO=subT2.ID_PRO;
    /
    
    
/****Clientes*****/
/*clientes_hechoPedidose: Listar los clientes que han hecho algún pedido*/ 
CREATE OR REPLACE VIEW clientes_hechoPedidos AS
    SELECT * FROM CLIENTES NATURAL JOIN (SELECT ID_U FROM PEDIDOS GROUP BY ID_U);
    /
/****Pedidos*****/

/****LineasPedido*****/
/*lineasPedido_dePedido: Listar las lineas de pedido agrupadas por pedido*/
CREATE OR REPLACE VIEW lineasPedido_dePedido AS
    SELECT * FROM LINEASPEDIDO ORDER BY ID_PD;
    /
    
/*lineasPedido_aDespacharHoy: Listar las lineas de pedido 
    que se deben despachar hoy*/
CREATE OR REPLACE VIEW lineasPedido_aDespacharHoy AS
    SELECT * FROM lineasPedido_dePedido 
    NATURAL JOIN(SELECT ID_PD, fechaRecogida FROM PEDIDOS 
        WHERE TRUNC(PEDIDOS.FECHARECOGIDA, 'DD')=TRUNC(SYSDATE, 'DD'));
        /

/****LineasListaCompra*****/
/*lineasListaCompra_ListaHoy: Listar los productos que se deben comprar
    ese día para reponer stock, habiendo generado previamente la ListaCompra
    correspondiente*/
CREATE OR REPLACE VIEW lineasListaCompra_ListaHoy AS
    SELECT * FROM LINEASLISTACOMPRA 
    NATURAL JOIN
    (SELECT ID_LC FROM LISTASCOMPRA WHERE TRUNC(fecha,'DD')=TRUNC(SYSDATE,'DD'));
    /

/****Listas Compra*****/

/*************************************
VISTAS DE ORGANIZACIÓN Y HORARIO
*************************************/

/****Turnos*****/
/*turnos_Actuales: Listar los turnos existentes por orden de 
    apertura*/
CREATE OR REPLACE VIEW turnos_Actuales AS
    SELECT * FROM TURNOS ORDER BY horaApertura;
    /
/****Empleados*****/
/*empleados_DeBaja: Listar los empleados que se encuentran de baja*/
CREATE OR REPLACE VIEW empleados_DeBaja AS
    SELECT * FROM EMPLEADOS WHERE bajaTemporal='s';
    /
/****Jornada*****/
/*ORACLE: TRUNC(SYSDATE,'DAY') -> Starting day of the week*/
/*jornadas_SemanaActual: Listar todas las jornadas asignadas para esta semana*/
CREATE OR REPLACE VIEW jornadas_SemanaActual AS
    SELECT * FROM JORNADAS WHERE 
        TRUNC(fechaHoraInicio,'DAY')=TRUNC(SYSDATE,'DAY');
    /
/*jornadas_SemanaSiguiente: Listar todas las semanas establecidas 
    para la semana siguiente*/
CREATE OR REPLACE VIEW jornadas_SemanaSiguiente AS
    SELECT * FROM JORNADAS WHERE 
        TRUNC(fechaHoraInicio,'DAY')=TRUNC(SYSDATE+7,'DAY');
    /
/****Incidencias*****/
CREATE OR REPLACE VIEW incidencias_Pendientes AS
    SELECT * FROM INCIDENCIAS WHERE estadoIncidencia='PENDIENTE';
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
CREATE OR REPLACE TRIGGER PEDIDO_SIN_ANTELACION
BEFORE INSERT OR UPDATE ON PEDIDOS
FOR EACH ROW
DECLARE
ex_Pedido EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Pedido, -60001);
BEGIN
    IF :NEW.fechaRecogida < SYSDATE+(3*(1/24))  THEN
    RAISE_APPLICATION_ERROR(-60001, 'Los pedidos deben hacerse por lo menos 
        con 3 horas de antelación');
    END IF;
END;
/

/*RN4: 
Pedidos especiales o de productos sin stock, con al menos 2 días de antelación*/
CREATE OR REPLACE TRIGGER PEDIDO_ESPECIAL_SIN_ANTELACION
BEFORE INSERT OR UPDATE ON PEDIDOS
FOR EACH ROW
DECLARE
ex_Pedido EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Pedido, -60002);
is_pedido_especial NUMBER;
is_pedido_fuera_de_stock NUMBER;
BEGIN
    SELECT COUNT(*) INTO is_pedido_especial FROM LINEASPEDIDOESPECIAL 
    WHERE ID_PD = :NEW.ID_PD;
    
    SELECT COUNT(*) INTO is_pedido_fuera_de_stock FROM LINEASPEDIDO
    NATURAL JOIN productos_StockRestante
    WHERE ID_PD = :NEW.ID_PD AND stock_Restante - cantidadKg < 0;
    
    IF :NEW.fechaRecogida < SYSDATE+(2)  THEN
    RAISE_APPLICATION_ERROR
    (-60001, 'Los pedidos especiales deben hacerse por lo menos con 2 días de antelación');
    END IF;
END;
/
/****Productos*****/

/****Precios*****/
CREATE OR REPLACE TRIGGER PRECIO_CON_FECHA_POSTERIOR
BEFORE INSERT OR UPDATE ON PRECIOS
FOR EACH ROW
DECLARE
ex_Precio EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Precio, -30001);
BEGIN
    IF :NEW.fecha<SYSDATE THEN
    RAISE_APPLICATION_ERROR(-30001, 'No se puede añadir un precio 
        con una fecha anterior a la actual.');
    END IF;
END;
/
/****Lotes*****/

/****Ventas*****/

CREATE OR REPLACE TRIGGER VENTA_SIN_PRECIO
BEFORE INSERT OR UPDATE ON LINEASVENTA
FOR EACH ROW
DECLARE
ex_Venta EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Venta, -40001);
pre_count NUMBER;
BEGIN

    SELECT COUNT(*) INTO pre_count FROM PRECIOS 
        NATURAL JOIN(SELECT ID_PRO FROM LOTES WHERE ID_L=(:NEW.ID_L));
    IF pre_count=0 THEN
    RAISE_APPLICATION_ERROR(-40001, 'No se puede hacer una venta si no 
    hay ningún precio definido para el producto');
    END IF;
END;
/
CREATE OR REPLACE TRIGGER VENTA_NO_RENTABLE
BEFORE INSERT OR UPDATE ON LINEASVENTA
FOR EACH ROW
DECLARE
ex_Venta EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Venta, -40001);
coste_AlMayor NUMBER;
precio_Minorista NUMBER;
BEGIN
    SELECT lotes.PRECIOUNITARIOALMAYOR INTO coste_AlMayor 
    FROM lotes WHERE ID_L=(:NEW.ID_L);
    
    SELECT precioUnitario INTO precio_Minorista FROM  productos_UltimosPrecios
        NATURAL JOIN(SELECT ID_PRO FROM LOTES WHERE ID_L=(:NEW.ID_L));
   
    IF precio_Minorista<coste_AlMayor THEN
    RAISE_APPLICATION_ERROR(-40001, 'La venta se está haciendo a un precio 
        inferior al coste de adquirirlo.');
    END IF;
END;
/

/****Clientes*****/

CREATE OR REPLACE TRIGGER CLIENTE_MENOR_18
BEFORE INSERT OR UPDATE ON CLIENTES
FOR EACH ROW
DECLARE
ex_Cliente EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Cliente, -50001);
edadCliente NUMBER;
BEGIN
    IF  SYSDATE<:NEW.fechaNacimiento THEN
    RAISE_APPLICATION_ERROR(-50001, 'La fecha de nacimiento 
        no puede ser posterior al día actual.');
    END IF;
    edadCliente:= TRUNC(TO_NUMBER(SYSDATE-:NEW.fechaNacimiento)/365);
    IF  edadCliente<18 THEN
    RAISE_APPLICATION_ERROR(-50001, 'Los clientes registrados deben tener
    por lo menos 18 años.');
    END IF;
END;
/
/****Pedidos*****/

CREATE OR REPLACE TRIGGER PEDIDO_ENTREGADO
BEFORE INSERT OR UPDATE ON PEDIDOS
FOR EACH ROW
DECLARE
ex_Pedido EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Pedido, -60001);
BEGIN
    IF (:OLD.estadoPedido IS NULL )AND
    ((:NEW.estadoPedido='DESPACHADO')OR(:NEW.estadoPedido='ENTREGADO')) THEN
    RAISE_APPLICATION_ERROR(-60001, 'Los pedidos en el momento de crearse deben
    tener como estado PENDIENTE');
    END IF;
    IF (:OLD.estadoPedido='DESPACHADO')AND
    (:NEW.estadoPedido='PENDIENTE') THEN
    RAISE_APPLICATION_ERROR(-60001, 'Los pedidos una vez DESPACHADO no pueden 
    retroceder de estado PENDIENTE.');
    END IF;
        IF (:OLD.estadoPedido='ENTREGADO') THEN
    RAISE_APPLICATION_ERROR(-60001, 'Los pedidos una vez ENTREGADO no pueden 
    cambiar de estado.');
    END IF;

END;
/
/****LineasPedido*****/
CREATE OR REPLACE TRIGGER LINEAPEDIDO_EXCEDE_STOCK
BEFORE INSERT OR UPDATE ON LINEASPEDIDO
FOR EACH ROW
DECLARE
ex_LineaPedido EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_LineaPedido, -70001);
existenciasActuales NUMBER;
BEGIN
    SELECT stock_Restante INTO existenciasActuales FROM productos_StockRestante
     WHERE ID_PRO=:NEW.ID_PRO;

    IF existenciasActuales<:NEW.cantidadKg THEN
    RAISE_APPLICATION_ERROR(-70001, 'La cantidad de producto que se pretende 
    vender excede las existencias restantes de producto.');
    END IF;
END;
/
/****LineasListaCompra*****/
CREATE OR REPLACE TRIGGER LINEALISTACOMPRA_INVALIDA
BEFORE INSERT OR UPDATE ON LINEASLISTACOMPRA
FOR EACH ROW
DECLARE
ex_LineaListaCompra EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_LineaListaCompra, -80001);
fecha_ListaCompra DATE;
BEGIN
    SELECT fecha INTO fecha_ListaCompra FROM LISTASCOMPRA 
    WHERE ID_LC= :NEW.ID_LC;
    
    IF TRUNC(fecha_ListaCompra,'DD')<TRUNC(SYSDATE, 'DD') THEN
    RAISE_APPLICATION_ERROR(-80001, 'No se puede añadir una linea a una 
        lista de compra anterior a la fecha actual.');
    END IF;
END;
/
CREATE OR REPLACE TRIGGER LINEALISTACOMPRA_ESTADO
BEFORE INSERT OR UPDATE ON LINEASLISTACOMPRA
FOR EACH ROW
DECLARE
ex_LineaListaCompra EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_LineaListaCompra, -80001);
BEGIN
    IF (:OLD.estadoComprado IS NULL)AND(:NEW.estadoComprado='s') THEN
    RAISE_APPLICATION_ERROR(-80001, 'No se puede añadir una linea de 
    lista de compra como ya comprada.');
    END IF;
    
    IF :OLD.estadoComprado='s' THEN
    RAISE_APPLICATION_ERROR(-80001, 'No se puede alterar el estado de una linea 
        de una Lista de Compra cuando ya se ha comprado.');
    END IF;
END;
/
/****Listas Compra*****/
CREATE OR REPLACE TRIGGER LISTACOMPRA_FECHA_INVALIDA
BEFORE INSERT OR UPDATE ON LISTASCOMPRA
FOR EACH ROW
DECLARE
ex_ListaCompra EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_ListaCompra, -90001);
BEGIN
    IF TRUNC(:NEW.fecha,'DD')<TRUNC(SYSDATE, 'DD') THEN
    RAISE_APPLICATION_ERROR(-90001, 'No se puede crear una lista 
        de compra anterior a la fecha actual.');
    END IF;
END;
/
CREATE OR REPLACE TRIGGER LISTACOMPRA_UNICA
BEFORE INSERT OR UPDATE ON LISTASCOMPRA
FOR EACH ROW
DECLARE
ex_ListaCompra EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_ListaCompra, -90001);
n_listasCompra NUMBER;
BEGIN
SELECT COUNT(*) INTO n_listasCompra FROM LISTASCOMPRA 
    WHERE TRUNC(FECHA,'DD')=TRUNC(:NEW.FECHA,'DD');

    IF 0<n_listasCompra THEN
    RAISE_APPLICATION_ERROR(-90001, 'No se puede crear una lista 
        de compra si ya existe una para el mismo día.');
    END IF;
END;
/
/*********************************************************
TRIGGERS DE RECLAS DE NEGOCIO SOBRE ORGANIZACIÓN Y HORARIO
**********************************************************/

/*RN6: No se debe poder generar incidencias de jornadas ya trabajadas*/
/****Incidencias*****/
CREATE OR REPLACE TRIGGER INCIDENCIAS_YA_TRABAJADAS
BEFORE INSERT OR UPDATE ON INCIDENCIAS
FOR EACH ROW
DECLARE
ex_Jornada EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Jornada , -140001);
aux_jornadaID JORNADAS%ROWTYPE;
BEGIN
    SELECT * INTO aux_jornadaID FROM JORNADAS WHERE ID_J=:NEW.ID_J;
    IF TRUNC(aux_jornadaID.fechaHoraInicio,'DD')<TRUNC(SYSDATE, 'DD') THEN
    RAISE_APPLICATION_ERROR(-140001, 'No se puede crear una incidencia
    a una jornada que que ya se ha trabajado.');
    END IF;
END;
/

/*RN7: No se puede eliminar una jornada que ya ha sido trabajada*/

CREATE OR REPLACE TRIGGER JORNADAS_YA_TRABAJADAS
BEFORE UPDATE OR DELETE ON JORNADAS
FOR EACH ROW
DECLARE
ex_Jornada EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Jornada , -130001);
BEGIN
    IF :OLD.fechaHoraInicio<SYSDATE THEN
    RAISE_APPLICATION_ERROR(-130001, 'La jornada que se pretende modificar 
    o eliminar ya ha sido trabajada.');
    END IF;
END;
/

/*RN8: Un empleado no puede trabajar más de 40h semanales*/

CREATE OR REPLACE TRIGGER JORNADAS_EXCESO_HORAS
BEFORE INSERT OR UPDATE ON JORNADAS
FOR EACH ROW
DECLARE
ex_Jornada EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Jornada , -130001);
CURSOR jornadasSemana IS SELECT * FROM JORNADAS 
    WHERE ID_U=:NEW.ID_U AND 
        TRUNC(fechaHoraInicio, 'DAY')=TRUNC(:NEW.fechaHoraInicio, 'DAY');
CURSOR jornadasDia IS SELECT * FROM JORNADAS 
    WHERE ID_U=:NEW.ID_U AND 
        TRUNC(fechaHoraInicio, 'DD')=TRUNC(:NEW.fechaHoraInicio, 'DD');
total_horasSemana  NUMBER;
total_horasDia  NUMBER;
BEGIN
    OPEN jornadasDia;
    FOR aux_jornada IN jornadasDia LOOP
        total_horasDia:= total_horasDia 
        +(TO_NUMBER(aux_jornada.fechaHoraSalida - aux_jornada.fechaHoraInicio)*24);
    END LOOP;
    CLOSE jornadasDia;
    
    IF 9<total_horasDia THEN
    RAISE_APPLICATION_ERROR(-130001, 'La jornada que se pretende añadir
        incumple la restricción del máximo de 9 horas diarias de trabajo.');
    END IF;
    
    OPEN jornadasSemana;
    FOR aux_jornada IN jornadasDia LOOP
        total_horasSemana:= total_horasSemana
        +(TO_NUMBER(aux_jornada.fechaHoraSalida - aux_jornada.fechaHoraInicio)*24);
    END LOOP;
    CLOSE jornadasSemana;
    
    IF 40<total_horasSemana THEN
    RAISE_APPLICATION_ERROR(-130001, 'La jornada que se pretende añadir
        incumple la restricción del máximo de 40 horas semanales de trabajo.');
    END IF;
END;
/

/*RN9: 
No se puede asignar una jornada a un trabajador 
si en ese momento está de baja temporal*/

CREATE OR REPLACE TRIGGER JORNADAS_EMPLEADO_BAJA
BEFORE INSERT OR UPDATE ON JORNADAS
FOR EACH ROW
DECLARE
ex_Jornada EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Jornada , -130001);
is_de_baja CHAR(1); 
BEGIN
    SELECT bajaTemporal INTO is_de_baja FROM Empleados WHERE ID_U = :NEW.ID_U;

    IF is_de_baja LIKE 's' THEN
    
    RAISE_APPLICATION_ERROR(-100001, 'El empleado al que se le quiere asignar la jornada está de baja.');
    END IF;
END;
/

/****Turnos*****/
CREATE OR REPLACE TRIGGER TURNO_SIN_SOLAPAMIENTO
BEFORE INSERT OR UPDATE ON TURNOS
FOR EACH ROW
DECLARE
ex_Turno EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Turno, -100001);
CURSOR turnosDia IS SELECT * FROM TURNOS WHERE diaSemana=:NEW.diaSemana;
BEGIN
   
    OPEN turnosDia;
    FOR aux_turno IN turnosDia LOOP
        IF(:NEW.horaApertura<aux_turno.horaFinal
            AND aux_turno.horaApertura<:NEW.horaFinal) THEN
        RAISE_APPLICATION_ERROR(-100001, 
            'Los Turnos no pueden solaparse entre ellos.');
    END IF;
    END LOOP;
    CLOSE turnosDia;
    
END;
/
CREATE OR REPLACE TRIGGER TURNO_DURACION_NO_VALIDA
BEFORE INSERT OR UPDATE ON TURNOS
FOR EACH ROW
DECLARE
ex_Turno EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Turno, -100001);
BEGIN
   
    IF (TO_NUMBER(:NEW.horaFinal-:NEW.horaApertura)*24)<2 THEN
    
    RAISE_APPLICATION_ERROR(-100001, 'Los turnos deben durar 
    un minimo de 2 horas');
    END IF;
    
    IF 6<(TO_NUMBER(:NEW.horaFinal-:NEW.horaApertura)*24) THEN
    
    RAISE_APPLICATION_ERROR(-100001, 'Los turnos no pueden durar 
   más de 6 horas.');
    END IF;
END;
/
CREATE OR REPLACE TRIGGER TURNO_NO_VALIDO
BEFORE INSERT OR UPDATE ON TURNOS
FOR EACH ROW
DECLARE
ex_Turno EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Turno, -100001);

        LUNES CONSTANT VARCHAR2(10) := '01/01/2001';
        MARTES CONSTANT VARCHAR2(10) :='02/01/2001';
        MIERCOLES CONSTANT VARCHAR2(10) :='03/01/2001';
        JUEVES CONSTANT VARCHAR2(10) :='04/01/2001';
        VIERNES CONSTANT VARCHAR2(10) :='05/01/2001';
        SABADO CONSTANT VARCHAR2(10) :='06/01/2001';
        DOMINGO CONSTANT VARCHAR2(10) :='07/01/2001';
    aux_Referencia DATE;
BEGIN
   CASE REPLACE(TO_CHAR(:NEW.horaApertura,'DAY'), ' ', '')
        WHEN 'LUNES' THEN aux_Referencia:=TO_DATE(LUNES,'DD/MM/YYYY');
        WHEN 'MARTES' THEN aux_Referencia:=TO_DATE(MARTES,'DD/MM/YYYY');
        WHEN 'MIÉRCOLES' THEN aux_Referencia:=TO_DATE(MIERCOLES,'DD/MM/YYYY');
        WHEN 'JUEVES' THEN aux_Referencia:=TO_DATE(JUEVES,'DD/MM/YYYY');
        WHEN 'VIERNES' THEN aux_Referencia:=TO_DATE(VIERNES,'DD/MM/YYYY');
        WHEN 'SÁBADO' THEN aux_Referencia:=TO_DATE(SABADO,'DD/MM/YYYY');
        WHEN 'DOMINGO' THEN aux_Referencia:=TO_DATE(DOMINGO,'DD/MM/YYYY');
        END CASE;
    
    IF( TRUNC(:NEW.horaApertura, 'DD')<> TRUNC(:NEW.horaFinal,'DD')) 
    THEN
    RAISE_APPLICATION_ERROR(-100001, 'Los turnos deben tener una hora de inicio 
        y final en el mismo día.');
    END IF;
    
    IF( (:NEW.diaSemana<> REPLACE(TO_CHAR(:NEW.horaApertura,'DAY'),' ','')) 
    OR (:NEW.diaSemana<> REPLACE(TO_CHAR(:NEW.horaApertura,'DAY'),' ','')) )
    THEN
    RAISE_APPLICATION_ERROR(-100001, 'Los Turnos deben tener horas de inicio
    y final que coincidan con el día de la semana al que hacen referencia.');
    END IF;
    
    IF (TRUNC(:NEW.horaApertura, 'DD')<> TRUNC(aux_Referencia,'DD')) 
    THEN
    
    RAISE_APPLICATION_ERROR(-100001, 'Los Turnos almacenan en las columnas de horaApertura 
    y horaFinal valores de hora absolutos, la fecha debe coincidir con la semana 
    de referencia, que es la primera semana del 2001.');
    END IF;
END;
/
/****Empleados*****/

/****Jornada*****/
CREATE OR REPLACE TRIGGER JORNADA_TURNO_INEXISTENTE
BEFORE INSERT ON JORNADAS
FOR EACH ROW
DECLARE
ex_Jornada EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_Jornada , -130001);
CURSOR turnosDia IS SELECT * FROM TURNOS 
    WHERE diaSemana=TO_CHAR(:NEW.fechaHoraInicio, 'DAY');
aux_coincidencia BOOLEAN:=FALSE;
BEGIN
    OPEN turnosDia;
    FOR aux_turno IN turnosDia LOOP
        IF(:NEW.fechaHoraInicio<aux_turno.horaFinal
            AND aux_turno.horaApertura<:NEW.fechaHoraSalida) THEN
            aux_coincidencia:=TRUE;
    END IF;
    END LOOP;
    CLOSE turnosDia;
    
    IF aux_coincidencia THEN
    RAISE_APPLICATION_ERROR(-130001, 'La jornada que se pretende añadir no se
    corresponde con ningún turno existente.');
    END IF;
END;
/


