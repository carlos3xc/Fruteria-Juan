/**************************************
TABLAS DE APROVISIONAMIENTO Y PEDIDOS
***************************************/
/*Borrado de Tablas (Orden de dependencias)*/
DROP TABLE LineasPedido;
DROP TABLE LineasPedidoEspecial;
DROP TABLE Pedidos;
DROP TABLE Clientes;

DROP TABLE LineasListaCompra;
DROP TABLE ListasCompra;
DROP TABLE LineasVenta;
DROP TABLE Ventas;
DROP TABLE Lotes;
DROP TABLE Precios;
DROP TABLE Productos;
DROP TABLE Categorias;

/*Definición de Tablas*/

CREATE TABLE Categorias
(ID_CAT NUMBER(5) PRIMARY KEY,
nombre VARCHAR2(30) NOT NULL UNIQUE,
ID_PCAT NUMBER(5),
    CONSTRAINT no_autoanidar CHECK(ID_CAT != ID_PCAT),
    FOREIGN KEY(ID_PCAT) REFERENCES Categorias ON DELETE SET NULL);/

CREATE TABLE Productos
(ID_PRO NUMBER(5) PRIMARY KEY,
nombre VARCHAR2(20) NOT NULL UNIQUE,
caducidad INTEGER,
    CONSTRAINT numeroDeDiasPositivo CHECK(0<=caducidad),
stockMinKg NUMBER(9,3),
    CONSTRAINT stockMinimo_Positivo CHECK(0<=stockMinKg),
ID_CAT NUMBER(5),
    FOREIGN KEY(ID_CAT) REFERENCES Categorias ON DELETE SET NULL);/

CREATE TABLE Precios(
ID_PRE NUMBER(6) PRIMARY KEY,
fecha DATE NOT NULL,
precioUnitario NUMBER(8,3) NOT NULL, 
    CONSTRAINT precioUnitario_Positivo CHECK(0<=precioUnitario),
ID_PRO NUMBER(5) NOT NULL, FOREIGN KEY(ID_PRO) REFERENCES Productos ON DELETE CASCADE);/

CREATE TABLE Lotes(
ID_L NUMBER(6) PRIMARY KEY,
fechaEntrada DATE NOT NULL,
cantidad NUMBER(9,3) NOT NULL,
precioUnitarioAlMayor NUMBER(8,3) NOT NULL,
ID_PRO NUMBER(5), FOREIGN KEY(ID_PRO) REFERENCES Productos);/

CREATE TABLE Ventas(
ID_V NUMBER(6) PRIMARY KEY,
fechaRealizacion DATE NOT NULL);/

CREATE TABLE LineasVenta(
ID_LV NUMBER(6) PRIMARY KEY,
cantidadVendida NUMBER(9,3) NOT NULL,
ID_L NUMBER(5), FOREIGN KEY(ID_L) REFERENCES Lotes ON DELETE CASCADE,
ID_PRE NUMBER(5), FOREIGN KEY(ID_PRE) REFERENCES Precios,
ID_V NUMBER(6), FOREIGN KEY(ID_L) REFERENCES Ventas);/

CREATE TABLE Clientes
(ID_U NUMBER(6) PRIMARY KEY,
pass VARCHAR2(30) NOT NULL,
nombre VARCHAR2(30) NOT NULL,
apellidos VARCHAR2(50) NOT NULL,
telefono VARCHAR2(9) NOT NULL,
email VARCHAR2(30) NOT NULL,
fechaNacimiento DATE NOT NULL,
direccion VARCHAR2(120) NOT NULL,
tarjetaCredito VARCHAR(12));/

CREATE TABLE Pedidos
(ID_Pd NUMBER(6) PRIMARY KEY,
fechaRealizacion DATE NOT NULL,
fechaRecogida DATE NOT NULL,
estadoPedido VARCHAR2(10), CONSTRAINT enumeradoEstadosPedido
    CHECK( estadoPedido IN ('PENDIENTE','DESPACHADO','ENTREGADO') ),
ID_U NUMBER(6), FOREIGN KEY(ID_U) REFERENCES Clientes,
ID_V NUMBER(6), FOREIGN KEY(ID_V) REFERENCES Ventas);/

CREATE TABLE LineasPedido(
ID_lPd NUMBER(3) PRIMARY KEY,
cantidadKg NUMBER(9,3) NOT NULL,
ID_PRO NUMBER(5), FOREIGN KEY(ID_PRO) REFERENCES Productos,
ID_PD NUMBER(6), FOREIGN KEY(ID_PD) REFERENCES Pedidos ON DELETE CASCADE);/

