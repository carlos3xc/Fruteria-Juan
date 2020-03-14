/**************************************
PAQUETES DE APROVISIONAMIENTO Y PEDIDOS
***************************************/

/*Funciones Auxiliares*/

/****Productos*****/

CREATE OR REPLACE PACKAGE p_productos AS

    PROCEDURE crear
        (PRO_NOMBRE IN PRODUCTOS.Nombre%TYPE,
       PRO_CADUCIDAD IN PRODUCTOS.Caducidad%TYPE,
       PRO_STOCK IN PRODUCTOS.StockMinKg%TYPE);
       
        PROCEDURE modificar
        (PRO_ID IN PRODUCTOS.ID_PRO%TYPE,
        PRO_NOMBRE IN PRODUCTOS.Nombre%TYPE,
        PRO_CADUCIDAD IN PRODUCTOS.Caducidad%TYPE,
        PRO_STOCK IN PRODUCTOS.StockMinKg%TYPE);
       
       PROCEDURE eliminar
        (PRO_ID_Eliminar IN PRODUCTOS.ID_PRO%TYPE);
        
        FUNCTION obtenerId(
            PRO_NOMBRE IN PRODUCTOS.Nombre%TYPE) 
            RETURN PRODUCTOS.ID_PRO%TYPE;
            
END p_productos;
/
CREATE OR REPLACE PACKAGE BODY p_productos AS
    PROCEDURE crear
        (PRO_NOMBRE IN PRODUCTOS.Nombre%TYPE,
       PRO_CADUCIDAD IN PRODUCTOS.Caducidad%TYPE,
       PRO_STOCK IN PRODUCTOS.StockMinKg%TYPE)
         IS
        BEGIN
          INSERT INTO PRODUCTOS(NOMBRE,CADUCIDAD,STOCKMINKG) 
          VALUES (PRO_NOMBRE,PRO_CADUCIDAD,ROUND(PRO_STOCK,2));
        END crear;
        
    PROCEDURE modificar
        (PRO_ID IN PRODUCTOS.ID_PRO%TYPE,
        PRO_NOMBRE IN PRODUCTOS.Nombre%TYPE,
        PRO_CADUCIDAD IN PRODUCTOS.Caducidad%TYPE,
        PRO_STOCK IN PRODUCTOS.StockMinKg%TYPE) IS
        BEGIN
        UPDATE PRODUCTOS 
            SET Caducidad=PRO_CADUCIDAD,stockMinKg=PRO_STOCK, nombre=PRO_NOMBRE
            WHERE ID_PRO=PRO_ID;
        END modificar;
        
    PROCEDURE eliminar
        (PRO_ID_Eliminar IN PRODUCTOS.ID_PRO%TYPE) IS
        BEGIN
            DELETE FROM PRODUCTOS WHERE PRO_ID_Eliminar =ID_PRO;
    END eliminar;
    
    FUNCTION obtenerId(PRO_NOMBRE IN PRODUCTOS.Nombre%TYPE) 
        RETURN PRODUCTOS.ID_PRO%TYPE IS
    resultado PRODUCTOS.ID_PRO%TYPE;
    BEGIN
    SELECT ID_PRO INTO resultado FROM PRODUCTOS WHERE nombre=PRO_NOMBRE;
    RETURN resultado; 
    END obtenerId;
    
END p_productos;
/
/****Precios*****/
CREATE OR REPLACE PACKAGE p_precios AS

    PROCEDURE crear
        (P_FECHA IN PRECIOS.fecha%TYPE,
        P_PRECIO IN PRECIOS.precioUnitario%TYPE,
        P_PRO IN PRECIOS.ID_PRO%TYPE);
END p_precios;
/
CREATE OR REPLACE PACKAGE BODY p_precios AS
    PROCEDURE crear
        (P_FECHA IN PRECIOS.fecha%TYPE,
        P_PRECIO IN PRECIOS.precioUnitario%TYPE,
        P_PRO IN PRECIOS.ID_PRO%TYPE) IS
        BEGIN
        INSERT INTO PRECIOS(fecha, precioUnitario, ID_PRO) 
        VALUES (P_FECHA, P_PRECIO, P_PRO);
    END crear;
