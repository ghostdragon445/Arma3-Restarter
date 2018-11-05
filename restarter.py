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
    zip_log_en = parser.getboolean('Archive', 'Archive server log')
    zip_log_path = parser.get('Archive', 'Server log path')
    zip_log_ignore = parser.get('Archive', 'log to leave')





# TODO:Testing
# Check if server is running

def ServerCheck():
    print('Checking if server already exists...')
    if psutil.pid_exists(ParseConf.arma_ser_pid):
        print("closing existing server...")
        os.popen('TASKKILL /PID ' + str(ParseConf.arma_ser_pid) + ' /F')
        BecCheck()
    else:
        BecCheck()




# TODO:Testing
# Check if BEC is running
def BecCheck:
    print('Checking if BEC already exists...')
    if psutil.pid_exists(ParseConf.bec_pid):
        print("closing existing BEC instance...")
        os.popen('TASKKILL /PID ' + str(ParseConf.bec_pid) + ' /F')
        HeadlessCheck()
    else:
        HeadlessCheck()


# TODO:Testing
# Check if headless client is running
def HeadlessCheck:
    print('Checking if Headless client already exists...')
    if psutil.pid_exists(ParseConf.hc_pid):
        print("closing existing Headless client...")
        os.popen('TASKKILL /PID ' + str(ParseConf.hc_pid) + ' /F')
        StartSequence()
    else:
        StartSequence()


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
    log_paths = []
    sorted_log_paths = []
    if ParseConf.zip_log_en:
        for file in os.listdir(ParseConf.zip_log_path):
            if file.endswith('.log'):
                log_path = ParseConf.zip_log_path + file
                log_paths.append(log_path)
                sorted_log_paths = sorted(log_paths, key=os.path.getctime)
                for x in range(len(sorted_log_path)):
                    if x >= ParseConf.zip_log_ignore:
                        with zipfile.ZipFile('my_python_files.zip', 'w') as zip:
                            # writing each file one by one
                            zip.write(sorted_log_paths[x])





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
