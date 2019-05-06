#!/usr/bin/env bash
cp carlosReis/crawler_crypto/processados/processados.zip carlosReis/crawler_crypto/consolidados/transferidos/transferidos.zip
python3 dolar_zip_transferidos.py
hdfs dfs -moveFromLocal $1/carlosReis/crawler_crypto/consolidados/crypto_data.csv /user/carlosReis/input
hdfs dfs -moveFromLocal $1/carlosReis/crawler_dolar/dolar_data.csv /user/carlosReis/input

# Processa os dados no hdfs e os pega de volta no final
spark-submit --class processamento_spark --master local[*] $1/carlosReis/bin/processamento_spark_2.11-1.0.jar

hdfs dfs -get /user/carlosReis/output/processado_data.json $1/carlosReis/processados_json/
