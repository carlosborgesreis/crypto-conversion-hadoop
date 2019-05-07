# Script para consolidar os dados oriundos do crawler das criptomoedas em um único arquivo csv
import os
import glob
import pandas as pd
import zipfile
import datetime
import sys

wdir = sys.argv[1]
# Setando a pasta onde os arquivos estão salvos e a sua extensão
os.chdir(f"{wdir}/carlosReis/crawler_crypto")
extension = "csv"
all_filenames = [i for i in glob.glob("*.csv")]

timestamp = datetime.date.today().strftime("%Y-%d-%m")
filename = f"{wdir}/carlosReis/crawler_crypto/consolidados/crypto_data.csv"

# Combinando os arquivos
combined_csv = pd.concat([pd.read_csv(f) for f in all_filenames ])
# Exportando para csv na pasta de consolidados
combined_csv.to_csv(filename, index=False, encoding="utf-8-sig")

for file_path in all_filenames:
    os.remove(file_path)
