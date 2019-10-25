#!/bin/bash


echo "Instalando o python 3, o pip 3 e o unzip com apt-get"
{ 
    sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
    sudo yum install -y python36u python36u-devel python36u-pip
    sudo yum install -y unzip    
} &> /dev/null

echo "Instalando os componentes necessários no processamento: requests, beautifulsoup4, glob3, pandas"
{
    sudo pip3 install requests
    sudo pip3 install beautifulsoup4
    sudo pip3 install glob3
    sudo pip3 install pandas
    sudo pip3 install elasticsearch
} &> /dev/null

echo "Criando os diretórios locais"
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

echo "Criando os diretórios no hdfs"
{
    hdfs dfs -mkdir -p carlosReis
    hdfs dfs -mkdir -p carlosReis/input
    hdfs dfs -mkdir -p carlosReis/input/processados
    hdfs dfs -mkdir -p carlosReis/output
    hdfs dfs -mkdir -p carlosReis/output/transferidos
} &> /dev/null

echo "Fazendo download dos scripts no github, descompactando e realocando os scripts"
{
    wget --no-check-certificate --content-disposition https://github.com/carlosborgesreis/desafio_semantix_scripts/archive/master.zip
    unzip desafio_semantix_scripts-master.zip
    mv desafio_semantix_scripts-master/*.py carlosReis/bin
    mv desafio_semantix_scripts-master/*.sh carlosReis/bin
    mv desafio_semantix_scripts-master/*.jar carlosReis/bin
    chmod +x carlosReis/bin/*
    rm desafio_semantix_scripts-master.zip
    rm -r desafio_semantix_scripts-master
} &> /dev/null

touch cronfile

echo "Adicionando os crawlers ao crontab em ordem de execução, uma por minuto"
# Crawler das criptomoedas a cada 20 minutos
echo "*/20 * * * * python3 ~/carlosReis/bin/crypto_crawler.py ~" >> cronfile
# Consolidação dos dados das criptomoedas uma vez por dia às 12:01
echo "1 23 * * * python3 ~/carlosReis/bin/crypto_join_copy.py ~" >> cronfile
# Crawler do dólar uma vez por dia às 14:00
echo "0 23 * * * python3 ~/carlosReis/bin/dolar_crawler.py ~" >> cronfile

# Envio ao hdfs e processamento dos dados enviados
echo "2 23 * * * python3 ~/carlosReis/bin/dolar_zip_transferidos.py ~" >> cronfile
echo "3 23 * * * hdfs dfs -put ~/carlosReis/crawler_crypto/consolidados/crypto_data.csv carlosReis/input" >> cronfile
echo "3 23 * * * hdfs dfs -put ~/carlosReis/crawler_dolar/dolar_data.csv carlosReis/input" >> cronfile
echo "3 23 * * * hdfs dfs -put ~/carlosReis/crawler_crypto/consolidados/crypto_data.csv carlosReis/input/processados" >> cronfile
echo "3 23 * * * hdfs dfs -put ~/carlosReis/crawler_dolar/dolar_data.csv carlosReis/input/processados" >> cronfile
echo "4 23 * * * rm ~/carlosReis/crawler_crypto/consolidados/crypto_data.csv" >> cronfile
echo "4 23 * * * rm ~/carlosReis/crawler_dolar/dolar_data.csv" >> cronfile

# Processa os dados no hdfs e os pega de volta no final
echo "5 23 * * * spark-submit --master local[*] ~/carlosReis/bin/processamento_spark.jar" >> cronfile
echo "6 23 * * * hdfs dfs -get \"carlosReis/output/*.json\" ~/carlosReis/processados_json" >> cronfile
echo "7 23 * * * hdfs dfs -rm -r \"carlosReis/output/*.json\"" >> cronfile
echo "8 23 * * * python3 ~/carlosReis/bin/rename_json_file.py ~" >> cronfile
echo "9 23 * * * python3 ~/carlosReis/bin/create_index.py ~" >> cronfile

crontab cronfile
