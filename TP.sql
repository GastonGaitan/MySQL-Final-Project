drop database if exists mobilidad_sustentable;

create database mobilidad_sustentable;

use mobilidad_sustentable;

create table TipoUsuario(
idTipoUsuario int not null default 1, -- El usuario 1 es el comun y el 2 es el premium. Por defecto el usuario va a ser 1. 
descripcion text,
primary key (idTipoUsuario),
check(idTipoUsuario = 1 or idTipoUsuario = 2)
);

insert into tipoUsuario(idTipoUsuario, descripcion)
values(1, 'basico'),
(2, 'premium');

create table Acceso( -- Un acceso debe estar relacionado si o si con algun Usuario
idAcceso int auto_increment, 
CUIL char(11) not null unique,
contraseña varchar(30),
email varchar(100),
idTipoUsuario int not null,
primary key (idAcceso),
foreign key (idTipoUsuario) references TipoUsuario(idTipoUsuario)
);


create table Usuario( -- Un usario puede estar asociado a uno o ningun acceso la cuenta podria ser creada pero entre que se verifica y demas no hay ningun acceso
CUIL char(11) not null unique,
nombre varchar(50),
apellido varchar(50),
dni char(8) unique, -- Char de 8 verifica que si o si el dni tenga 8 caracteres
TipoDocumento int not null,
email varchar(50) unique,
imagen_rostro varchar(2),
fecha_nacimiento date,
codLocalidad int not null,
pais_residencia int not null,
estado varchar(11),
constraint check ((estado = 'activo') or (estado = 'sin validar') or (estado = 'inactivo')),
constraint check ((imagen_rostro = 'si') or (imagen_rostro = 'no')),
primary key (CUIL)
-- Agregar las 3 foreign key faltantes despues con un alter table (TipoDocumento, codLocalidad y pais_residencia)
);

create table Pais(
idPais int not null unique,
nombrePais varchar(50),
primary key (idPais)
);

create table TipoDocumento(
id_documento char(8) not null unique,
descripcion text,
pais_origen int not null,
primary key (id_documento),
foreign key (pais_origen) references pais(idPais)
);
-- Seteo pais_residencia de usuario como clave foranea que apunta a pais
alter table Usuario add foreign key (pais_residencia) references Pais(idPais);

-- Seteo dni de usuario como foreign key que apunta a tipo_documento
alter table Usuario add foreign key (dni) references tipodocumento(id_documento);

-- Seteo cuil de acceso como foreign key que apunta a cuil de usuario
alter table Acceso add foreign key (cuil) references usuario(cuil);

create table Viaje(
idviaje int not null auto_increment,
cuilusuario char(11) not null,
fechaInicio date not null,
horaInicio time not null,
fechaFin date default null,
horaFin time default null,
idRodado int not null, 
idAnclajeInicio int not null,
idAnclajeDestino int default null,
primary key (idviaje),
foreign key (cuilusuario) references usuario(cuil)
);

create table Disponibilidad(
idRegistroRodadoAnclaje int unique auto_increment not null,
idRodado int not null unique,
idAnclaje int default null,
fecha_estado date,
hora_estado time,
-- foreign key (idRodado) references viaje(idRodado)
-- foreign key (idAnclaje) references viaje(idAnclaje)
primary key (idRegistroRodadoAnclaje)
);

create table TipoModelo(
idModelo int not null unique,
descripcion text
);

create table Rodado(
idRodado int not null unique,
nombre varchar(60),
descripcion text,
idModelo int not null,
estado int,
constraint check ((estado = 1) or (estado = 2) or (estado = 3) or (estado = 4)),
primary key (idRodado),
foreign key (idModelo) references TipoModelo(idModelo)
);

create table Anclaje(
idAnclaje int not null unique,
idPuesto int not null,
estado varchar(30),
constraint check ((estado = 'disponible') or (estado = 'no disponible') or (estado = 'libre') or (estado = 'reservado')),
primary key (idAnclaje)
);