END p_precios;
/
/****Lotes*****/
CREATE OR REPLACE PACKAGE p_Lotes AS

    CURSOR lotes_deProducto_porID(L_PRODUCTO IN LOTES.ID_PRO%TYPE) IS
        SELECT * FROM LOTES WHERE ID_PRO=L_PRODUCTO ORDER BY FECHAENTRADA;
        
    
    CURSOR lotes_deProducto_porNombre
    (L_NOMBRE_PRODUCTO IN PRODUCTOS.nombre%TYPE) IS
        SELECT * FROM LOTES WHERE ID_PRO=
        (SELECT ID_PRO FROM PRODUCTOS WHERE nombre=L_NOMBRE_PRODUCTO)
            ORDER BY FECHAENTRADA;
        
        PROCEDURE crear
        (L_FECHA IN LOTES.FechaEntrada%TYPE,
        L_CANTIDAD IN LOTES.Cantidad%TYPE,
        L_PRECIO IN LOTES.precioUnitarioAlMayor%TYPE,
        L_PRODUCTO IN PRODUCTOS.ID_PRO%TYPE);
END p_lotes;
/
CREATE OR REPLACE PACKAGE BODY p_Lotes AS
        PROCEDURE crear
        (L_FECHA IN LOTES.FechaEntrada%TYPE,
        L_CANTIDAD IN LOTES.Cantidad%TYPE,
        L_PRECIO IN LOTES.precioUnitarioAlMayor%TYPE,
        L_PRODUCTO IN PRODUCTOS.ID_PRO%TYPE) IS
        BEGIN
        INSERT INTO LOTES (fechaEntrada, cantidad, precioUnitarioAlMayor, ID_PRO) 
        VALUES(L_FECHA, L_CANTIDAD, L_PRECIO, L_PRODUCTO);
        END crear;
END p_lotes;
/
/****Ventas*****/

CREATE OR REPLACE PACKAGE p_Ventas AS
    
    PROCEDURE crear(V_CANTIDAD IN VENTAS.cantidadVendida%TYPE,
                    V_LOTE IN VENTAS.ID_L%TYPE);
END p_Ventas;
/
CREATE OR REPLACE PACKAGE BODY p_Ventas AS
    
    PROCEDURE crear(V_CANTIDAD IN VENTAS.cantidadVendida%TYPE,
                    V_LOTE IN VENTAS.ID_L%TYPE) IS
                auxPrecio PRECIOS.ID_PRE%TYPE;
                BEGIN
                SELECT ID_PRE INTO auxPrecio FROM productos_UltimosPrecios 
                NATURAL JOIN 
                    (SELECT ID_PRO FROM LOTES WHERE ID_L=V_LOTE);
                INSERT INTO VENTAS(fechaRealizacion, cantidadVendida, ID_L, ID_PRE)
                    VALUES(SYSDATE, V_CANTIDAD, V_LOTE, auxPrecio);
                END crear;
END p_Ventas;
/
/****Clientes*****/
CREATE OR REPLACE PACKAGE p_clientes AS
    PROCEDURE alta
        (C_PASS IN CLIENTES.pass%TYPE,
        C_NOMBRE IN CLIENTES.nombre%TYPE,
        C_APELLIDOS IN CLIENTES.apellidos%TYPE,
        C_TELEFONO IN CLIENTES.telefono%TYPE,
        C_EMAIL IN CLIENTES.email%TYPE,
        C_FECHA IN CLIENTES.fechaNacimiento%TYPE,
        C_DIRECCION IN CLIENTES.direccion%TYPE,
        C_TARJETA IN CLIENTES.tarjetaCredito%TYPE);
    PROCEDURE baja
    (C_ID IN CLIENTES.ID_U%TYPE);
