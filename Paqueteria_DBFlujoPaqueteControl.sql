Use Paqueteria;
BEGIN TRANSACTION [Tran1]
BEGIN TRY

EXEC RecibirPaqueteMiami 
	@TrackingNumber = '3232111eff',
	@Peso = 1,
	@Volumen = 1,
	@RemitienteId = 1,
	@Contenido = 'Libro programacion',
	@EsDelivery = NULL,
	@IdCliente = 4565
Go

SELECT * FROM EtiquetaManipulacion;
SELECT * FROM PaqueteEtiquetaManipulacion;

EXEC AgregarEtiquetaDeManipulacion 
	@IdPaquete = 12,
	@IdEtiquetaManipulacion = 12;
Go


SELECT * FROM TipoPAQUETE;
SELECT * FROM TipoPaquetePaquete;

EXEC AsignarTipoPaquete 
	@IdPaquete = 12,
	@IdTipoPaquete = 9;
Go

EXEC EmpacarPaquete 
	@IdPaquete = 12;
GO

EXEC EmbarcarPaquete 
	@IdPaquete = 12,
	@Detalles = NULL;
GO


EXEC RecibirPaqueteAILA 
	@IdPaquete = 12,
	@Detalles = NULL;
GO


EXEC RecibirPaqueteEnCD 
	@IdPaquete = 12,
	@Detalles = NULL;
GO

EXEC RecibirPaqueteEnSucursal 
@IdPaquete = 12;
GO
--Generamos cuerpo de factura Sucursal es Ubicacion menos 3
EXEC GenerarHeaderFactura @IdSucursal = 6,
@IdCliente = 4565,
@NFC = '323244433',
@EsDelivery = 0;

--Agregamos paquetes
EXEC AgregarPaquetesAFactura 
@IdFacturaHeader = 7,
@IdPaquete = 12;


EXEC GenerarFacturaNoPagada  
@IdFacturaHeader = 7,
@Descuento = 50;

EXEC PagarFactura  
@IdFacturaHeader = 7,
@IdMetodoPago = 2;

--EN SUCURSAL
EXEC EntregarPaquete @IdFacturaHeader = 7;

--Delivery
EXEC EnviarPaquete
@IdFacturaHeader = 6,
@IdPersonal = 3143,
@IdDireccion = 36

EXEC EntregarPaqueteDelivery 
@IdFacturaHeader = 6;



ROLLBACK TRANSACTION [Tran1]

END TRY

  BEGIN CATCH

      ROLLBACK TRANSACTION [Tran1]

  END CATCH  