/**************************************
SECUENCIAS DE APROVISIONAMIENTO Y PEDIDOS
***************************************/
DROP SEQUENCE SEC_CATEGORIAS;
DROP SEQUENCE SEC_PRODUCTOS;
DROP SEQUENCE SEC_PRECIOS;
DROP SEQUENCE SEC_LOTES;
DROP SEQUENCE SEC_VENTAS;
DROP SEQUENCE SEC_LINEASVENTA;
DROP SEQUENCE SEC_USUARIOS;
DROP SEQUENCE SEC_PEDIDOS;
DROP SEQUENCE SEC_LINEASPEDIDO;
DROP SEQUENCE SEC_LINEASPEDIDOESPECIAL;
DROP SEQUENCE SEC_LISTASCOMPRA;
DROP SEQUENCE SEC_LINEASLISTACOMPRA;

/*Funciones Auxiliares*/

/****Categorias*****/
CREATE SEQUENCE SEC_CATEGORIAS;

CREATE OR REPLACE TRIGGER CREA_ID_CATEGORIA
BEFORE INSERT ON CATEGORIAS
FOR EACH ROW
BEGIN
    SELECT SEC_CATEGORIAS.NEXTVAL INTO :NEW.ID_CAT FROM DUAL;
END;
/

/****PRODUCTOS*****/
CREATE SEQUENCE SEC_PRODUCTOS;

CREATE OR REPLACE TRIGGER CREA_ID_PRODUCTO
BEFORE INSERT ON PRODUCTOS
FOR EACH ROW
BEGIN
    SELECT SEC_PRODUCTOS.NEXTVAL INTO :NEW.ID_PRO FROM DUAL;
END;
/

/****Lotes*****/
CREATE SEQUENCE SEC_LOTES;

CREATE OR REPLACE TRIGGER CREA_ID_LOTES
BEFORE INSERT ON LOTES
FOR EACH ROW
BEGIN
    SELECT SEC_LOTES.NEXTVAL INTO :NEW.ID_L FROM DUAL;
END;
/

/****Precios*****/

CREATE SEQUENCE SEC_PRECIOS;

CREATE OR REPLACE TRIGGER CREA_ID_PRECIOS
BEFORE INSERT ON PRECIOS
FOR EACH ROW
BEGIN
    SELECT SEC_PRECIOS.NEXTVAL INTO :NEW.ID_PRE FROM DUAL;
END;
/

/****Ventas*****/
CREATE SEQUENCE SEC_VENTAS;

CREATE OR REPLACE TRIGGER CREA_ID_VENTAS
BEFORE INSERT ON VENTAS
FOR EACH ROW
BEGIN
    SELECT SEC_VENTAS.NEXTVAL INTO :NEW.ID_V FROM DUAL;
END;
/

/****LineasVenta*****/
CREATE SEQUENCE SEC_LINEASVENTA;

CREATE OR REPLACE TRIGGER CREA_ID_LINEASVENTA
BEFORE INSERT ON LINEASVENTA
FOR EACH ROW
BEGIN
    SELECT SEC_LINEASVENTA.NEXTVAL INTO :NEW.ID_V FROM DUAL;
END;
/

/****Clientes #USUARIO# *****/
CREATE SEQUENCE SEC_USUARIOS;

CREATE OR REPLACE TRIGGER CREA_ID_CLIENTES
BEFORE INSERT ON CLIENTES
FOR EACH ROW
BEGIN
    SELECT SEC_USUARIOS.NEXTVAL INTO :NEW.ID_U FROM DUAL;
END;
/

/****Pedidos*****/
CREATE SEQUENCE SEC_PEDIDOS;

CREATE OR REPLACE TRIGGER CREA_ID_PEDIDOS
BEFORE INSERT ON PEDIDOS
FOR EACH ROW
BEGIN
    SELECT SEC_PEDIDOS.NEXTVAL INTO :NEW.ID_Pd FROM DUAL;