CREATE TABLE LineasPedidoEspecial(
ID_lPdE NUMBER(3) PRIMARY KEY,
cantidadKg NUMBER(9,3) NOT NULL,
nombre VARCHAR2(30) NOT NULL,
ID_PRO NUMBER(5), FOREIGN KEY(ID_PRO) REFERENCES Productos,
ID_PD NUMBER(6), FOREIGN KEY(ID_PD) REFERENCES Pedidos ON DELETE CASCADE);/

CREATE TABLE ListasCompra
(ID_LC NUMBER(4) PRIMARY KEY,
fecha DATE UNIQUE NOT NULL);/

CREATE TABLE LineasListaCompra(
ID_lLC NUMBER(6) PRIMARY KEY,
cantidad NUMBER(9,3) NOT NULL,
ID_PRO NUMBER(6), FOREIGN KEY(ID_PRO) REFERENCES Productos ON DELETE CASCADE,
ID_LC NUMBER(4), FOREIGN KEY(ID_LC) REFERENCES ListasCompra ON DELETE CASCADE,
estadoComprado CHAR(1) NOT NULL,
    CONSTRAINT estadoComprado_Si_o_No CHECK(estadoComprado IN ('s','n')));/

/**************************************
TABLAS DE ORGANIZACIÓN DE HORARIOS
***************************************/

/*Borrado de Tablas (Orden Jerárquico)*/
DROP TABLE Incidencias;
DROP TABLE Jornadas;
DROP TABLE Empleados;
DROP TABLE Encargados;
DROP TABLE Turnos;

/*Definición de Tablas*/

CREATE TABLE Turnos(
ID_T NUMBER(4) PRIMARY KEY,
diaSemana VARCHAR2(16),
CONSTRAINT diaSemanaLaborable
  CHECK( diaSemana IN ('LUNES','MARTES','MIÉRCOLES','JUEVES','VIERNES','SÁBADO') ),
horaApertura DATE NOT NULL,
horaFinal DATE NOT NULL,
CONSTRAINT horaInicioAntesDeHoraFin CHECK(horaApertura<horaFinal));/

CREATE TABLE Empleados
(ID_U NUMBER(6) PRIMARY KEY,
pass VARCHAR2(30) NOT NULL,
nombre VARCHAR2(30) NOT NULL,
apellidos VARCHAR2(50) NOT NULL,
telefono VARCHAR2(9) NOT NULL,
email VARCHAR2(30) NOT NULL,
fechaNacimiento DATE NOT NULL,
direccion VARCHAR2(120) NOT NULL,
bajaTemporal CHAR(1),
    CHECK(bajaTemporal IN ('s','n')),
numeroDeCuenta VARCHAR2(24) NOT NULL,
nss VARCHAR2(12) NOT NULL UNIQUE);/

CREATE TABLE Encargados
(ID_U NUMBER(6) PRIMARY KEY,
pass VARCHAR2(30) NOT NULL,
nombre VARCHAR2(30) NOT NULL,
apellidos VARCHAR2(50) NOT NULL,
telefono VARCHAR2(9) NOT NULL,
email VARCHAR2(30) NOT NULL,
fechaNacimiento DATE NOT NULL,
direccion VARCHAR2(120) NOT NULL);/

CREATE TABLE Jornadas(
ID_J NUMBER(9) PRIMARY KEY,
fechaHoraInicio DATE,
fechaHoraSalida DATE,
CONSTRAINT horaInicioAntesDeHoraSalida 
    CHECK(fechaHoraInicio<fechaHoraSalida),
ID_U NUMBER(3), FOREIGN KEY(ID_U) REFERENCES EMPLEADOS);/

CREATE TABLE Incidencias(
ID_IN NUMBER(6) PRIMARY KEY,
asunto VARCHAR2(30) NOT NULL,
descripcion VARCHAR2(120) NOT NULL,
estadoIncidencia VARCHAR2(9) NOT NULL,
    CHECK( estadoIncidencia IN ('PENDIENTE','ACEPTADA','RECHAZADA') ),
ID_U NUMBER(3), FOREIGN KEY(ID_U) REFERENCES Empleados,
ID_J NUMBER(6), FOREIGN KEY(ID_J) REFERENCES Jornadas ON DELETE SET NULL);/
