#!/usr/bin/env bash
cp carlosReis/crawler_crypto/processados/processados.zip carlosReis/crawler_crypto/consolidados/transferidos/transferidos.zip
python3 dolar_zip_transferidos.py
hdfs dfs -moveFromLocal carlosReis/crawler_crypto/consolidados/crypto_data.csv /user/carlosReis/input
hdfs dfs -moveFromLocal carlosReis/crawler_dolar/dolar_data.csv /user/carlosReis/input
