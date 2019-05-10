#!/usr/bin/env bash

echo "Instalando o python 3, o pip 3 e o unzip com apt-get"
apt-get update > /dev/null 2>&1
apt-get install zip unzip -y > /dev/null 2>&1
apt-get install python3 -y > /dev/null 2>&1
apt-get install python3-pip -y > /dev/null 2>&1

echo "Instalando os componentes necessários no processamento: requests, beautifulsoup4, glob3, pandas"
pip3 install requests > /dev/null 2>&1
pip3 install beautifulsoup4 > /dev/null 2>&1
pip3 install glob3 > /dev/null 2>&1
pip3 install pandas > /dev/null 2>&1
pip3 install elasticsearch > /dev/null 2>&1

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

echo "Adicionando os crawlers ao crontab em ordem de execução, uma por minuto"
# Crawler das criptomoedas a cada 20 minutos
(crontab -l 2>&1; echo "*/20 * * * * cd $PWD && /usr/bin/python3 $PWD/carlosReis/bin/crypto_crawler.py $PWD") | crontab -
# Consolidação dos dados das criptomoedas uma vez por dia às 12:01
(crontab -l 2>&1; echo "43 13 * * * cd $PWD && /usr/bin/python3 $PWD/carlosReis/bin/crypto_join_copy.py $PWD") | crontab -
# Crawler do dólar uma vez por dia às 14:00
(crontab -l 2>&1; echo "42 13 * * * cd $PWD && /usr/bin/python3 $PWD/carlosReis/bin/dolar_crawler.py $PWD") | crontab -

# Envio ao hdfs e processamento dos dados enviados
(crontab -l 2>&1; echo "44 13 * * * cd $PWD && /usr/bin/python3 $PWD/carlosReis/bin/dolar_zip_transferidos.py $PWD >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "45 13 * * * cd $PWD && /usr/local/hadoop/bin/hdfs dfs -put $PWD/carlosReis/crawler_crypto/consolidados/crypto_data.csv /user/carlosReis/input >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "45 13 * * * cd $PWD && /usr/local/hadoop/bin/hdfs dfs -put $PWD/carlosReis/crawler_dolar/dolar_data.csv /user/carlosReis/input >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "45 13 * * * cd $PWD && /usr/local/hadoop/bin/hdfs dfs -put $PWD/carlosReis/crawler_crypto/consolidados/crypto_data.csv /user/carlosReis/input/processados >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "45 13 * * * cd $PWD && /usr/local/hadoop/bin/hdfs dfs -put $PWD/carlosReis/crawler_dolar/dolar_data.csv /user/carlosReis/input/processados >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "46 13 * * * cd $PWD && rm $PWD/carlosReis/crawler_crypto/consolidados/crypto_data.csv >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "46 13 * * * cd $PWD && rm $PWD/carlosReis/crawler_dolar/dolar_data.csv >> $PWD/carlosReis/log.log") | crontab -

# Processa os dados no hdfs e os pega de volta no final
(crontab -l 2>&1; echo "47 13 * * * cd $PWD && /usr/local/spark/bin/spark-submit --master local[*] $PWD/carlosReis/bin/processamento_spark.jar >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "48 13 * * * cd $PWD && /usr/local/hadoop/bin/hdfs dfs -get \"/user/carlosReis/output/*.json\" $PWD/carlosReis/processados_json >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "49 13 * * * cd $PWD && /usr/local/hadoop/bin/hdfs dfs -rm -r \"/user/carlosReis/output/*.json\" >> $PWD/carlosReis/log.log") | crontab -
(crontab -l 2>&1; echo "50 13 * * * cd $PWD && /usr/bin/python3 $PWD/carlosReis/bin/rename_json_file.py $PWD >> $PWD/carlosReis/log.log") | crontab -