-- Agrego a disponibilidad una foreign key que apunte a la foreign key de id rodado de viaje
alter table Disponibilidad add foreign key (idRodado) references rodado(idRodado);
alter table Disponibilidad add foreign key (idAnclaje) references anclaje(idAnclaje);
alter table Rodado add foreign key (idModelo) references tipomodelo(idModelo);
alter table viaje add foreign key (idRodado) references disponibilidad(idRodado);
alter table viaje add foreign key (idanclajeinicio) references anclaje(idanclaje);
alter table viaje add foreign key (idanclajedestino) references anclaje(idanclaje);

-- Creartabla puesto
-- Conectar puesto con alclaje
-- Conectar puesto con localidad
-- Conectar localidad con usuario

create table puesto(
idPuesto int not null unique,
nombre varchar(60),
direccion varchar(60),
idLocalidad int not null,
latitud int not null,
longitud int not null,
primary key (idPuesto)
);

create table localidad(
idLocalidad int not null,
nombreLocalidad varchar(50),
primary key (idLocalidad)
);

alter table puesto add foreign key(idLocalidad) references localidad(idLocalidad);

alter table usuario add foreign key(codLocalidad) references localidad(idLocalidad);


-- a. cargar 10 rodados:

-- Antes de cargar el rodado hay que incluir los modelos. Los modelos ya que son claves foraneas
-- que deberan ser incluidas en la entidad rodado:
insert into tipoModelo(idModelo, descripcion)
values(1, 'Modelo Basic: Bicicleta clasica con canasto rodado 16. No posee cambios. Modelo mas economico'),
(2,'Modelo Sport: Bicicleta todoterrerno rodado 20. Posee cambios. Modelo mas caro.');

-- Ahora si inserto los rodados:
insert into Rodado(idRodado, nombre, descripcion, idModelo, estado)
values
(1, 'Basic', 'Bicicleta Basica.', 1, '1'),
(2, 'Sport', 'Bicicleta Todoterreno', 2, '2'),
(3, 'Basic', 'Bicicleta Basica', 1, '3'), -- Bicicleta 3 no puede ser utilizada
(4, 'Sport', 'Bicicleta Todoterreno', 2, '4'),
(5, 'Basic', 'Bicicleta Basica', 1, '1'), -- Bicicleta 5 no puede ser utilizada
(6, 'Sport', 'Bicicleta Todoterreno', 2, '1'),
(7, 'Basic', 'Bicicleta Basica', 1, '1'),
(8, 'Sport', 'Bicicleta Todoterreno', 2, '2'),
(9, 'Basic', 'Bicicleta Basica', 1, '3'),
(10, 'Sport', 'Bicicleta Todoterreno', 2, '1');

-- b. Generar 4 puestos con sus correspondientes puntos de anclaje.

-- Primero agrego atributos a la tabla localidad ya que son claves foraneas de los puestos.
insert into localidad (idlocalidad, nombrelocalidad)
values(1, 'Palermo'),
(2, 'Recoleta'),
(3, 'Belgrano'),
(4, 'San Pablo'),
(5, 'Santiago');

alter table anclaje add foreign key(idpuesto) references puesto(idpuesto);

-- Tuve que cambiar esto porque sino me saltaba error
SET FOREIGN_KEY_CHECKS=0;

-- Luego ingreso los datos del puesto.
insert into puesto(idPuesto, nombre, direccion, idlocalidad, latitud, longitud)
values
(1, 'Plaza Serrano', '9 Julio 500', 2, -36, -73),
(2, 'Facultad de Derecho', 'Las Heras 2599', 3, -40, -80),
(3, 'Bulnes', 'Rivadavia 500', 1, -8, -73),
(4, 'Facultad de medicina', 'Genral Pinto 1709', 1, -6, -3);

-- Vincular los puestos con sus puntos de anclake
insert into Anclaje(idAnclaje, idPuesto, estado)
values
(1, 1, 'No disponible'),
(2, 1, 'Libre'),
(3, 1, 'Reservado'),
(4, 1, 'No disponible'),

