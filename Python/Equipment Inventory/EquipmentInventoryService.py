############################################################################# 
### Author: Jay Dahlstrom
### Entity: Campus Engineering, University of Washington
### Python Version: 2.7.8
### Date Created: September 21, 2015
### Last Modified Date: September 21, 2015
### 

############################################################################# 
### Description: Service script that runs each of the four procedures that
### are run to process updates from OASIS into the EIO GIS database.  It is
### now possible to run one single file instead of all four individually.  As
### a result data integrity is greatly improved.
###

############################################################################# 
### Libraries
###

# This script does not require any libraries

############################################################################# 
### Parameters
###

# This script does not have any parameters

#############################################################################  
###Script Follows
###

def main():
    # Run the Additions Procedure
    execfile('EquipmentInventoryAdditions.py')

    # Run the Updates Procedure
    execfile('EquipmentInventoryUpdates.py')
    
    # Run the Inactives Procedure
    execfile('EquipmentInventoryInactives.py')

    # Run the Roll Procedure
    execfile('EquipmentInventoryRollup.py')
	
if __name__ == "__main__":
    main()
