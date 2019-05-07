import zipfile
import os
import sys

wdir = sys.argv[1]

filename_dolar = f"{wdir}/carlosReis/crawler_dolar/dolar_data.csv"
filename_crypto = f"{wdir}/carlosReis/crawler_crypto/consolidados/crypto_data.csv"

with zipfile.ZipFile(f'{wdir}/carlosReis/crawler_dolar/transferidos/transferidos.zip', 'a') as myzip:
    myzip.write(filename_dolar)

# Cria uma cópia zipada na pasta transferidos
with zipfile.ZipFile(f"{wdir}/carlosReis/crawler_crypto/consolidados/transferidos/transferidos.zip", "a") as myzip:
    myzip.write(filename_crypto)

os.remove(f"{wdir}/carlosReis/crawler_crypto/*.csv")