(5, 2, 'No disponible'),
(6, 2, 'No disponible'),
(7, 2, 'Libre'),
(8, 2, 'Reservado'),

(9, 3, 'No disponible'),
(10, 3, 'Libre'),
(11, 3, 'No disponible'),
(12, 3, 'Reservado'),

(13, 4, 'No disponible'),
(14, 4, 'No disponible'),
(15, 4, 'No disponible'),
(16, 4, 'No disponible');

select * from tipodocumento;

-- 5 usuarios con todos sus datos
insert into pais(idPais, nombrePais)
values(1, 'Argentina'),
(2, 'Chile'),
(3, 'Brasil');

-- Primero inserto los tipo de documento.
insert into tipodocumento(id_documento, descripcion, pais_origen)
values(1, 'DNI', 1),
(2, 'RUN', 2),
(3, 'CPF', 3);

select * from tipodocumento;

-- Agrego los 3 paises

-- d. Agregar 5 usuarios con todos sus datos:
insert into usuario(cuil, nombre, apellido, dni, tipodocumento, email, imagen_rostro,
 fecha_nacimiento, codlocalidad, pais_residencia, estado)
values
('20411343457', 'Gastón', 'Gaitan', '41134345', 1, 'gaston-gaitan@hotmail.com', 'si', '1998-05-13', 1, 1, 'Activo'),
('21421473458', 'Sofia', 'Mangiantini', '42147345', 1, 'sofia-mangiantini@hotmail.com', 'no', '1998-06-13', 2, 1, 'Inactivo'),
('23483534810', 'Vladimir', 'Tapia', '48353481', 2, 'vladimir-tapia@hotmail.com', 'no', '1945-02-23', 4, 2, 'Sin validar'),
('56441348459', 'Alberto', 'Pipistrella', '44134845', 3, 'alberto-pipistrella@hotmail.com', 'si', '1980-05-18', 5, 3, 'Activo'),
('15412355697', 'Vicente', 'Ismael', '41235569', 1, 'vicente-ismael@hotmail.com', 'no', '2001-12-11', 2, 1, 'Activo');

-- e. Simular 5 viajes por usuario donde se presenten diferentes situaciones. 1 tiene que estar incompleto.

insert into acceso(cuil, contraseña, email, idtipousuario)
values
(20411343457, '1234567890', 'gaston-gaitan@hotmail.com', 1),
(21421473458, 'boquita', 'sofia-mangiantini@hotmail.com', 2),
(23483534810, 'messiteamo123', 'vladimir-tapia@hotmail.com', 1),
(56441348459, 'contasenia22', 'alberto-pipistrella@hotmail.com', 2),
(15412355697, 'qwer123', 'vicente-ismael@hotmail.com', 1);

insert into viaje(cuilusuario, fechainicio, horainicio, fechaFin, horaFin, idRodado,
idAnclajeInicio, idAnclajeDestino) values
(20411343457, '2022-01-02', '11:00', '2022-01-02', '13:00', 1, 1, 5),
(20411343457, '2021-08-03', '10:00', '2021-08-03', '11:00', 2, 2, 3),
(20411343457, '2018-08-03', '9:00', '2018-08-03', '10:30', 4, 1, 6),
(20411343457, '2022-10-07', '19:00', '2022-05-07', '21:00', 1, 1, 7),
(20411343457, '2022-12-26', '11:00', null, null, 1, 1, null),

(15412355697, '2022-01-07', '11:00', '2022-05-07', '13:00', 1, 1, 12),
(15412355697, '2020-08-07', '01:00', '2020-03-07', '02:00', 6, 2, 4),
(15412355697, '2022-10-09', '09:30', null, null, 1, 1, null),
(15412355697, '2022-05-07', '11:00', '2022-05-07', '13:00', 4, 1, 2),
(15412355697, '2022-05-07', '11:00', '2022-05-07', '13:00', 10, 3, 9),

