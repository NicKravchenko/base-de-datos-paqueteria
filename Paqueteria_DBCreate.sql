--create database Paqueteria
--COLLATE SQL_Latin1_General_CP1_CI_AS ;

--use  Paqueteria;
--drop database Paqueteria;

CREATE TABLE [Provincia] (
  [IdProvincia] int PRIMARY KEY IDENTITY,
  [NombreProvincia] nvarchar(50) NOT NULL
);

CREATE TABLE [Personal] (
  [IdPersonal] int PRIMARY KEY  IDENTITY,
  [Nombre] nvarchar(50) NOT NULL,
  [Apellido] nvarchar(50) NOT NULL,
  [Cedula] nvarchar(12) NOT NULL,
  [Celular] nvarchar(15) NOT NULL,
  [Correo] nvarchar(50) NOT NULL,
  [IdProvincia] int NOT NULL,
  [Direccion] nvarchar(100) NOT NULL,

  CONSTRAINT [FK_Personal.IdProvincia]
    FOREIGN KEY ([IdProvincia])
      REFERENCES [Provincia]([IdProvincia])
);

CREATE TABLE [Sucursal] (
  [IdSucursal] int PRIMARY KEY  IDENTITY,
  [Nombre] nvarchar(50) NOT NULL,
  [Direccion] nvarchar(100) NOT NULL,
  [Telefono] nvarchar(15) NOT NULL,
  [Correo] nvarchar(50) NOT NULL,
  [PermiteDevolucion] BIT NOT NULL
);

CREATE TABLE [TipoDocumento] (
  [IdTipoDocumento] int PRIMARY KEY IDENTITY,
  [NombreTipoDocumento] nvarchar(20) NOT NULL
);

CREATE TABLE [EstadoCivil] (
  [IdEstadoCivil] int PRIMARY KEY IDENTITY,
  [NombreEstadoCivil] nvarchar(20) NOT NULL
);

CREATE TABLE [Genero] (
  [IdGenero] int PRIMARY KEY IDENTITY,
  [NombreGenero] nvarchar(20) NOT NULL
);

CREATE TABLE [Cliente] (
  [IdCliente] int PRIMARY KEY IDENTITY,
  [Nombre] nvarchar(50) NOT NULL,
  [Apellido] nvarchar(50) NOT NULL,
  [Documento] nvarchar(15) NOT NULL,
  [IdTipoDocumento] int NOT NULL,
  [Celular] nvarchar(15) NOT NULL,
  [IdGenero] int NOT NULL,
  [IdEstadoCivil] int NOT NULL,
  [Correo] nvarchar(50) NOT NULL,
  [IdProvincia] int NOT NULL,
  [SucursalPreferido] int NOT NULL

  CONSTRAINT [FK_Cliente.SucursalPreferido]
    FOREIGN KEY ([SucursalPreferido])
      REFERENCES [Sucursal]([IdSucursal]),
  CONSTRAINT [FK_Cliente.IdTipoDocumento]
    FOREIGN KEY ([IdTipoDocumento])
      REFERENCES [TipoDocumento]([IdTipoDocumento]),
  CONSTRAINT [FK_Cliente.IdEstadoCivil]
    FOREIGN KEY ([IdEstadoCivil])
      REFERENCES [EstadoCivil]([IdEstadoCivil]),
  CONSTRAINT [FK_Cliente.IdGenero]
    FOREIGN KEY ([IdGenero])
      REFERENCES [Genero]([IdGenero]),
  CONSTRAINT [FK_Cliente.IdProvincia]
    FOREIGN KEY ([IdProvincia])
      REFERENCES [Provincia]([IdProvincia]),
);

CREATE TABLE [Direccion] (
  [IdDireccion] int PRIMARY KEY IDENTITY,
  [Direccion] nvarchar(100) NOT NULL,
  [IdCliente] int NOT NULL,
  [EsDireccionVivienda] BIT NOT NULL

  CONSTRAINT [FK_Direccion.IdCliente]
    FOREIGN KEY ([IdCliente])
      REFERENCES [Cliente]([IdCliente])
);


CREATE TABLE [EstadoPaquete] (
  [IdEstadoPaquete] int PRIMARY KEY IDENTITY,
  [NombreEstadoPaquete] nvarchar(40) NOT NULL
);

CREATE TABLE [TipoTarifa] (
  [IdTipoTarifa] int PRIMARY KEY IDENTITY,
  [NombreTipoTarifa] nvarchar(40) NOT NULL,
  [PrecioPorLibra] money NOT NULL
);

CREATE TABLE [MetodoPago] (
  [IdMetodoPago] int PRIMARY KEY IDENTITY,
  [NombreMetodoPago] nvarchar(20) NOT NULL
);

