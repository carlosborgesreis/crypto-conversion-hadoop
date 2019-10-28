curl -X PUT "localhost:9200/novofinally?pretty" -H 'Content-Type: application/json' -d'
{
 "settings": {
                "number_of_shards": 1,
                "number_of_replicas": 0
                }
        }       
 "mappings": {
  "doc": {
   "properties": {
    "code": {"type": "integer"},
    "name": {"type": "text"},
    "priceUSD": {"type": "float"},
    "change24H": {"type": "text"},
    "change7D": {"type": "text"},
    "symbol": {"type": "name"},
    "priceBTC": {"type": "name"},
    "priceReal": {"type": "float"},
   }
  }
 }
}
'


curl -s -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/novofinally/_bulk?pretty' --data-binary @json_pronto.json