(21421473458, '2025-05-02', '11:00', '2025-05-07', '13:00', 10, 1, 2),
(21421473458, '2022-02-07', '11:00', null, null, 1, 1, null),
(21421473458, '2022-05-11', '11:00', '2022-05-07', '13:00', 6, 1, 6),
(21421473458, '2018-08-07', '11:00', '2018-05-07', '13:00', 5, 2, 3),
(21421473458, '2022-05-12', '11:00', '2022-05-07', '13:00', 2, 10, 4),

(23483534810, '2025-05-02', '11:00', '2025-05-07', '13:00', 10, 1, 2),
(23483534810, '2022-02-07', '11:00', null, null, 1, 1, null),
(23483534810, '2022-05-11', '11:00', '2022-05-07', '13:00', 6, 1, 6),
(23483534810, '2018-08-07', '11:00', '2018-05-07', '13:00', 5, 2, 13),
(23483534810, '2022-05-12', '11:00', '2022-05-07', '13:00', 2, 10, 4),

(56441348459, '2025-05-02', '11:00', '2025-05-07', '13:00', 10, 1, 16),
(56441348459, '2022-02-07', '11:00', null, null, 1, 1, null),
(56441348459, '2022-05-11', '11:00', '2022-05-07', '13:00', 6, 1, 6),
(56441348459, '2018-08-07', '11:00', '2018-05-07', '13:00', 5, 2, 3),
(56441348459, '2022-05-12', '11:00', '2022-05-07', '13:00', 2, 10, 11);

-- 16 anclajes
-- 10 rodados
insert into disponibilidad (idRodado, idAnclaje, fecha_estado, hora_estado)
values
(1, 1, '2022-05-07', '11:00'),
(2, 2, '2022-05-07', '11:00'),
(3, 3, '2021-05-07', '12:00'),
(4, 4, '2022-05-07', '11:00'),
(5, 5, '2023-05-07', '11:00'),
(6, 6, '2021-05-07', '11:00'),
(7, 7, '2022-05-07', '01:00'),
(8, 8, '2022-05-07', '13:00'),
(9, 9, '2024-05-07', '15:00'),
(10, 16, '2022-05-07', '11:00');

-- Consultar Rodados
-- a) Conocer un informe por rodados que nos permita saber la ubicación actual de cada uno y el estado en el que se encuentra.
select rodado.idrodado,rodado.estado,disponibilidad.idAnclaje from rodado inner join disponibilidad on rodado.idRodado = disponibilidad.idRodado;

-- b) Calcular la cantidad de viajes que ha realizado un rodado, separando el informe por mes y año. Agregar la cantidad de reportes de Desperfecto.
select idRodado as 'Rodado',year(fechainicio) as 'anio viaje',month(fechainicio)as 'mes viaje', count(*) as 'Cantidad de viajes' from viaje group by year(fechainicio), month(fechainicio);

-- c) Informar la cantidad de rodados disponibles agrupados por puesto y su estado
select count(*) as 'Cantidad en el puesto', puesto.idPuesto, rodado.estado from rodado inner join disponibilidad on rodado.idRodado = disponibilidad.idRodado
inner join anclaje on disponibilidad.idAnclaje = anclaje.idAnclaje
inner join puesto on anclaje.idPuesto = puesto.idPuesto
group by puesto.idPuesto,
rodado.estado;

-- d) Informar la cantidad de rodados que se encuentran en reparación, agrupando la información por mes.
select  count(*) as 'Cantidad de rodados en reparacion', month(disponibilidad.fecha_estado) as Mes from rodado inner join disponibilidad on rodado.idRodado = disponibilidad.idRodado where rodado.estado = 'en reparacion'
group by rodado.idRodado;

-- e) Informe que permita ver los rodados disponibles, su modelo, estado y su último viaje realizado.
select rodado.idRodado, rodado.idModelo, tipomodelo.descripcion, rodado.estado, max(disponibilidad.fecha_estado) as 'Ultimo viaje realizado'
from Rodado 
inner join TipoModelo on rodado.IdModelo = TipoModelo.idModelo
inner join Disponibilidad on rodado.idRodado = disponibilidad.idRodado
group by rodado.idRodado;