END p_clientes;
/
CREATE OR REPLACE PACKAGE BODY p_clientes AS
    PROCEDURE alta
        (C_PASS IN CLIENTES.pass%TYPE,
        C_NOMBRE IN CLIENTES.nombre%TYPE,
        C_APELLIDOS IN CLIENTES.apellidos%TYPE,
        C_TELEFONO IN CLIENTES.telefono%TYPE,
        C_EMAIL IN CLIENTES.email%TYPE,
        C_FECHA IN CLIENTES.fechaNacimiento%TYPE,
        C_DIRECCION IN CLIENTES.direccion%TYPE,
        C_TARJETA IN CLIENTES.tarjetaCredito%TYPE) IS
        BEGIN
        INSERT INTO CLIENTES(nombre, apellidos, fechaNacimiento, direccion, telefono)
            VALUES(C_NOMBRE, C_APELLIDOS,C_FECHA,C_DIRECCION,C_TELEFONO);
        END alta;
    PROCEDURE baja
    (C_ID IN CLIENTES.ID_U%TYPE) IS
    BEGIN
    DELETE FROM CLIENTES WHERE C_ID=ID_U;
    END baja;
END p_clientes;
/
/****Pedidos*****/
CREATE OR REPLACE PACKAGE p_Pedidos AS
    
    PROCEDURE crear
    (PD_FECHAREALIZACION IN PEDIDOS.fechaRealizacion%TYPE,
    PD_FECHARECOGIDA IN PEDIDOS.fechaRecogida%TYPE,
    PD_CLIENTE IN PEDIDOS.ID_U%TYPE);
    
    PROCEDURE actualizar_EstadoPedido(PD_ID IN PEDIDOS.ID_PD%TYPE);
END p_Pedidos;
/
CREATE OR REPLACE PACKAGE BODY p_Pedidos AS
    PROCEDURE crear
    (PD_FECHAREALIZACION IN PEDIDOS.fechaRealizacion%TYPE,
    PD_FECHARECOGIDA IN PEDIDOS.fechaRecogida%TYPE,
    PD_CLIENTE IN PEDIDOS.ID_U%TYPE) IS 
    BEGIN 
    INSERT INTO PEDIDOS(fechaRealizacion, fechaRecogida, estadoPedido, ID_U)
        VALUES (PD_FECHAREALIZACION, PD_FECHARECOGIDA, 'PENDIENTE', PD_CLIENTE);
    END crear;
    
    PROCEDURE actualizar_EstadoPedido(PD_ID IN PEDIDOS.ID_PD%TYPE) IS
    auxPedido PEDIDOS%ROWTYPE;
    newEstadoPedido PEDIDOS.estadoPedido%TYPE;
    BEGIN
    SELECT * INTO auxPedido FROM PEDIDOS WHERE ID_PD=PD_ID;
    
    CASE auxPedido.estadoPedido
    WHEN 'DESPACHADO' THEN  newEstadoPedido:='ENTREGADO';
    WHEN 'PENDIENTE' THEN  newEstadoPedido:='DESPACHADO';
    WHEN 'ENTREGADO' THEN  newEstadoPedido:='ENTREGADO';
    END CASE;
    UPDATE PEDIDOS SET estadoPedido=newEstadoPedido WHERE ID_PD=PD_ID;
   
    END actualizar_EstadoPedido;
    

END p_Pedidos;
/
/****LineasPedido*****/

CREATE OR REPLACE PACKAGE p_LineasPedido AS
    PROCEDURE crear
    (lPD_CANTIDADKG IN LINEASPEDIDO.cantidadKG%TYPE,
    lPD_PRO IN LINEASPEDIDO.ID_PRO%TYPE,
    lPD_PD IN LINEASPEDIDO.ID_PD%TYPE);
    
    PROCEDURE eliminar(lPD_ID IN LINEASPEDIDO.ID_lPD%TYPE);

    PROCEDURE actualizar_Cantidad
    (lPD_ID IN LINEASPEDIDO.ID_lPD%TYPE,
    lPD_CANTIDADKG IN LINEASPEDIDO.cantidadKG%TYPE);
