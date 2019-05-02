import zipfile
import os


filename = "carlosReis/crawler_dolar/dolar_data.csv"
with zipfile.ZipFile('carlosReis/crawler_dolar/transferidos/transferidos.zip', 'a+') as myzip:
    myzip.write(filename)

os.remove("carlosReis/crawler_dolar/*.csv")