-- f) Listado que permita obtener por rodado, el tiempo promedio de viaje, el tiempo total y el tiempo maximo, con el agregado de la cantidad de viajes realizados
select idRodado, max(viaje.horafin - viaje.horainicio)/10000 as 'Maximo tiempo de viaje',
avg((viaje.horafin - viaje.horainicio)/10000) as 'Tiempo Promedio de Viaje',
count(idRodado) as 'Cantidad de viajes' 
from viaje
group by viaje.idRodado;

-- Consultar Puestos
-- a) Listado completo de puestos con todos sus datos y cuando anclajes posee
select idPuesto, count(*) from anclaje
group by idPuesto;

-- b) Cantidad de viajes que se realizaron por puesto (Inicio de viaje), agrupar la información por año y mes.
select localidad.nombrelocalidad as 'Destino', puesto.idPuesto,count(*) as 'Cantidad de viajes desde el puesto', year(viaje.fechaInicio) as 'Anio viaje', month(viaje.fechaInicio) as 'Mes viaje'
from viaje 
inner join anclaje on viaje.idAnclajeDestino = anclaje.idAnclaje
inner join puesto on anclaje.idPuesto = puesto.idPuesto
inner join localidad on puesto.idLocalidad = localidad.idLocalidad
group by puesto.idPuesto,
year(viaje.fechaFin),
month(viaje.fechaFin);

-- c) Cantidad de viajes que se realizaron por puesto (Destino de viaje), agrupar la información por año y mes.
select localidad.nombrelocalidad as 'Destino', puesto.idPuesto,count(*) as 'Cantidad de viajes hacia el puesto', year(viaje.fechaFin) as 'Anio viaje', month(viaje.fechaFin) as 'Mes viaje'
from viaje 
inner join anclaje on viaje.idAnclajeDestino = anclaje.idAnclaje
inner join puesto on anclaje.idPuesto = puesto.idPuesto
inner join localidad on puesto.idLocalidad = localidad.idLocalidad
group by puesto.idPuesto,
year(viaje.fechaFin),
month(viaje.fechaFin);

-- d) Estado actual del puesto, con detalle de sus anclajes y el estado en el que se encuentran.
select * from anclaje;

-- e) Listado informando la cantidad de anclajes por puesto y el estado;
-- Primero muestro los puestos con sus respectivos anclajes porque si saco la cantidad de todos los anclajes,
-- no voy a poder saber el estado de cada uno.
select puesto.idPuesto, anclaje.idAnclaje, anclaje.estado from puesto inner join anclaje on puesto.idPuesto = anclaje.idPuesto;

-- Ahora si cuento la cantidad de anclajes de cada puesto:
select puesto.idPuesto as 'Puesto', count(anclaje.idAnclaje) as 'Cantidad de anclajes' 
from puesto inner join anclaje on puesto.idPuesto = anclaje.idPuesto
group by puesto.idPuesto;

-- f) Cantidad de reservas para retiro realizadas en el puesto
select anclaje.idPuesto, count(*) as 'Cantidad de anclajes reservados' from anclaje
inner join puesto on anclaje.idPuesto = puesto.idPuesto
where anclaje.estado = 'Reservado'
group by idPuesto;

-- g) Cantidad de reservas para entrega realizadas en el puesto.
-- Este no lo hice porque creeria que es bastante similar al punto anterior.

-- Consultas Usuarios:
-- a) Listado de los últimos viajes realizado por usuario:
select max(viaje.fechafin) as 'Ultimo viaje del usuario', usuario.cuil from viaje inner join usuario on viaje.cuilusuario = usuario.cuil
group by usuario.cuil;

-- b) Resumen de cantidad de viajes realizados por usuario, agrupado por mes y año.
-- Cantidad de viajes de cada usuario por mes
select cuilusuario, 
count(*) as 'Cantidad de viajes por mes',
month(fechaFin) as Mes
from viaje where fechaFin is not null
group by cuilusuario, month(fechaFin);

