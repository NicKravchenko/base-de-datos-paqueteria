Use Paqueteria;

--Eligir tipo de tarifa en base al peso
GO
CREATE FUNCTION EligirTipoTarifa(
    @Peso FLOAT
)
RETURNS INT
AS 
BEGIN
DECLARE @IdTipoTarifa as INT
IF @Peso < 71  
   Set @IdTipoTarifa = 1;  
ELSE   
   BEGIN 
	IF
		@Peso < 351  
		Set @IdTipoTarifa = 2;  
   ELSE  
      Set @IdTipoTarifa = 3;  
   END;
    RETURN @IdTipoTarifa
END;
GO

--Hacer movimiento
GO
CREATE PROCEDURE HacerMovimiento(
@IdPaquete INT,
@Detalles NVARCHAR(50),
@IdUbicacionOrigen INT,
@IdUbicacionDestino INT)
AS
INSERT INTO [MovemientoPaquete] (IdPaquete, 
IdUbicacionOrigen, IdUbicacionDestino,
FechaEnvio, FechaLlegada, EstaTerminado,
Detalles)
VALUES (@IdPaquete, 
@IdUbicacionOrigen, @IdUbicacionDestino,
GETDATE(), NULL, 0, 
@Detalles);
GO

--Actualizar movimiento
GO
CREATE PROCEDURE ActualizarMovimiento(
@IdPaquete INT,
@IdUbicacionOrigen INT)
AS

UPDATE [MovemientoPaquete]
SET FechaLlegada = GETDATE(), EstaTerminado = 1
WHERE IdPaquete = @IdPaquete AND IdUbicacionDestino = @IdUbicacionOrigen;
GO


--ActualizarPrecioSiEsHazmat
GO
CREATE PROCEDURE ActuralizarPrecio(
@IdPaquete INT)
AS
DECLARE @Precio AS MONEY;

SET @Precio = (Select MontoAPagarPorPaquete FROM Paquete
Where IdPaquete = @IdPaquete)

IF (1 = (Select TOP 1 EsHAZMAT
FROM TipoPaquetePaquete TPP
JOIN TipoPaquete TP ON TPP.IdTipoPaquete = TP.IdTipoPaquete
Where IdPaquete = @IdPaquete
ORDER BY EsHAZMAT DESC))
BEGIN
	SET @Precio = (@Precio + 6000);
END

UPDATE Paquete
SET MontoAPagarPorPaquete = @Precio
WHERE IdPaquete = @IdPaquete

GO


--Recibir paquete en miami
GO
Create PROCEDURE RecibirPaqueteMiami
	@TrackingNumber nvarchar(30),	
	@Peso FLOAT, 
	@Volumen FLOAT, 
	@RemitienteId INT,
	@Contenido nvarchar(50),
	@EsDelivery bit,
	@IdCliente int
AS
DECLARE @IdTipoTarifa as int,
		@FechaRecibido DATETIME, 
		@IdEstadoPaquete as int,
		@IdUbicacionActual int,
		@PrecioPorLibra money,
		@MontoAPagarPorPaquete as MONEY;

SET @FechaRecibido = GETDATE();
SET @IdEstadoPaquete = 1;
SET @IdUbicacionActual = 1;

EXEC @IdTipoTarifa = EligirTipoTarifa @Peso = @Peso;  

SET @PrecioPorLibra = (SELECT PrecioPorLibra
	FROM TipoTarifa
	WHERE IdTipoTarifa = @IdTipoTarifa);

SET @MontoAPagarPorPaquete = @PrecioPorLibra * @Peso;

INSERT INTO [Paquete] 
	(TrackingNumber, 
	IdEstadoPaquete,	
	FechaRecibido, 
	Peso, 
	Volumen, 
	RemitienteId,
	IdTipoTarifa,
	MontoAPagarPorPaquete,
	Contenido,
	EsDelivery,
	IdUbicacionActual,
	IdCliente)
VALUES (@TrackingNumber, 
@IdEstadoPaquete,
@FechaRecibido,
@Peso, 
@Volumen, 
@RemitienteId,
@IdTipoTarifa,
@MontoAPagarPorPaquete,
@Contenido,
@EsDelivery,
@IdUbicacionActual,
@IdCliente)
GO


