import os
import configparser
import subprocess
import psutil
import shutil
import zipfile
# Create variables
cfgFile = "Config.cfg"


# Reads config file
class ParseConf:
    parser = configparser.ConfigParser()
    parser.read(cfgFile)
    # save to variable
    arma_ser_pid = parser.getint('PIDs', "Arma3")
    bec_pid = parser.getint("PIDs", 'BEC')
    hc_pid = parser.getint('PIDs', 'HC')
    workshop_dir = parser.get('Workshop', 'Path')
    custom_dir = parser.get('Sync files path', 'Custom path')
    readme_dir = parser.get('Sync files path', 'Readme Path')
    server_dir = parser.get('Server location', 'Server Path')



# TODO:Testing
# Check if server is running

class ServerCheck:
    print('Checking if server already exists...')
    if psutil.pid_exists(ParseConf.arma_ser_pid):
        print("closing existing server...")
        os.popen('TASKKILL /PID ' + str(ParseConf.arma_ser_pid) + ' /F')
    else:
        StartSequence()




# TODO:Testing
# Check if BEC is running
class BecCheck:
    print('Checking if BEC already exists...')
    if psutil.pid_exists(ParseConf.bec_pid):
        print("closing existing BEC instance...")
        os.popen('TASKKILL /PID ' + str(ParseConf.bec_pid) + ' /F')
        ServerCheck
    else:
        ServerCheck


# TODO:Testing
# Check if headless client is running
class HeadlessCheck:
    print('Checking if Headless client already exists...')
    if psutil.pid_exists(ParseConf.hc_pid):
        print("closing existing Headless client...")
        os.popen('TASKKILL /PID ' + str(ParseConf.hc_pid) + ' /F')
        BecCheck
    else:
        BecCheck


# TODO:code to check for steam mod updates and copy files needed
class SteamCheck:
    for folderName, subfolders, filenames in os.walk(ParseConf.workshop_dir):
        print(folderName)

        for subfolder in subfolder:
            print(subfolder)

        for filename in filenames:
            print(filename)

        print('')


# TODO:copy none steam files for use on server
class CustomModsCheck:
    for folderName, subfolders, filenames in os.walk(ParseConf.custom_dir):
        print(folderName)

        for subfolder in subfolder:
            print(subfolder)

        for filename in filenames:
            print(filename)

        print('')


# TODO: copy arma3 readme file from centralised location
class CopyReadme:
    dest_dir = ParseConf.server_dir + 'readme.txt'
    shutil.copyfile(ParseConf.readme_dir, dest_dir)


# sync keys folder
class CopyKeys:
    dest_dir = ParseConf.server_dir
    shutil.copy(ParseConf.keys_dir, dest_dir)


# sync mpmissions
class CopyMissions:
    dest_dir = ParseConf.server_dir
    shutil.copy(ParseConf.mpmissions_dir, dest_dir)


# sync beserver.cfg
class CopyBeServer:
    dest_dir = ParseConf.server_dir  # Edit to BEserver.cfg location
    shutil.copy(ParseConf.mpmissions_dir, dest_dir)
# archive server logs
# investigate usage of zipfile
class ZipLog:
    if ParseConf.zip_log_en = True:



# archive BEC logs

# Back up optionsz

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
