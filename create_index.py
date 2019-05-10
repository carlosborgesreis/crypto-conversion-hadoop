from elasticsearch import Elasticsearch 
import json, sys, glob

# Criando a conexão com o elasticsearch
es=Elasticsearch([{'host':'localhost','port':9200}])
wdir = sys.argv[1]

file_path = glob.glob(f"{wdir}/carlosReis/processados_json/*.json")[0]
file_name = file_path.split("/").replace(".json", "")
index_name = 'cotacao-cripto-' + file_name

json_cotacao = open(file_path, 'r')

es.indices.create(index=index_name, body=json_cotacao)
es.indices.put_settings(index=index_name, body={
  "settings" : {
        "index" : {
            "number_of_shards" : 1, 
            "number_of_replicas" : 0 
        }
    }
})
es.indices.put_alias(index=index_name, name="cotacao-cripto")

