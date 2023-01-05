USE Paqueteria;
SELECT * FROM Paquete
SELECT * 
FROM CLIENTE
WHERE IdCliente = 4565;
SELECT * FROM GetSucursalByIdPaquete(12) ;
SELECT * FROM GetAllNuevosPaquetesDeCliente(4565);
SELECT * FROM Delivery;
SELECT * FROM Sucursal;
SELECT * FROM MovemientoPaquete
WHERE IdPaquete = 12;
SELECT * FROM InformacionPaquetes;
SELECT * FROM InventarioActualSucursal;
SELECT * FROM EstadoPaquete;
Select * From FacturaHeader;
Select * From FacturaDetail;
SELECT * FROM Delivery;
SELECT * FROM TipoPaquete;

Select * From FacturaDetail;

SELECT * FROM Direccion
Where IdCliente = 4335;

SELECT * FROM PersonaSucursal
WHere IdRol = 1

SELECT S.Nombre as [NombreSucursal],
InS.IdPaquete, P.Contenido, P.Peso, P.Volumen, P.TrackingNumber,
InS.FechaLlegada, InS.FechaSalida
from InventarioSucursal InS
JOIN Sucursal S ON InS.IdSucursal = S.IdSucursal
JOIN Paquete P ON P.IdPaquete = InS.IdPaquete
WHERE InS.IdSucursal = @IdSucursal
/*
DELETE FROM PaqueteEtiquetaManipulacion;
DELETE FROM TipoPaquetePaquete;
DELETE FROM MovemientoPaquete;
DBCC CHECKIDENT ('MovemientoPaquete', RESEED, 0);
DELETE FROM Paquete;
DBCC CHECKIDENT ('Paquete', RESEED, 0);

DELETE FROM FacturaDetail;
DBCC CHECKIDENT ('FacturaDetail', RESEED, 0);

DELETE FROM FacturaHeader;
DBCC CHECKIDENT ('FacturaHeader', RESEED, 0);

DELETE FROM InventarioSucursal;
DELETE FROM Delivery;
DBCC CHECKIDENT ('Delivery', RESEED, 0);

*/

--2022/07/12

SELECT FH.IdFacturaHeader,
S.Nombre, FH.IdCliente, 
MP.NombreMetodoPago,
FH.MontoDelivery, FH.Bruto, FH.Descuento,
FH.MontoTotal, FH.Fecha
FROM FacturaHeader FH
JOIN Sucursal S ON S.IdSucursal = FH.IdSucursal
JOIN MetodoPago MP ON MP.IdMetodoPago = FH.IdMetodoPago
WHERE FH.IdSucursal = @IdSucursal AND 
day(Fecha)=day(@Fecha) and 
month(Fecha)=month(@Fecha)
and year(Fecha)=year(@Fecha)
and EsPagada = 1;
SELECT * FROM MovemientoPaquete;
