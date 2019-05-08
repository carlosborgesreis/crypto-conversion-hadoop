#!/usr/bin/env bash
/usr/bin/python3 $1/carlosReis/bin/dolar_zip_transferidos.py $1
hdfs dfs -put $1/carlosReis/crawler_crypto/consolidados/crypto_data.csv /user/carlosReis/input
hdfs dfs -put $1/carlosReis/crawler_dolar/dolar_data.csv /user/carlosReis/input
hdfs dfs -put $1/carlosReis/crawler_crypto/consolidados/crypto_data.csv /user/carlosReis/input/processados
hdfs dfs -put $1/carlosReis/crawler_dolar/dolar_data.csv /user/carlosReis/input/processados
rm $1/carlosReis/crawler_crypto/consolidados/crypto_data.csv
rm $1/carlosReis/crawler_dolar/dolar_data.csv

# Processa os dados no hdfs e os pega de volta no final
spark-submit --master local[*] $1/carlosReis/bin/processamento_spark.jar

hdfs dfs -get "/user/carlosReis/output/*.json" $1/carlosReis/processados_json
hdfs dfs -rm "/user/carlosReis/output/*.json"

/usr/bin/python3 $1/carlosReis/bin/rename_json_file.py $1
