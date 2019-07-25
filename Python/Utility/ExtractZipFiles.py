import os, zipfile

dir_name = r'C:\Users\jamesd26\Downloads'
extension = ".zip"

os.chdir(dir_name) # change directory from working dir to dir with files

for item in os.listdir(dir_name): # loop through items in dir
    if item.endswith(extension): # check for ".zip" extension
        file_name = os.path.abspath(item) # get full path of files
        output_dir = file_name[:-4]
        print file_name
        print output_dir
        zip_ref = zipfile.ZipFile(file_name) # create zipfile object
        zip_ref.extractall(output_dir) # extract file to dir
        zip_ref.close() # close file
        #os.remove(file_name) # delete zipped file
