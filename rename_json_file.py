import os, sys, glob, shutil

wdir = sys.argv[1]
parent_folder = f"{wdir}/carlosReis/processados_json/"
folder_full_path = glob.glob(parent_folder + "*.json")[0]

folder_name = folder_full_path.split("/")[-1]
os.rename(folder_full_path, folder_full_path + "-temp")

file_full_path = glob.glob(folder_full_path + "-temp" + "/*.json")[0]
new_file_name = parent_folder + "/" + folder_name

shutil.move(file_full_path, new_file_name)
shutil.rmtree(folder_full_path + "-temp")

#print(file_full_path, folder_full_path + "/" + folder_name)