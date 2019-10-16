USE CampusEngineeringOperations

-- When a new barcode is applied to an extinguisher convert all previous inspection records from old barcode to new one.

UPDATE FireExtinguishersInspections
SET LocationBarCode = new.NewLocationBarcode
FROM FireExtinguishersBarcodeUpdates as new
WHERE FireExtinguishersInspections.LocationBarCode = new.OldLocationBarcode AND new.Processed = 'No'
GO

UPDATE FireExtinguishersBarcodeUpdates
SET Processed = 'Yes'
WHERE Processed = 'No'
GO

-- Update Fire Extinguisher Progress Table which controlls web map building colors

TRUNCATE TABLE FireExtinguishersBuildingInspectionsProgress
GO

INSERT INTO FireExtinguishersBuildingInspectionsProgress
SELECT *
FROM ViewFireExtinguisherBuildingInspectionProgress
GO








