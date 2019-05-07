#!/usr/bin/env bash

# Assumindo que o sistema seja ubuntu, instala o python 3, o pip 3 e o unzip
sudo apt-get update
sudo apt-get install zip unzip -y
sudo apt-get install python3 -y
sudo apt-get install python3-pip -y

# Instalação dos componentes necessários no processamento
pip3 install requests
pip3 install beautifulsoup4
pip3 install glob3
pip3 install pandas

# Criação das pastas locais
mkdir -p carlosReis
mkdir -p carlosReis/bin
mkdir -p carlosReis/crawler_crypto
mkdir -p carlosReis/crawler_crypto/processados
mkdir -p carlosReis/crawler_crypto/consolidados
mkdir -p carlosReis/crawler_crypto/consolidados/transferidos
mkdir -p carlosReis/crawler_dolar
mkdir -p carlosReis/crawler_dolar/transferidos
mkdir -p carlosReis/processados_json
mkdir -p carlosReis/processados_json/indexados

# Criação das pastas no hdfs
hdfs dfs -mkdir -p /user/carlosReis
hdfs dfs -mkdir -p /user/carlosReis/input
hdfs dfs -mkdir -p /user/carlosReis/input/processados
hdfs dfs -mkdir -p /user/carlosReis/output
hdfs dfs -mkdir -p /user/carlosReis/output/transferidos

# Download dos scripts no github, descompactação e realocação dos scripts
wget --no-check-certificate --content-disposition https://github.com/carlosborgesreis/desafio_semantix_scripts/archive/master.zip
unzip desafio_semantix_scripts-master.zip
mv desafio_semantix_scripts-master/*.py carlosReis/bin
mv desafio_semantix_scripts-master/*.sh carlosReis/bin
mv desafio_semantix_scripts-master/*.jar carlosReis/bin
chmod +x carlosReis/bin/*
rm desafio_semantix_scripts-master.zip
rm -r desafio_semantix_scripts-master

# Adicionando os crawlers ao crontab
# Crawler das criptomoedas a cada 20 minutos
(crontab -l 2>/dev/null; echo "*/20 * * * * cd $PWD/carlosReis/bin && /usr/bin/python3 $PWD/carlosReis/bin/crypto_crawler.py $PWD") | crontab -
# Consolidação dos dados das criptomoedas uma vez por dia às 12:01
(crontab -l 2>/dev/null; echo "5 18 */1 * * cd $PWD/carlosReis/bin && /usr/bin/python3 $PWD/carlosReis/bin/crypto_join_copy.py $PWD") | crontab -
# Crawler do dólar uma vez por dia às 18:00
(crontab -l 2>/dev/null; echo "0 18 */1 * * cd $PWD/carlosReis/bin && /usr/bin/python3 $PWD/carlosReis/bin/dolar_crawler.py $PWD") | crontab -

# Adicionando permissões ao script que envia dados para o hdfs
chmod +x carlosReis/bin/carlosReisData_send_to_hdfs.sh
# Adicionando os scripts de envio ao hdfs e processamento dos dados enviados ao crontab
(crontab -l 2>/dev/null; echo "10 18 */1 * * cd $PWD/carlosReis/bin && $PWD/carlosReis/bin/carlosReisData_send_to_hdfs.sh $PWD") | crontab -





