#!/usr/bin/env bash

echo "Instalando o python 3, o pip 3 e o unzip com apt-get"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install zip unzip -y > /dev/null 2>&1
sudo apt-get install python3 -y > /dev/null 2>&1
sudo apt-get install python3-pip -y > /dev/null 2>&1

echo "Instalando os componentes necessários no processamento: requests, beautifulsoup4, glob3, pandas"
pip3 install requests > /dev/null 2>&1
pip3 install beautifulsoup4 > /dev/null 2>&1
pip3 install glob3 > /dev/null 2>&1
pip3 install pandas > /dev/null 2>&1

echo "Criando os diretórios locais"
mkdir -p carlosReis > /dev/null 2>&1
mkdir -p carlosReis/bin > /dev/null 2>&1
mkdir -p carlosReis/crawler_crypto > /dev/null 2>&1
mkdir -p carlosReis/crawler_crypto/processados > /dev/null 2>&1
mkdir -p carlosReis/crawler_crypto/consolidados > /dev/null 2>&1
mkdir -p carlosReis/crawler_crypto/consolidados/transferidos > /dev/null 2>&1
mkdir -p carlosReis/crawler_dolar > /dev/null 2>&1
mkdir -p carlosReis/crawler_dolar/transferidos > /dev/null 2>&1
mkdir -p carlosReis/processados_json > /dev/null 2>&1
mkdir -p carlosReis/processados_json/indexados > /dev/null 2>&1

echo "Criando os diretórios no hdfs"
hdfs dfs -mkdir -p /user/carlosReis > /dev/null 2>&1
hdfs dfs -mkdir -p /user/carlosReis/input > /dev/null 2>&1
hdfs dfs -mkdir -p /user/carlosReis/input/processados > /dev/null 2>&1
hdfs dfs -mkdir -p /user/carlosReis/output > /dev/null 2>&1
hdfs dfs -mkdir -p /user/carlosReis/output/transferidos > /dev/null 2>&1

echo "Fazendo download dos scripts no github, descompactando e realocando os scripts"
wget --no-check-certificate --content-disposition https://github.com/carlosborgesreis/desafio_semantix_scripts/archive/master.zip > /dev/null 2>&1
unzip desafio_semantix_scripts-master.zip > /dev/null 2>&1
mv desafio_semantix_scripts-master/*.py carlosReis/bin
mv desafio_semantix_scripts-master/*.sh carlosReis/bin
mv desafio_semantix_scripts-master/*.jar carlosReis/bin
chmod +x carlosReis/bin/*
rm desafio_semantix_scripts-master.zip
rm -r desafio_semantix_scripts-master

echo "Adicionando os crawlers ao crontab"
# Crawler das criptomoedas a cada 20 minutos
(crontab -l 2>&1; echo "53 20 * * * cd $PWD/carlosReis/bin && /usr/bin/python3 $PWD/carlosReis/bin/crypto_crawler.py $PWD") | crontab -
# Consolidação dos dados das criptomoedas uma vez por dia às 12:01
(crontab -l 2>&1; echo "56 20 */1 * * cd $PWD/carlosReis/bin && /usr/bin/python3 $PWD/carlosReis/bin/crypto_join_copy.py $PWD") | crontab -
# Crawler do dólar uma vez por dia às 18:00
(crontab -l 2>&1; echo "54 20 */1 * * cd $PWD/carlosReis/bin && /usr/bin/python3 $PWD/carlosReis/bin/dolar_crawler.py $PWD") | crontab -

# Adicionando permissões ao script que envia dados para o hdfs
chmod +x $PWD/carlosReis/bin/carlosReisData_send_to_hdfs.sh
# Adicionando os scripts de envio ao hdfs e processamento dos dados enviados ao crontab
(crontab -l 2>&1; echo "58 20 */1 * * cd $PWD/carlosReis/bin && $PWD/carlosReis/bin/carlosReisData_send_to_hdfs.sh $PWD") | crontab -