CREATE TABLE [FacturaHeader] (
  [IdFacturaHeader] int PRIMARY KEY IDENTITY,
  [IdSucursal] int NOT NULL,
  [IdCliente] int NOT NULL,
  [NFC] nvarchar(20) NOT NULL,
  [IdMetodoPago] INT,
  [MontoDelivery] money NOT NULL,
  [Bruto] money NOT NULL,
  [Descuento] money NOT NULL,
  [MontoTotal] money NOT NULL,
  [Fecha] DateTime NOT NULL,
  [EsPagada] BIT NOT NULL

  CONSTRAINT [FK_Factura.IdSucursal]
    FOREIGN KEY ([IdSucursal])
      REFERENCES [Sucursal]([IdSucursal]),
  CONSTRAINT IdCliente
    FOREIGN KEY ([IdCliente])
      REFERENCES [Cliente]([IdCliente]),
  CONSTRAINT IdMetodoPago
    FOREIGN KEY (IdMetodoPago)
      REFERENCES [MetodoPago]([IdMetodoPago])
);


CREATE TABLE [Ubicacion] (
  [IdUbicacion] int PRIMARY KEY IDENTITY,
  [NombreUbicacion] nvarchar(40) NOT NULL,
  [Ubicacion] nvarchar(100) NOT NULL
);


CREATE TABLE [Remitiente] (
  [RemitienteId] int PRIMARY KEY IDENTITY,
  [NombreRemitiente] nvarchar(20) NOT NULL
);

--
CREATE TABLE [Paquete] (
  [IdPaquete] int PRIMARY KEY IDENTITY,
  [IdCliente] int NOT NULL,
  [TrackingNumber] nvarchar(40) NOT NULL,
  [IdEstadoPaquete] int NOT NULL,
  [FechaRecibido] DateTime NOT NULL,
  [Peso] float NOT NULL,
  [Volumen] float NOT NULL,
  [RemitienteId] int NOT NULL,
  [IdTipoTarifa] int NOT NULL,
  [MontoAPagarPorPaquete] money NOT NULL,
  [Contenido] nvarchar(50) NOT NULL,
  [EsDelivery] bit ,
  [IdUbicacionActual] int NOT NULL
 
  CONSTRAINT [FK_Paquete .IdEstadoPaquete]
    FOREIGN KEY ([IdEstadoPaquete])
      REFERENCES [EstadoPaquete]([IdEstadoPaquete]),
  CONSTRAINT [FK_Paquete .IdTipoTarifa]
    FOREIGN KEY ([IdTipoTarifa])
      REFERENCES [TipoTarifa]([IdTipoTarifa]),
  CONSTRAINT [FK_Paquete .RemitienteId]
    FOREIGN KEY ([RemitienteId])
      REFERENCES [Remitiente]([RemitienteId]),
  CONSTRAINT [FK_Paquete .IdUbicacionActual]
    FOREIGN KEY ([IdUbicacionActual])
      REFERENCES [Ubicacion]([IdUbicacion]),
  CONSTRAINT [FK_Paquete .IdCliente]
    FOREIGN KEY ([IdCliente] )
      REFERENCES [Cliente] ([IdCliente])
);
--
CREATE TABLE [FacturaDetail] (
  [IdFacturaDetail] int IDENTITY,
  [IdFacturaHeader] int NOT NULL,
  [IdPaquete] int NOT NULL UNIQUE,
  [Precio] money NOT NULL,
  [Fecha] DateTime NOT NULL,

  PRIMARY KEY ([IdFacturaDetail], [IdFacturaHeader]),

  CONSTRAINT [FK_Factura.IdFacturaHeader]
    FOREIGN KEY ([IdFacturaHeader])
      REFERENCES [FacturaHeader]([IdFacturaHeader]),
  CONSTRAINT [FK_Factura.IdPaquete]
    FOREIGN KEY ([IdPaquete])
      REFERENCES [Paquete]([IdPaquete])
);

--
CREATE TABLE [Delivery] (
  [IdDelivery] int PRIMARY KEY IDENTITY,
  [IdFacturaHeader] int NOT NULL,
  [IdPersonal] int NOT NULL,
  [IdDireccion] int NOT NULL,
  [EsTerminado] BIT NOT NULL,
  [TiempoEnviado] DateTime NOT NULL,
  [TiempoRecibido] DateTime,

  CONSTRAINT [FK_Delivery.IdFacturaHeader]
    FOREIGN KEY ([IdFacturaHeader])
      REFERENCES [FacturaHeader]([IdFacturaHeader]),
  CONSTRAINT [FK_Delivery.IdDireccion]
    FOREIGN KEY ([IdDireccion])
      REFERENCES [Direccion]([IdDireccion]),
  CONSTRAINT [FK_Delivery.IdPersonal]
    FOREIGN KEY ([IdPersonal])
      REFERENCES [Personal]([IdPersonal])
);


