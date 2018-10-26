import os
import
workshopdir = '' #TODO Add directory to scan

# TODO:read cfg file

#TODO: read PID file

#TODO: back up server files

# TODO:check if server is already running TODO

# TODO:check if BEC is already running TODO

# TODO:check if HC is already running TODO


# TODO:code to check for mod updates and copy files needed
# EU1/2/7
for folderName, subfolders, filenames in os.walk(workshopdir):
    print(folderName)

    for subfolder in subfolder:
        print(subfolder)

    for filename in filenames:
        print(filename)

    print('')

# TODO:copy none steam files for use on server

#TODO: copy arma3 readme file from centrilised location

# TODO:start server
#TODO: check for server update

#TODO:TODO: start BEC

# TODO:start HC

# TODO:check server status

# TODO:Check bec status

# TODO:check HC status


#TODO: if bec or HC crash 3 times print error and restart all

# TODO:restart at set time

#TODO: on exit close bec, hc and server