END;
/

/****LineasPedido*****/
CREATE SEQUENCE SEC_LINEASPEDIDO;

CREATE OR REPLACE TRIGGER CREA_ID_LINEASPEDIDO
BEFORE INSERT ON LINEASPEDIDO
FOR EACH ROW
BEGIN
    SELECT SEC_LINEASPEDIDO.NEXTVAL INTO :NEW.ID_LPd FROM DUAL;
END;
/

/****LineasPedidoEspecial*****/
CREATE SEQUENCE SEC_LINEASPEDIDOESPECIAL;

CREATE OR REPLACE TRIGGER CREA_ID_LINEASPEDIDOESPECIAL
BEFORE INSERT ON LINEASPEDIDOESPECIAL
FOR EACH ROW
BEGIN
    SELECT SEC_LINEASPEDIDOESPECIAL.NEXTVAL INTO :NEW.ID_LPdE FROM DUAL;
END;
/
/****Listas Compra*****/
CREATE SEQUENCE SEC_LISTASCOMPRA;

CREATE OR REPLACE TRIGGER CREA_ID_LISTASCOMPRA
BEFORE INSERT ON LISTASCOMPRA
FOR EACH ROW
BEGIN
    SELECT SEC_LISTASCOMPRA.NEXTVAL INTO :NEW.ID_LC FROM DUAL;
END;
/
/****Lineas ListaCompra*****/
CREATE SEQUENCE SEC_LINEASLISTACOMPRA;

CREATE OR REPLACE TRIGGER CREA_ID_LINEASLISTACOMPRA
BEFORE INSERT ON LINEASLISTACOMPRA
FOR EACH ROW
BEGIN
    SELECT SEC_LINEASLISTACOMPRA.NEXTVAL INTO :NEW.ID_LLC FROM DUAL;
END;
/
/**************************************
SECUENCIAS DE ORGANIZACIÓN Y HORARIO
***************************************/
DROP SEQUENCE SEC_INCIDENCIAS;
DROP SEQUENCE SEC_JORNADAS;
DROP SEQUENCE SEC_TURNOS;

/****Turnos*****/
CREATE SEQUENCE SEC_TURNOS;

CREATE OR REPLACE TRIGGER CREA_ID_TURNOS
BEFORE INSERT ON TURNOS
FOR EACH ROW
BEGIN
    SELECT SEC_TURNOS.NEXTVAL INTO :NEW.ID_T FROM DUAL;
END;
/

/****Empleados #USUARIO# *****/

CREATE OR REPLACE TRIGGER CREA_ID_EMPLEADOS
BEFORE INSERT ON EMPLEADOS
FOR EACH ROW
BEGIN
    SELECT SEC_USUARIOS.NEXTVAL INTO :NEW.ID_U FROM DUAL;
END;
/

/****Encargados #USUARIO# *****/

CREATE OR REPLACE TRIGGER CREA_ID_ENCARGADOS
BEFORE INSERT ON ENCARGADOS
FOR EACH ROW
BEGIN
    SELECT SEC_USUARIOS.NEXTVAL INTO :NEW.ID_U FROM DUAL;
END;
/
/****Jornada*****/
CREATE SEQUENCE SEC_JORNADAS;

CREATE OR REPLACE TRIGGER CREA_ID_JORNADAS
BEFORE INSERT ON JORNADAS
FOR EACH ROW
BEGIN
    SELECT SEC_JORNADAS.NEXTVAL INTO :NEW.ID_J FROM DUAL;
END;
/

/****Incidencias*****/
CREATE SEQUENCE SEC_INCIDENCIAS;

CREATE OR REPLACE TRIGGER CREA_ID_INCIDENCIAS
BEFORE INSERT ON INCIDENCIAS
FOR EACH ROW
BEGIN
    SELECT SEC_INCIDENCIAS.NEXTVAL INTO :NEW.ID_IN FROM DUAL;
END;
/