END p_LineasPedido;
/
CREATE OR REPLACE PACKAGE BODY p_LineasPedido AS
    PROCEDURE crear
    (lPD_CANTIDADKG IN LINEASPEDIDO.cantidadKG%TYPE,
    lPD_PRO IN LINEASPEDIDO.ID_PRO%TYPE,
    lPD_PD IN LINEASPEDIDO.ID_PD%TYPE) IS 
    BEGIN 
    INSERT INTO LINEASPEDIDO(cantidadKG, ID_PRO, ID_PD)
        VALUES(lPD_CANTIDADKG, lPD_PRO, lPD_PD);
    END crear;
    
    PROCEDURE eliminar (lPD_ID IN LINEASPEDIDO.ID_lPD%TYPE) IS
    BEGIN
    DELETE FROM LINEASPEDIDO WHERE ID_LPD=lPD_ID;
    END eliminar;

    PROCEDURE actualizar_Cantidad
    (lPD_ID IN LINEASPEDIDO.ID_lPD%TYPE,
    lPD_CANTIDADKG IN LINEASPEDIDO.cantidadKG%TYPE) IS
    BEGIN
    UPDATE LINEASPEDIDO SET cantidadKG=lPD_CANTIDADKG WHERE ID_lPD=lPD_ID;
    END actualizar_Cantidad;
END p_LineasPedido;
/

/****LineasPedidoEspecial*****/

CREATE OR REPLACE PACKAGE p_LineasPedidoEspecial AS
    PROCEDURE crear
    (lPD_CANTIDADKG IN LINEASPEDIDOESPECIAL.cantidadKG%TYPE,
    lPD_NOMBRE IN LINEASPEDIDOESPECIAL.nombre%TYPE,
    lPD_PRO IN LINEASPEDIDOESPECIAL.ID_PRO%TYPE,
    lPD_PD IN LINEASPEDIDOESPECIAL.ID_PD%TYPE);
    
    PROCEDURE eliminar(lPDe_ID IN LINEASPEDIDOESPECIAL.ID_lPDe%TYPE);

    PROCEDURE actualizar
    (lPDe_ID IN LINEASPEDIDOESPECIAL.ID_lPdE%TYPE,
    lPDe_CANTIDADKG IN LINEASPEDIDOESPECIAL.cantidadKG%TYPE,
    lPDe_NOMBRE IN LINEASPEDIDOESPECIAL.nombre%TYPE);
    
END p_LineasPedidoEspecial;
/
CREATE OR REPLACE PACKAGE BODY p_LineasPedidoEspecial AS
    PROCEDURE crear
    (lPD_CANTIDADKG IN LINEASPEDIDOESPECIAL.cantidadKG%TYPE,
    lPD_NOMBRE IN LINEASPEDIDOESPECIAL.nombre%TYPE,
    lPD_PRO IN LINEASPEDIDOESPECIAL.ID_PRO%TYPE,
    lPD_PD IN LINEASPEDIDOESPECIAL.ID_PD%TYPE) IS 
    BEGIN 
    INSERT INTO LINEASPEDIDOESPECIAL(cantidadKG, nombre, ID_PRO, ID_PD)
        VALUES(lPD_CANTIDADKG, lPD_NOMBRE ,lPD_PRO, lPD_PD);
    END crear;
    
    PROCEDURE eliminar (lPDe_ID IN LINEASPEDIDOESPECIAL.ID_lPdE%TYPE) IS
    BEGIN
    DELETE FROM LINEASPEDIDOESPECIAL WHERE ID_LPDe=lPDe_ID;
    END eliminar;

    PROCEDURE actualizar
    (lPDe_ID IN LINEASPEDIDOESPECIAL.ID_lPdE%TYPE,
    lPDe_CANTIDADKG IN LINEASPEDIDOESPECIAL.cantidadKG%TYPE,
    lPDe_NOMBRE IN LINEASPEDIDOESPECIAL.nombre%TYPE) IS
    BEGIN
    UPDATE LINEASPEDIDOESPECIAL SET cantidadKG=lPDe_CANTIDADKG, nombre=lPDe_NOMBRE 
        WHERE ID_lPdE=lPDe_ID;
    END actualizar;
