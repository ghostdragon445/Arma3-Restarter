import os
import configparser
import subprocess
import psutil
import shutil

# file paths to config files
cfgFile = "Config.cfg"


# Reads config file
parser = configparser.ConfigParser()
parser.read(cfgFile)

# save to variable
global arma_ser_pid
global bec_pid
global hc_pid
global workshop_dir
global readme_dir
global server_dir
arma_ser_pid = parser.getint('PIDs', "Arma3")
bec_pid = parser.getint("PIDs", 'BEC')
hc_pid = parser.getint('PIDs', 'HC')
workshop_dir = parser.get('Workshop', 'Dir')
readme_dir = parser.get('Sync files path', 'Readme Path')

server_dir = parser.get('Server location', 'Server root')


# TODO:Testing
# Check if server is running
print('Checking if server already exists...')
if psutil.pid_exists(arma_ser_pid):
    print("closing existing server...")
    os.popen('TASKKILL /PID ' + str(arma_ser_pid) + ' /F')
else:



# TODO:Testing
# Check if BEC is running
print('Checking if BEC already exists...')
if psutil.pid_exists(bec_pid):
    print("closing existing BEC instance...")
    os.popen('TASKKILL /PID ' + str(bec_pid) + ' /F')
else:


# TODO:Testing
# Check if headless client is running
print('Checking if Headless client already exists...')
if psutil.pid_exists(hc_pid):
    print("closing existing Headless client...")
    os.popen('TASKKILL /PID ' + str(hc_pid) + ' /F')
else:

# TODO:code to check for steam mod updates and copy files needed
def Steam_check:
    for folderName, subfolders, filenames in os.walk(workshop_dir):
        print(folderName)

        for subfolder in subfolder:
            print(subfolder)

        for filename in filenames:
            print(filename)

        print('')

# TODO:copy none steam files for use on server
def CustomMods_check():
    for folderName, subfolders, filenames in os.walk(workshop_dir):
        print(folderName)

        for subfolder in subfolder:
            print(subfolder)

        for filename in filenames:
            print(filename)

        print('')

# TODO: copy arma3 readme file from centralised location
dest_dir = server_dir + 'readme.txt'
shutil.copyfile(readme_dir, dest_dir)

# sync keys folder
dest_dir = server_dir
shutil.copy(_dir, dest_dir)
# sync mpmissions
dest_dir = server_dir
shutil.copy(mpmissions_dir, dest_dir)
# sync beserver.cfg

# archive server logs


# archive BEC logs

# Back up options

# TODO: Steam check for server update

# use TADST profile if not use defaults


# TODO:start server
# subprocess.run(Arma3Server)

# TODO: start BEC

# TODO:start HC

# TODO:check server status

# TODO:Check bec status

# TODO:check HC status


# TODO: if bec or HC crash 3 times print error and restart all

# TODO:restart at set time

# TODO: on exit close bec, hc and server