--Agregar Etiqueta De Manipulacion
GO
Create PROCEDURE AgregarEtiquetaDeManipulacion
@IdPaquete INT,
@IdEtiquetaManipulacion INT
AS
INSERT INTO PaqueteEtiquetaManipulacion (IdPaquete, IdEtiquetaManipulacion)
VALUES (@IdPaquete, @IdEtiquetaManipulacion);
GO


--Asignar tipo de paquete
GO
Create PROCEDURE AsignarTipoPaquete
@IdPaquete INT,
@IdTipoPaquete INT
AS
INSERT INTO TipoPaquetePaquete (IdPaquete, IdTipoPaquete)
VALUES (@IdPaquete, @IdTipoPaquete);
GO


--Empacar paquete
GO
Create PROCEDURE EmpacarPaquete
@IdPaquete INT
AS
UPDATE Paquete
SET IdEstadoPaquete = 2
WHERE IdPaquete = @IdPaquete;
GO

--Embarcar paquete
GO
CREATE PROCEDURE EmbarcarPaquete(
@IdPaquete INT,
@Detalles NVARCHAR(50))
AS
DECLARE @IdUbicacionOrigen AS INT,
@IdUbicacionDestino AS INT;

SET @IdUbicacionOrigen = 1;
SET @IdUbicacionDestino = 2;
UPDATE Paquete
SET IdEstadoPaquete = 3
WHERE IdPaquete = @IdPaquete;

EXEC HacerMovimiento
	@IdPaquete = @IdPaquete,
	@Detalles = @Detalles,
	@IdUbicacionOrigen = @IdUbicacionOrigen,
	@IdUbicacionDestino = @IdUbicacionDestino;

GO


--Recibir paquete en AILA 
GO
CREATE PROCEDURE RecibirPaqueteAILA(
@IdPaquete INT,
@Detalles NVARCHAR(50))
AS
DECLARE @IdUbicacionOrigen AS INT,
@IdUbicacionDestino AS INT;

SET @IdUbicacionOrigen = 2;
SET @IdUbicacionDestino = 3;
UPDATE Paquete
SET IdEstadoPaquete = 4, IdUbicacionActual = @IdUbicacionOrigen
WHERE IdPaquete = @IdPaquete;

EXEC HacerMovimiento
	@IdPaquete = @IdPaquete,
	@Detalles = @Detalles,
	@IdUbicacionOrigen = @IdUbicacionOrigen,
	@IdUbicacionDestino = @IdUbicacionDestino;


EXEC ActualizarMovimiento
	@IdPaquete = @IdPaquete,
	@IdUbicacionOrigen = @IdUbicacionOrigen;

GO

--Recibir paquete en Centro de distribucion 
GO
CREATE PROCEDURE RecibirPaqueteEnCD(
@IdPaquete INT,
@Detalles NVARCHAR(50))
AS
DECLARE @IdUbicacionOrigen AS INT,
@IdCliente AS INT,
@IdUbicacionDestino AS INT;

SET @IdUbicacionOrigen = 3;

SET @IdCliente = (SELECT IdCliente 
FROM PAQUETE
Where IdPaquete = @IdPaquete);

SET @IdUbicacionDestino =  (SELECT SucursalPreferido FROM Cliente
WHERE IdCliente = @IdCliente)
SET @IdUbicacionDestino = @IdUbicacionDestino + 3;

UPDATE Paquete
SET IdEstadoPaquete = 5, IdUbicacionActual = @IdUbicacionOrigen
WHERE IdPaquete = @IdPaquete;

EXEC HacerMovimiento
	@IdPaquete = @IdPaquete,
	@Detalles = @Detalles,
	@IdUbicacionOrigen = @IdUbicacionOrigen,
	@IdUbicacionDestino = @IdUbicacionDestino;

EXEC ActualizarMovimiento
	@IdPaquete = @IdPaquete,
	@IdUbicacionOrigen = @IdUbicacionOrigen;
GO

--Recibir paquete en sucursal
GO
CREATE PROCEDURE RecibirPaqueteEnSucursal(
@IdPaquete INT)
AS
DECLARE @IdUbicacionActual AS INT,
@IdCliente AS INT;

SET @IdCliente = (SELECT IdCliente 
FROM PAQUETE
Where IdPaquete = @IdPaquete);

SET @IdUbicacionActual =  (SELECT SucursalPreferido FROM Cliente
WHERE IdCliente = @IdCliente)

INSERT INTO InventarioSucursal (IdSucursal, 
IdPaquete, FechaLlegada, FechaSalida)
VALUES (@IdUbicacionActual, 
@IdPaquete, GETDATE(), NULL);