END p_LineasPedidoEspecial;
/

/****LineasListaCompra*****/
CREATE OR REPLACE PACKAGE p_LineasListaCompra AS
    
    PROCEDURE crear
        (LLC_CANTIDAD IN LINEASLISTACOMPRA.CANTIDAD%TYPE,
        LLC_PRODUCTO IN LINEASLISTACOMPRA.ID_PRO%TYPE,
        LLC_FECHA IN LISTASCOMPRA.Fecha%TYPE);
    
    PROCEDURE marcarComprado(LLC_ID IN LINEASLISTACOMPRA.ID_LLC%TYPE);
       
       PROCEDURE eliminar
        (LLC_ID_Eliminar IN LINEASLISTACOMPRA.ID_LLC%TYPE);
END p_LineasListaCompra;
/
CREATE OR REPLACE PACKAGE BODY p_LineasListaCompra AS
    
    PROCEDURE crear
        (LLC_CANTIDAD IN LINEASLISTACOMPRA.CANTIDAD%TYPE,
        LLC_PRODUCTO IN LINEASLISTACOMPRA.ID_PRO%TYPE,
        LLC_FECHA IN LISTASCOMPRA.FECHA%TYPE) IS
        ListaCompra_ID ListasCompra.ID_LC%TYPE;
        BEGIN 
        SELECT ID_LC INTO ListaCompra_ID FROM LISTASCOMPRA 
            WHERE TRUNC(LISTASCOMPRA.fecha,'DD')=TRUNC(LLC_FECHA,'DD');
        INSERT INTO LINEASLISTACOMPRA(CANTIDAD, ID_PRO, ID_LC, estadoComprado)
        VALUES(LLC_CANTIDAD, LLC_PRODUCTO,ListaCompra_ID,'n');
    END crear;
    
    PROCEDURE marcarComprado(LLC_ID IN LINEASLISTACOMPRA.ID_LLC%TYPE) IS
    BEGIN
    UPDATE LINEASLISTACOMPRA SET estadoComprado='s' WHERE ID_LC=LLC_ID;
    END marcarComprado;
       
       PROCEDURE eliminar
        (LLC_ID_Eliminar IN LINEASLISTACOMPRA.ID_LLC%TYPE) IS
        BEGIN 
        DELETE FROM LINEASLISTACOMPRA WHERE ID_LLC=LLC_ID_Eliminar;
    END eliminar;
END p_LineasListaCompra;
/

/****Listas Compra*****/
CREATE OR REPLACE PACKAGE p_listasCompra AS
    
    PROCEDURE crear
        (LC_FECHA IN LISTASCOMPRA.Fecha%TYPE);
       
       PROCEDURE eliminar
        (LC_ID_Eliminar IN LISTASCOMPRA.ID_LC%TYPE);
END p_listasCompra;

/
CREATE OR REPLACE PACKAGE BODY p_ListasCompra AS
    
    PROCEDURE crear
        (LC_FECHA IN LISTASCOMPRA.Fecha%TYPE) IS
        BEGIN
          INSERT INTO LISTASCOMPRA(FECHA)
          VALUES (LC_FECHA);
        END crear;
        
    PROCEDURE eliminar
        (LC_ID_Eliminar IN LISTASCOMPRA.ID_LC%TYPE) IS
        BEGIN
            DELETE FROM LISTASCOMPRA WHERE LC_ID_Eliminar =ID_LC;
    END eliminar;
END p_ListasCompra;
/



/**************************************
PAQUETES DE ORGANIZACIÓN Y HORARIO
***************************************/

