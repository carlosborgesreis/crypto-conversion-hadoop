#!/usr/bin/env bash
cp $1carlosReis/crawler_crypto/processados/processados.zip $1carlosReis/crawler_crypto/consolidados/transferidos/transferidos.zip
/usr/bin/python3 $1/carlosReis/bin/dolar_zip_transferidos.py
hdfs dfs -moveFromLocal $1/carlosReis/crawler_crypto/consolidados/crypto_data.csv /user/carlosReis/input
hdfs dfs -moveFromLocal $1/carlosReis/crawler_dolar/dolar_data.csv /user/carlosReis/input

# Processa os dados no hdfs e os pega de volta no final
spark-submit --class processamento_spark --master local[*] $1/carlosReis/bin/processamento_spark.jar

hdfs dfs -get /user/carlosReis/output/processado_data.json $1/carlosReis/processados_json/
