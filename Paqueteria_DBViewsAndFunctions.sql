USE Paqueteria;

GO
CREATE VIEW InformacionPaqueteEnMiami AS
SELECT C.Nombre, C.Apellido, P.IdPaquete, P.Peso, P.Volumen, R.NombreRemitiente, 
EP.NombreEstadoPaquete, P.Contenido, 
P.MontoAPagarPorPaquete [Precio],
CONCAT(U.NombreUbicacion, ' - ', U.Ubicacion) [Ubicacion Actual]
FROM PAQUETE P
JOIN EstadoPaquete EP ON EP.IdEstadoPaquete = P.IdEstadoPaquete 
JOIN Ubicacion U ON U.IdUbicacion = P.IdUbicacionActual 
JOIN Remitiente R ON R.RemitienteId = P.RemitienteId
Join Cliente C ON C.IdCliente = P.IdCliente
WHERE U.IdUbicacion = 1
GO

SELECT  * FROM InformacionPaqueteEnMiami;

GO
CREATE VIEW InformacionCliente AS
SELECT C.Nombre, C.Apellido, TD.NombreTipoDocumento, C.Documento, Celular, Correo,
G.NombreGenero, EC.NombreEstadoCivil,  P.NombreProvincia
FROM CLIENTE C
Join TipoDocumento TD ON TD.IdTipoDocumento = C.IdTipoDocumento
Join Provincia P ON P.IdProvincia = C.IdProvincia
Join Genero G ON G.IdGenero = C.IdGenero
Join EstadoCivil EC ON EC.IdEstadoCivil = C.IdEstadoCivil

GO

SELECT * From InformacionCliente;

GO
CREATE VIEW InventarioActualSucursal AS
SELECT S.Nombre, P.IdPaquete, 
P.MontoAPagarPorPaquete [Monto], P.Contenido,
Isuc.FechaLlegada[Fecha de llegada]
FROM InventarioSucursal ISuc
Join Sucursal S ON ISuc.IdSucursal = S.IdSucursal
Join Paquete P ON ISuc.IdPaquete = P.IdPaquete
WHERE '' = ISNULL(ISuc.FechaSalida,'')
GO

SELECT * FROM InventarioActualSucursal;

GO
CREATE VIEW InformacionPaquetes AS
SELECT 
P.IdPaquete, P.IdCliente, P.Peso, P.Volumen, 
R.NombreRemitiente, EP.NombreEstadoPaquete, P.Contenido, P.MontoAPagarPorPaquete [Precio],
CONCAT(U.NombreUbicacion, ' - ', U.Ubicacion) [Ubicacion Actual]
FROM PAQUETE P
JOIN EstadoPaquete EP ON EP.IdEstadoPaquete = P.IdEstadoPaquete 
JOIN Ubicacion U ON U.IdUbicacion = P.IdUbicacionActual 
JOIN Remitiente R ON R.RemitienteId = P.RemitienteId
GO

CREATE FUNCTION GetSucursalByIdPaquete (
    @IdPaquete INT
)
RETURNS TABLE
AS
RETURN
    SELECT C.SucursalPreferido
FROM Paquete P
Join Cliente C ON P.IdCliente = C.IdCliente
WHERE P.IdPaquete = @IdPaquete
GO

CREATE FUNCTION GetAllPaquetesDeCliente (
    @IdCliente INT
)
RETURNS TABLE
AS
RETURN
SELECT C.Nombre, C.Apellido,
IdPaquete [Paquete ID], TrackingNumber[Tracking Number],
P.FechaRecibido [Fecha Recibido], EP.NombreEstadoPaquete,
P.Contenido, P.Peso, P.Volumen, 
R.NombreRemitiente[Remitiente], TT.NombreTipoTarifa[Tipo Tarifa],
P.MontoAPagarPorPaquete [Monto]
FROM Paquete P
JOIN Remitiente R ON R.RemitienteId = P.RemitienteId
JOIN TipoTarifa TT ON TT.IdTipoTarifa = P.IdTipoTarifa
JOIN EstadoPaquete EP ON EP.IdEstadoPaquete = P.IdEstadoPaquete
JOIN Cliente C ON C.IdCliente = P.IdCliente
WHERE P.IdCliente = @IdCliente
GO


CREATE FUNCTION GetAllNuevosPaquetesDeCliente (
    @IdCliente INT
)
RETURNS TABLE
AS
RETURN
SELECT C.Nombre, C.Apellido,
IdPaquete [Paquete ID], TrackingNumber[Tracking Number],
P.FechaRecibido [Fecha Recibido], EP.NombreEstadoPaquete,
P.Contenido, P.Peso, P.Volumen, 
R.NombreRemitiente[Remitiente], TT.NombreTipoTarifa[Tipo Tarifa],
P.MontoAPagarPorPaquete [Monto]
FROM Paquete P
JOIN Remitiente R ON R.RemitienteId = P.RemitienteId
JOIN TipoTarifa TT ON TT.IdTipoTarifa = P.IdTipoTarifa
JOIN EstadoPaquete EP ON EP.IdEstadoPaquete = P.IdEstadoPaquete
JOIN Cliente C ON C.IdCliente = P.IdCliente
WHERE P.IdCliente = @IdCliente AND P.IdEstadoPaquete <> 7
GO

CREATE FUNCTION GetIdPaquetePorTrackingNumber (
    @TrackingNumber nvarchar(40)
)
RETURNS INT
AS
BEGIN
	DECLARE @IdPaquete AS INT;
    SET @IdPaquete = (SELECT TOP(1) IdPaquete
	FROM PAQUETE
	WHERE TrackingNumber = @TrackingNumber)
    RETURN @IdPaquete
END