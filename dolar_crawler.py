import os
import csv
import requests
import zipfile
from datetime import datetime
from bs4 import BeautifulSoup

url = "https://m.investing.com/currencies/usd-brl"

request_string = requests.get(url = url, headers = {'User-Agent':'curl/7.52.1'})
soup = BeautifulSoup(request_string.text, "html.parser") 

currency = "USD/BRL"
value = soup.find("span", "pid-2103-last").text.strip()
change = soup.find("i", "pid-2103-pc").text.strip()
perc = soup.find("i", "pid-2103-pcp").text.strip()
timestamp = datetime.strptime(request_string.headers['Date'][:-4], '%a, %d %b %Y %H:%M:%S')


output_file = f"carlosReis/crawler_dolar/dolar_data.csv"
output_zip_file = "carlosReis/crawler_dolar/"

with open(output_file, "a+") as csv_file:
    wr = csv.writer(csv_file, delimiter = ";")

    #Verifica se o arquivo está vazio, e escreve o cabeçalho.
    if os.stat(output_file).st_size == 0:
        wr.writerow(["currency", "value", "change", "perc", "timestamp"])

    wr.writerow([currency, value, change, perc, timestamp])