SET @IdUbicacionActual = @IdUbicacionActual + 3;

UPDATE Paquete
SET IdEstadoPaquete = 12, IdUbicacionActual = @IdUbicacionActual
WHERE IdPaquete = @IdPaquete;

EXEC ActualizarMovimiento
	@IdPaquete = @IdPaquete,
	@IdUbicacionOrigen = @IdUbicacionActual;

EXEC ActuralizarPrecio
	@IdPaquete = @IdPaquete;
GO

--Generar Header de la factura
GO
CREATE PROCEDURE GenerarHeaderFactura
@IdSucursal INT,
@IdCliente INT,
@NFC nvarchar(20),
@EsDelivery BIT

AS
DECLARE @MontoDelivery AS MONEY;
DECLARE @MontoFinal AS MONEY;

IF @EsDelivery = 0  
   Set @MontoDelivery = 0
ELSE
	SET @MontoDelivery = 200;

INSERT INTO FacturaHeader ([IdSucursal], 
[IdCliente], [NFC], [MontoDelivery], 
[Bruto], [Descuento], [MontoTotal], Fecha, [EsPagada], [IdMetodoPago] )
VALUES (@IdSucursal, @IdCliente, @NFC, @MontoDelivery,
0, 0, 0, GETDATE(), 0, NULL);
GO


--Agregar paquetes a la factura
GO
CREATE PROCEDURE AgregarPaquetesAFactura
@IdFacturaHeader INT,
@IdPaquete INT

AS
DECLARE @Precio AS MONEY,
@MontoDelivery AS MONEY,
@EsDelivery AS BIT;

SET @Precio = (SELECT MontoAPagarPorPaquete 
FROM PAQUETE
WHERE IdPaquete = @IdPaquete)

SET @MontoDelivery = ( SELECT MontoDelivery 
FROM FacturaHeader
Where IdFacturaHeader = @IdFacturaHeader)

IF @MontoDelivery > 0  
   Set @EsDelivery = 1
ELSE
	SET @EsDelivery = 0;

UPDATE Paquete
SET EsDelivery = @EsDelivery
WHERE IdPaquete = @IdPaquete;

INSERT INTO FacturaDetail(IdPaquete, 
IdFacturaHeader, Precio, Fecha)
VALUES (@IdPaquete, @IdFacturaHeader, @Precio, GETDATE());

GO


--Procedure to show bill
Create PROCEDURE GenerarFacturaNoPagada
@IdFacturaHeader INT,
@Descuento MONEY
AS
DECLARE @MontoDelivery AS MONEY;
DECLARE @MontoFinal AS MONEY;
DECLARE @MontoPaquetes AS MONEY;
DECLARE @MontoPaquetesConDescuento AS MONEY;

SET @MontoDelivery = (SELECT MontoDelivery 
FROM FacturaHeader
WHERE IdFacturaHeader = @IdFacturaHeader)

SET @MontoPaquetes = (SELECT SUM(Precio)
FROM FacturaDetail
WHERE IdFacturaHeader = @IdFacturaHeader);

SET @MontoPaquetesConDescuento = @MontoPaquetes - @Descuento;
SET @MontoFinal = @MontoDelivery + @MontoPaquetesConDescuento;

UPDATE FacturaHeader
SET Bruto = @MontoPaquetes, 
Descuento = @Descuento,
MontoTotal = @MontoFinal
WHERE IdFacturaHeader = @IdFacturaHeader
GO

--Pagar Factura
GO
CREATE PROCEDURE PagarFactura
@IdFacturaHeader INT,
@IdMetodoPago INT
AS
DECLARE @IdPaquete AS INT;

SELECT IdPaquete  INTO #TempTable
FROM FacturaDetail FD 
JOIN FacturaHeader FH ON FH.IdFacturaHeader = FD.IdFacturaHeader
WHERE FD.IdFacturaHeader = @IdFacturaHeader