/*Funciones Auxiliares*/


/****Turnos*****/
CREATE OR REPLACE PACKAGE p_Turnos AS

    PROCEDURE crear
    (T_DIASEMANA IN TURNOS.diaSemana%TYPE,
    T_HORAINICIO IN TURNOS.horaApertura%TYPE,
    T_HORAFIN IN TURNOS.horaFinal%TYPE);
    
    PROCEDURE crear_TRIM
    (T_DIASEMANA VARCHAR2,
    T_HORAINICIO VARCHAR2,
    T_HORAFIN VARCHAR2);
    
    PROCEDURE eliminar(T_ID IN TURNOS.ID_T%TYPE);
    
    PROCEDURE modificar
    (T_ID IN TURNOS.ID_T%TYPE, 
    NEW_T_HORAINICIO IN TURNOS.horaApertura%TYPE,
    NEW_T_HORAFIN IN TURNOS.horaFinal%TYPE);

END p_Turnos;
/
CREATE OR REPLACE PACKAGE BODY p_Turnos AS
    
    FUNCTION fechaReferencia_VARCHAR2
        (diaSemana VARCHAR2, hora VARCHAR2) RETURN DATE IS
        resultado DATE;
        LUNES CONSTANT VARCHAR2(10) := '01/01/2001';
        MARTES CONSTANT VARCHAR2(10) :='02/01/2001';
        MIERCOLES CONSTANT VARCHAR2(10) :='03/01/2001';
        JUEVES CONSTANT VARCHAR2(10) :='04/01/2001';
        VIERNES CONSTANT VARCHAR2(10) :='05/01/2001';
        SABADO CONSTANT VARCHAR2(10) :='06/01/2001';
        DOMINGO CONSTANT VARCHAR2(10) :='07/01/2001';
        BEGIN
        CASE REPLACE(diaSemana, ' ', '')
        WHEN 'LUNES' THEN resultado:=TO_DATE(LUNES||' '||hora,'DD/MM/YYYY HH24:MI');
        WHEN 'MARTES' THEN resultado:=TO_DATE(MARTES||' '||hora,'DD/MM/YYYY HH24:MI');
        WHEN 'MIÉRCOLES' THEN resultado:=TO_DATE(MIERCOLES||' '||hora,'DD/MM/YYYY HH24:MI');
        WHEN 'JUEVES' THEN resultado:=TO_DATE(JUEVES||' '||hora,'DD/MM/YYYY HH24:MI');
        WHEN 'VIERNES' THEN resultado:=TO_DATE(VIERNES||' '||hora,'DD/MM/YYYY HH24:MI');
        WHEN 'SÁBADO' THEN resultado:=TO_DATE(SABADO||' '||hora,'DD/MM/YYYY HH24:MI');
        WHEN 'DOMINGO' THEN resultado:=TO_DATE(DOMINGO||' '||hora,'DD/MM/YYYY HH24:MI');
        END CASE;
        RETURN resultado;
    END fechaReferencia_VARCHAR2;
    
    FUNCTION fechaReferencia_DATE
        (fecha DATE, hora VARCHAR2) RETURN DATE IS
        BEGIN
        RETURN fechaReferencia_VARCHAR2(TRIM(TO_CHAR(fecha,'DAY')), hora);
    END fechaReferencia_DATE;
    
    PROCEDURE crear
    (T_DIASEMANA IN TURNOS.diaSemana%TYPE,
    T_HORAINICIO IN TURNOS.horaApertura%TYPE,
    T_HORAFIN IN TURNOS.horaFinal%TYPE) IS 
    auxHoraInicio DATE;
    auxHoraFin DATE;
    BEGIN 
    auxHoraInicio := fechaReferencia_VARCHAR2
        (T_DIASEMANA, TO_CHAR(T_HORAINICIO,'HH24:MI'));
    auxHoraFin := fechaReferencia_VARCHAR2
        (T_DIASEMANA, TO_CHAR(T_HORAFIN,'HH24:MI'));
    INSERT INTO TURNOS(diaSemana,horaApertura, horaFinal) 
        VALUES(T_DIASEMANA,auxHoraInicio,auxHoraFin);
    END crear;
    
    PROCEDURE crear_TRIM
    (T_DIASEMANA VARCHAR2,
    T_HORAINICIO VARCHAR2,
    T_HORAFIN VARCHAR2) IS
    BEGIN
    crear(REPLACE(T_DIASEMANA, ' ', ''),
    fechaReferencia_VARCHAR2(T_DIASEMANA,T_HORAINICIO),
    fechaReferencia_VARCHAR2(T_DIASEMANA,T_HORAFIN));
    END crear_TRIM;
    
    PROCEDURE eliminar(T_ID IN TURNOS.ID_T%TYPE) IS
    BEGIN
    DELETE FROM TURNOS WHERE ID_T=T_ID;
    END eliminar;
    
    PROCEDURE modificar
    (T_ID IN TURNOS.ID_T%TYPE, 
    NEW_T_HORAINICIO IN TURNOS.horaApertura%TYPE,
    NEW_T_HORAFIN IN TURNOS.horaFinal%TYPE) IS
    BEGIN
    UPDATE TURNOS SET horaApertura=NEW_T_HORAINICIO, horaFinal=NEW_T_HORAFIN
        WHERE ID_T=T_ID;
    END modificar;
    

