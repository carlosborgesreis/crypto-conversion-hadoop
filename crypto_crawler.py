import os
import csv
import requests
from datetime import datetime
from bs4 import BeautifulSoup
import os
import sys 

wdir = sys.argv[1]
url = "https://m.investing.com/crypto/"

request_string = requests.get(url = url, headers = {'User-Agent':'curl/7.52.1'})
soup = BeautifulSoup(request_string.text, "html.parser") 

# Faz o scrap do objeto soup que indica uma tabela no html
page_content = soup.findAll('tr')

# Formata a data para yyyy-mm-dd hh:mm:ss
print(request_string.headers['Date'][:-4])
date = datetime.strptime(request_string.headers['Date'][:-4], '%a, %d %b %Y %H:%M:%S').strftime('%Y-%d-%m_%H:%M:%S')

output_file = f"{wdir}/carlosReis/crawler_crypto/crypto_data_{date}.csv"

# Cria e popula o arquivo CSV.:
with open(output_file, "a+") as csv_file:
    wr = csv.writer(csv_file, delimiter = ";")

    #Verifica se o arquivo está vazio, e escreve o cabeçalho.
    if os.stat(output_file).st_size == 0:
        wr.writerow(["code", "name", "priceUSD", "change24H", "change7D", "symbol", "priceBTC", "marketCap", "volume24H", "totalVolume", "timestamp"])

    for line in page_content[1:]:
        # Remove as tabulações da linha
        formatted_line = line.get_text().replace('\t', '').split('\n')

        # Filtra os valores vazios da linha
        filtered_line = list(filter(None, formatted_line))

        #Popula o csv com a linha
        wr.writerow([filtered_line[0],filtered_line[1],filtered_line[2].replace(",", ""),filtered_line[3],filtered_line[4],filtered_line[5],filtered_line[6],filtered_line[7],filtered_line[8],filtered_line[9], date])