CREATE TABLE [InventarioSucursal] (
  [IdSucursal] int NOT NULL,
  [IdPaquete] int NOT NULL,
  [FechaLlegada] DateTime NOT NULL,
  FechaSalida DateTime

  PRIMARY KEY ([IdSucursal], [IdPaquete]),

  CONSTRAINT [FK_InventarioSucursal.IdPaquete]
    FOREIGN KEY ([IdPaquete])
      REFERENCES [Paquete ]([IdPaquete]),
  CONSTRAINT [FK_InventarioSucursal.IdSucursal]
    FOREIGN KEY ([IdSucursal])
      REFERENCES [Sucursal]([IdSucursal])
);




CREATE TABLE [RolTrabajo] (
  [IdRolTrabajo] int PRIMARY KEY IDENTITY,
  [NombreRolTrabajo] nvarchar(40) NOT NULL
);

CREATE TABLE [EstadoPersonal] (
  [IdEstado] int PRIMARY KEY IDENTITY,
  [NombreEstado] nvarchar(20) NOT NULL
);

CREATE TABLE [PersonaSucursal] (
  [IdSucursal] int NOT NULL,
  [IdPersonal] int NOT NULL,
  [IdRol] int NOT NULL,
  [FechaInicio] DateTIME NOT NULL,
  [FechaFin] DateTIME,
  [IdEstado] int NOT NULL,

  PRIMARY KEY ([IdSucursal], [IdPersonal], [IdRol]),

  CONSTRAINT [FK_PersonaSucursal.IdRol]
    FOREIGN KEY ([IdRol])
      REFERENCES [RolTrabajo]([IdRolTrabajo]),
  CONSTRAINT [FK_PersonaSucursal.IdSucursal]
    FOREIGN KEY ([IdSucursal])
      REFERENCES [Sucursal]([IdSucursal]),
  CONSTRAINT [FK_PersonaSucursal.IdPersonal]
    FOREIGN KEY ([IdPersonal])
      REFERENCES [Personal]([IdPersonal]),
    CONSTRAINT [FK_PersonaSucursal.IdEstado]
    FOREIGN KEY ([IdEstado])
      REFERENCES [EstadoPersonal]([IdEstado])
);


CREATE TABLE [MovemientoPaquete] (
  [IdMovimiento] int PRIMARY KEY  IDENTITY,
  [IdPaquete] int NOT NULL,
  [IdUbicacionOrigen] int NOT NULL,
  [IdUbicacionDestino] int NOT NULL,
  [FechaEnvio] DateTime NOT NULL,
  [FechaLlegada] DateTime,
  [EstaTerminado] BIT NOT NULL,
  [Detalles] nvarchar(50) ,

  CONSTRAINT [FK_MovemientoPaquete.IdUbicacionOrigen]
    FOREIGN KEY ([IdUbicacionOrigen])
      REFERENCES [Ubicacion]([IdUbicacion]),
  CONSTRAINT [FK_MovemientoPaquete.IdUbicacionDestino]
    FOREIGN KEY ([IdUbicacionDestino])
      REFERENCES [Ubicacion]([IdUbicacion]),
  CONSTRAINT [FK_MovemientoPaquete.IdPaquete]
    FOREIGN KEY ([IdPaquete])
      REFERENCES [Paquete]([IdPaquete])
);

CREATE TABLE [EtiquetaManipulacion] (
  [IdEtiquetaManipulacion] int PRIMARY KEY IDENTITY,
  [NombreEtiquetaManipulacion] nvarchar(50) NOT NULL
);


CREATE TABLE [PaqueteEtiquetaManipulacion] (
  [IdPaquete] int NOT NULL,
  [IdEtiquetaManipulacion] int NOT NULL,

  PRIMARY KEY ([IdPaquete], [IdEtiquetaManipulacion]),

  CONSTRAINT [FK_PaqueteEtiquetaManipulacion.IdEtiquetaManipulacion]
    FOREIGN KEY ([IdEtiquetaManipulacion])
      REFERENCES [EtiquetaManipulacion]([IdEtiquetaManipulacion]),
  CONSTRAINT [FK_PaqueteEtiquetaManipulacion.IdPaquete]
    FOREIGN KEY ([IdPaquete])
      REFERENCES [Paquete]([IdPaquete])
);


CREATE TABLE [TipoPaquete] (
  [IdTipoPaquete] int PRIMARY KEY IDENTITY,
  [NombreTipoPaquete] nvarchar(20) NOT NULL,
  [EsHAZMAT] BIT NOT NULL
);

--
CREATE TABLE [TipoPaquetePaquete] (
  [IdPaquete] int NOT NULL,
  [IdTipoPaquete] int NOT NULL,

  PRIMARY KEY ([IdPaquete], [IdTipoPaquete]),

  CONSTRAINT [FK_TipoPaquetePaquete.IdPaquete]
    FOREIGN KEY ([IdPaquete])
      REFERENCES [Paquete]([IdPaquete]),
  CONSTRAINT [FK_TipoPaquetePaquete.IdTipoPaquete]
    FOREIGN KEY ([IdTipoPaquete])
      REFERENCES [TipoPaquete]([IdTipoPaquete])
);