END p_Turnos;
/
/****Jornadas*****/
CREATE OR REPLACE PACKAGE p_Jornadas AS
    
    PROCEDURE crear
    (J_TURNO IN TURNOS.ID_T%TYPE,
    J_EMPLEADO IN JORNADAS.ID_U%TYPE,
    J_FECHA DATE);
    
    PROCEDURE eliminar
    (J_ID IN JORNADAS.ID_J%TYPE);

END p_Jornadas;
/
CREATE OR REPLACE PACKAGE BODY p_Jornadas AS

    FUNCTION asegurar_FechaYHora
        (fecha DATE, hora DATE) RETURN DATE IS
        BEGIN
        RETURN TO_DATE
        (TO_CHAR(fecha,'DD/MM/YYYY')||' '||
        TO_CHAR(hora,'HH24:MI'),'DD/MM/YYYY HH24:MI');
    END asegurar_FechaYHora;

    PROCEDURE crear
    (J_TURNO IN TURNOS.ID_T%TYPE,
    J_EMPLEADO IN JORNADAS.ID_U%TYPE,
    J_FECHA DATE) IS 
    auxTurno TURNOS%ROWTYPE;
    J_horaInicio JORNADAS.fechaHoraInicio%TYPE;
    J_horaSalida JORNADAS.fechaHoraSalida%TYPE;
    BEGIN
    J_horaInicio :=asegurar_FechaYHora(J_FECHA,auxTurno.horaApertura);
    J_horaSalida :=asegurar_FechaYHora(J_FECHA,auxTurno.horaFinal);
    
    SELECT * INTO auxTurno FROM TURNOS WHERE ID_T=J_TURNO;
    
    INSERT INTO JORNADAS(fechaHoraInicio, fechaHoraSalida, ID_U) 
        VALUES(J_horaInicio,J_horaSalida,J_EMPLEADO);
    END crear;
    
    PROCEDURE eliminar
    (J_ID IN JORNADAS.ID_J%TYPE) IS
    BEGIN
    DELETE FROM INCIDENCIAS WHERE ID_J=J_ID;
    END eliminar;

END p_Jornadas;
/

