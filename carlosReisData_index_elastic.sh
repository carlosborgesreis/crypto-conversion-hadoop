#!/usr/bin/env bash

curl -XPUT 'localhost:9200/cotacao-cripto' -H 'Content-Type: application/json' -d'{"settings" : {"index" : {"number_of_shards" : 1, "number_of_replicas" : 0 }}}'