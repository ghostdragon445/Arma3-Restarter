import os

root = '' #TODO Add directory to scan

for folderName, subfolders, filenames in os.walk(root):
    print(folderName)

    for subfolder in subfolder:
        print(subfolder)

    for filename in filenames:
        print(filename)

    print('')