/****Incidencias*****/
CREATE OR REPLACE PACKAGE p_Incidencias AS

    PROCEDURE crear
    (I_ASUNTO IN INCIDENCIAS.asunto%TYPE,
    I_DESCRIPCION IN INCIDENCIAS.descripcion%TYPE,
    I_EMPLEADO IN INCIDENCIAS.ID_U%TYPE,
    I_JORNADA IN INCIDENCIAS.ID_J%TYPE);
    
    PROCEDURE modificar
    (I_ID IN INCIDENCIAS.ID_IN%TYPE,
    I_ASUNTO IN INCIDENCIAS.asunto%TYPE,
    I_DESCRIPCION IN INCIDENCIAS.descripcion%TYPE);
 
    PROCEDURE actualizar_estadoIncidencia
    (I_ID IN INCIDENCIAS.ID_IN%TYPE,
    I_ESTADO IN INCIDENCIAS.estadoIncidencia%TYPE);
    
    PROCEDURE eliminar(IN_ID IN INCIDENCIAS .ID_IN%TYPE);

END p_Incidencias;
/
CREATE OR REPLACE PACKAGE BODY p_Incidencias AS

    PROCEDURE crear
    (I_ASUNTO IN INCIDENCIAS.asunto%TYPE,
    I_DESCRIPCION IN INCIDENCIAS.descripcion%TYPE,
    I_EMPLEADO IN INCIDENCIAS.ID_U%TYPE,
    I_JORNADA IN INCIDENCIAS.ID_J%TYPE) IS
    BEGIN
    INSERT INTO INCIDENCIAS(asunto, descripcion, estadoIncidencia, ID_U, ID_J)
        VALUES(I_ASUNTO, I_DESCRIPCION, 'pendiente' ,I_EMPLEADO,I_JORNADA);
    END crear;
    
    PROCEDURE modificar
    (I_ID IN INCIDENCIAS.ID_IN%TYPE,
    I_ASUNTO IN INCIDENCIAS.asunto%TYPE,
    I_DESCRIPCION IN INCIDENCIAS.descripcion%TYPE)IS
    BEGIN
    UPDATE INCIDENCIAS SET asunto=I_ASUNTO, descripcion=I_DESCRIPCION WHERE ID_IN=I_ID;
    END modificar;
    
    PROCEDURE actualizar_estadoIncidencia
    (I_ID IN INCIDENCIAS.ID_IN%TYPE,
    I_ESTADO IN INCIDENCIAS.estadoIncidencia%TYPE) IS 
    BEGIN
    UPDATE INCIDENCIAS SET estadoIncidencia=I_ESTADO WHERE ID_IN=I_ID;
    END actualizar_estadoIncidencia;
    
    PROCEDURE eliminar(IN_ID IN INCIDENCIAS .ID_IN%TYPE) IS
    BEGIN
    DELETE FROM INCIDENCIAS WHERE ID_IN=IN_ID;
    END eliminar;
END p_Incidencias;
/


/****Empleados*****/
CREATE OR REPLACE PACKAGE p_Empleados AS

    PROCEDURE crear
    (E_NOMBRE IN EMPLEADOS.nombre%TYPE,
    E_APELLIDOS IN EMPLEADOS.apellidos%TYPE);
    
    PROCEDURE modificar_BajaTemporal(
    E_ID IN EMPLEADOS.ID_U%TYPE, 
    E_bajaTemporal IN EMPLEADOS.bajaTemporal%TYPE);
    

END p_Empleados;
/
CREATE OR REPLACE PACKAGE BODY p_Empleados AS

    PROCEDURE crear
    (E_NOMBRE IN EMPLEADOS.nombre%TYPE,
    E_APELLIDOS IN EMPLEADOS.apellidos%TYPE) IS
    BEGIN
    INSERT INTO EMPLEADOS(nombre, apellidos, bajaTemporal)
        VALUES(E_NOMBRE,E_APELLIDOS,'n');
    END crear;
    
    PROCEDURE modificar_BajaTemporal(
    E_ID IN EMPLEADOS.ID_U%TYPE, 
    E_bajaTemporal IN EMPLEADOS.bajaTemporal%TYPE) IS
    BEGIN
    UPDATE EMPLEADOS SET bajaTemporal=E_bajaTemporal WHERE ID_U=E_ID;
    END modificar_BajaTemporal;
    
END p_Empleados;