#!/usr/bin/env bash

# Checa o sistema atual e define o gerenciador de pacotes ideal
if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu
    sudo apt-get update
    sudo apt-get install python3 -y
    sudo apt-get install python3-pip -y
elif [ -f /etc/redhat-release ]; then
    # Red Hat, CentOS, etc.
    sudo yum -y update
    sudo yum -y install yum-utils
    sudo yum -y groupinstall development
    sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
    sudo yum -y install python36u
    sudo yum -y install python36-setuptools
    sudo easy_install-3.6 -y pip
    alias python3=$(which python3.6)
    alias pip3=$(which pip3.6)
fi

# Instalação dos componentes necessários no processamento

pip3 install requests
pip3 install beautifulsoup4
pip3 install glob3
pip3 install pandas

# Criação das pastas locais
mkdir carlosReis
mkdir carlosReis/bin
mkdir carlosReis/crawler_crypto
mkdir carlosReis/crawler_crypto/processados
mkdir carlosReis/crawler_crypto/consolidados
mkdir carlosReis/crawler_crypto/consolidados/transferidos
mkdir carlosReis/crawler_dolar
mkdir carlosReis/crawler_dolar/transferidos
mkdir carlosReis/processados_json
mkdir carlosReis/processados_json/indexados

# Criação das pastas no hdfs
hdfs dfs -mkdir /user/carlosReis
hdfs dfs -mkdir /user/carlosReis/input
hdfs dfs -mkdir /user/carlosReis/input/processados
hdfs dfs -mkdir /user/carlosReis/output
hdfs dfs -mkdir /user/carlosReis/output/transferidos

# Download dos scripts no github, descompactação e realocação dos scripts
wget --no-check-certificate --content-disposition https://github.com/carlosborgesreis/desafio_semantix_scripts/archive/master.zip
unzip desafio_semantix_scripts-master.zip
mv desafio_semantix_scripts-master/*.py carlosReis/bin
mv desafio_semantix_scripts-master/*.sh carlosReis/bin
rm desafio_semantix_scripts-master.zip
rm -r desafio_semantix_scripts-master

# Adicionando os crawlers ao crontab
# Crawler das criptomoedas a cada 20 minutos
(crontab -l 2>/dev/null; echo "*/20 * * * * python3 $PWD/carlosReis/bin/crypto_crawler.py $PWD") | crontab -
# Consolidação dos dados das criptomoedas uma vez por dia às 12:01
(crontab -l 2>/dev/null; echo "5 12 */1 * * python3 $PWD/carlosReis/bin/crypto_join_copy.py $PWD") | crontab -
# Crawler do dólar uma vez por dia às 12:00
(crontab -l 2>/dev/null; echo "0 12 */1 * * python3 $PWD/carlosReis/bin/dolar_crawler.py $PWD") | crontab -

# Adicionando permissões ao script que envia dados para o hdfs
chmod +x carlosReis/bin/carlosReisData_send_to_hdfs.sh
# Adicionando os scripts de envio ao hdfs e processamento dos dados enviados ao crontab
(crontab -l 2>/dev/null; echo "10 12 */1 * * $PWD/carlosReis/bin/carlosReisData_send_to_hdfs.sh $PWD") | crontab -