-- Cantidad de viajes de cada usuario por dia
select cuilusuario, 
count(*) as 'Cantidad de viajes por Anio',
year(fechaFin) as Anio
from viaje where fechaFin is not null
group by cuilusuario, year(fechaFin);

-- Consulta administrador
-- a) Listado de Usuarios cargadas en el sistema informando su tipo de perfil. Se deberán
-- mostrar todos los datos.
select usuario.*, tipousuario.* from usuario
inner join acceso on usuario.cuil = acceso.cuil
inner join tipousuario on acceso.idtipousuario = tipousuario.idtipousuario;

-- b) Listado de rodados disponibles y su estado actual, además del puesto donde se encuentran.
select rodado.idrodado, max(fecha_estado) 'Ultimo registro de disponibilidad', anclaje.idPuesto
from rodado
inner join disponibilidad on rodado.idrodado = disponibilidad.idrodado
inner join anclaje on disponibilidad.idanclaje
inner join puesto on puesto.idpuesto = anclaje.idpuesto
group by rodado.idRodado;

-- c) Listado completo de puestos y puntos de anclaje
select * from puesto inner join anclaje;

-- 4) Ingresar un registro del estado de los rodados con una evaluacion del porque del estado
-- Agregar causas raices categorizadas asi tambien como se le dio solucion
-- Este historial de estado debe contar con la fecha y hora en que entro en ese estado y cuando dejo de estarlo
-- Hay una relacion muchos a muchos por lo que se va a requerir de una tabla conectora entre los rodados y sus estados.
select * from rodado;

create table clasificacion_estados(
id_estado int unique,
descripcion text,
primary key (id_estado)
);

insert into clasificacion_estados(id_estado, descripcion)
values(1, "Activo"), 
(2, "Desperfecto"),
(3, "En reparacion"),
(4, "Inactivo");

select  * from clasificacion_estados;

create table registro_estados(
id_registro_estado int unique auto_increment not null,
idRodado int not null,
idEstado int not null,
descripcion text,
solucion_aplicada text default NULL,
comienzo_estado datetime,
fin_estado datetime,
primary key (id_registro_estado),
foreign key (idRodado) references rodado(idRodado),
foreign key (idEstado) references clasificacion_estados(id_estado)
);

-- Carga de la tabla registro_estados
insert into registro_estados
(idRodado, idEstado, descripcion, solucion_aplicada, comienzo_estado, fin_estado)
values
(1, 1, "Sin desperfectos", "Recien adquirida", "2021-01-01 12:00:00", NULL),
(2, 2, "Luz rota", "Cambio de foco", "2021-01-01 12:00:00", "2021-04-01 10:10:14"),
(3, 3, "Cadena rota", "Se le cambio la cadena", "2021-01-01 12:00:00", "2021-02-02 12:00:00"),
(3, 1, "Sin desperfectos", "Se le cambio la cadena", "2021-02-02 12:00:00", NULL),
(5, 1, "Sin desperfectos", "Recien adquirida", "2021-01-01 12:00:00", NULL),
(6, 1, "Sin desperfectos", "Recien adquirida", "2021-01-01 12:00:00", NULL),
(7, 4, "Rodado desaparecido", "Se reporto un hurto", "2021-06-01 12:00:00", "2021-07-01 12:00:00"),
(8, 1, "Sin desperfectos", "Recien adquirida", "2021-01-01 12:00:00", NULL),
(9, 1, "Sin desperfectos", "Recien adquirida", "2021-01-01 12:00:00", NULL),
(10, 1, "Sin desperfectos", "Recien adquirida", "2021-01-01 12:00:00", NULL),
(7, 1, "Sin desperfectos", "Bicicleta recuperada por la policia", "2021-07-01 12:00:00", NULL),
(3, 1, "Sin desperfectos", "Recien adquirida", "2021-01-01 12:00:00", NULL);

-- Prueba de la table union creada:
select * from clasificacion_estados
inner join registro_estados on clasificacion_estados.id_estado = registro_estados.idEstado
inner join rodado on registro_estados.idRodado = rodado.idRodado;