WHILE (EXISTS(SELECT * FROM #TempTable))
BEGIN
	IF (EXISTS(SELECT * FROM #TempTable))
		BEGIN
			SET @IdPaquete = (SELECT TOP(1) IdPaquete 
			FROM #TempTable);
			UPDATE Paquete
			SET IdEstadoPaquete = 6
			WHERE IdPaquete = @IdPaquete;
		END
	DELETE TOP(1)
	FROM #TempTable;
END

DROP TABLE #TempTable;
UPDATE FacturaHeader
SET EsPagada = 1, IdMetodoPago = @IdMetodoPago
WHERE IdFacturaHeader = @IdFacturaHeader
GO

--Entregar Paquete via sucursal
CREATE PROCEDURE EntregarPaquete
@IdFacturaHeader INT
AS
DECLARE @IdSucursal AS INT;
DECLARE @IdPaquete AS INT;


SELECT IdPaquete  INTO #TempTable
FROM FacturaDetail FD 
JOIN FacturaHeader FH ON FH.IdFacturaHeader = FD.IdFacturaHeader
WHERE FD.IdFacturaHeader = @IdFacturaHeader

WHILE (EXISTS(SELECT * FROM #TempTable))
BEGIN
	IF (EXISTS(SELECT * FROM #TempTable))
		BEGIN
			SET @IdPaquete = (SELECT TOP(1) IdPaquete 
			FROM #TempTable);

			
			SET @IdSucursal = (SELECT (IdUbicacionActual-3) 
			FROM Paquete
			WHERE IdPaquete = @IdPaquete);

			UPDATE Paquete
			SET IdEstadoPaquete = 7
			WHERE IdPaquete = @IdPaquete

			UPDATE InventarioSucursal
			SET FechaSalida = GETDATE()
			WHERE IdPaquete = @IdPaquete and IdSucursal = @IdSucursal
		END
	DELETE TOP(1)
	FROM #TempTable;
END

DROP TABLE #TempTable;


GO

--Enviar Paquete via delivery
CREATE PROCEDURE EnviarPaquete
@IdFacturaHeader INT,
@IdPersonal INT,
@IdDireccion INT
AS
DECLARE @IdSucursal AS INT;
DECLARE @IdPaquete AS INT;

SELECT IdPaquete  INTO #TempTable
FROM FacturaDetail FD 
JOIN FacturaHeader FH ON FH.IdFacturaHeader = FD.IdFacturaHeader
WHERE FD.IdFacturaHeader = @IdFacturaHeader

WHILE (EXISTS(SELECT * FROM #TempTable))
BEGIN
	IF (EXISTS(SELECT * FROM #TempTable))
		BEGIN
			SET @IdPaquete = (SELECT TOP(1) IdPaquete 
			FROM #TempTable);

			UPDATE Paquete
			SET IdEstadoPaquete = 8
			WHERE IdPaquete = @IdPaquete;

			UPDATE InventarioSucursal
			SET FechaSalida = GETDATE()
			WHERE IdPaquete = @IdPaquete;
		END
	DELETE TOP(1)
	FROM #TempTable;
END

DROP TABLE #TempTable;

INSERT INTO Delivery (IdFacturaHeader, IdPersonal, IdDireccion, EsTerminado, TiempoEnviado, TiempoRecibido)
VALUES (@IdFacturaHeader, @IdPersonal, @IdDireccion, 0, GetDate(), NULL);
GO



--Entregar Paquete via sucursal
CREATE PROCEDURE EntregarPaqueteDelivery
@IdFacturaHeader INT
AS
DECLARE @IdSucursal AS INT;
DECLARE @IdPaquete AS INT;


SELECT IdPaquete  INTO #TempTable
FROM FacturaDetail FD 
JOIN FacturaHeader FH ON FH.IdFacturaHeader = FD.IdFacturaHeader
WHERE FD.IdFacturaHeader = @IdFacturaHeader

WHILE (EXISTS(SELECT * FROM #TempTable))
BEGIN
	IF (EXISTS(SELECT * FROM #TempTable))
		BEGIN
			SET @IdPaquete = (SELECT TOP(1) IdPaquete 
			FROM #TempTable);

			
			SET @IdSucursal = (SELECT (IdUbicacionActual-3) 
			FROM Paquete
			WHERE IdPaquete = @IdPaquete);

			UPDATE Paquete
			SET IdEstadoPaquete = 7
			WHERE IdPaquete = @IdPaquete

			UPDATE InventarioSucursal
			SET FechaSalida = GETDATE()
			WHERE IdPaquete = @IdPaquete and IdSucursal = @IdSucursal
		END
	DELETE TOP(1)
	FROM #TempTable;
END

DROP TABLE #TempTable;

UPDATE Delivery
	SET TiempoRecibido = GETDATE()
	WHERE IdFacturaHeader = @IdFacturaHeader
GO