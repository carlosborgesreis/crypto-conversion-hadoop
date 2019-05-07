#!/usr/bin/env bash
/usr/bin/python3 $1/carlosReis/bin/dolar_zip_transferidos.py $1
hdfs dfs -moveFromLocal $1/carlosReis/crawler_crypto/consolidados/crypto_data.csv /user/carlosReis/input
hdfs dfs -moveFromLocal $1/carlosReis/crawler_dolar/dolar_data.csv /user/carlosReis/input

# Processa os dados no hdfs e os pega de volta no final
spark-submit --master local[*] $1/carlosReis/bin/processamento_spark.jar

hdfs dfs -get "/user/carlosReis/output/*.json" $1/carlosReis/processados_json
hdfs dfs -rm "/user/carlosReis/output/*.json"
