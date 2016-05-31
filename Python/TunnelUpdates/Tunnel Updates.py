import arcpy


Table = r"Database Connections\PUB-CEO.sde\ScanUpdates"
Fields = ["FARO_URL", "OBJECTID"]

edit = arcpy.da.Editor(r"Database Connections\PUB-CEO.sde")
edit.startEditing(False, True)
edit.startOperation()
with arcpy.da.UpdateCursor(Table, Fields) as Cursor:
    for GisRow in Cursor:
        if GisRow[0] == None:
            pass
        else:
            ScanURL = GisRow[0]
            ShorttenURL = ScanURL[25:]
            print ShorttenURL
            NewScanURL = "http://faro.irgia.com:8400?" + ShorttenURL
            GisRow[0] = NewScanURL
            Cursor.updateRow(GisRow)
del GisRow
del Cursor
edit.stopOperation()
# Stop editing and save changes
edit.stopEditing(True)
