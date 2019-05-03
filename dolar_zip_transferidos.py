import zipfile
import os
import sys

wdir = sys.argv[1]

filename = f"{wdir}/carlosReis/crawler_dolar/dolar_data.csv"
with zipfile.ZipFile('carlosReis/crawler_dolar/transferidos/transferidos.zip', 'a+') as myzip:
    myzip.write(filename)

os.remove(f"{wdir}/carlosReis/crawler_dolar/*.csv")