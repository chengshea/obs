#!/bin/bash

<<EOF
localpg

EOF

url(){
  echo "Grafana URL: https://granfana.local.org"
  echo "admin 123456"
}


pge_start(){
bash /opt/ELK/elasticsearch-7.17.1/elasticsearch.sh start

docker compose -f /home/cs/oss/k8s-1.26/monitor/exporter/exporter.yaml up -d

docker compose -f /home/cs/oss/k8s-1.26/monitor/pg/pgbeat.yaml up -d
}

vmge_start(){

docker compose -f /home/cs/oss/k8s-1.26/monitor/exporter/exporter.yaml up -d

docker compose -f /home/cs/oss/k8s-1.26/monitor/pg/g.yaml up -d

docker compose -f /home/cs/oss/k8s-1.26/monitor/victoriametrics/cluster.yaml up -d
}

thanos(){
     docker compose -f   /home/cs/oss/k8s-1.26/store/minio/docker-compose.yml   up -d
     nc -z -v minio.ui.k8s.cn 9090 || exit 1

    docker compose -f  /home/cs/oss/k8s-1.26/monitor/victoriametrics/thanos-remote-read/thanos.yaml   up -d
     echo "https://minio.ui.k8s.cn:9090/browser"
     echo "httpslocal.org:10902"

}



pg_down(){
docker compose -f /home/cs/oss/k8s-1.26/monitor/exporter/exporter.yaml down

docker compose -f /home/cs/oss/k8s-1.26/monitor/pg/pg.yaml down

bash /opt/ELK/elasticsearch-7.17.1/elasticsearch.sh stop
}



yml(){
cat <<EOF
>>>>elasticsearch
bash /opt/ELK/elasticsearch-7.17.1/elasticsearch.sh 

>>>>>prometheus grafana beat es
docker compose -f /home/cs/oss/k8s-1.26/monitor/pg/pgbeat.yaml up -d 

>>>>>grafana
docker compose -f /home/cs/oss/k8s-1.26/monitor/pg/g.yaml up -d 

>>>>>exporter (redis ,mysql postgres )
docker compose -f /home/cs/oss/k8s-1.26/monitor/exporter/exporter.yaml up -d  

>>>>>thanos-remote-read s3
docker compose -f  /home/cs/oss/k8s-1.26/monitor/victoriametrics/thanos-remote-read/thanos.yaml

>>>>> s3 minio
docker compose -f   /home/cs/oss/k8s-1.26/store/minio/docker-compose.yml

>>>>> vm cluster
docker compose -f /home/cs/oss/k8s-1.26/monitor/victoriametrics/cluster.yaml up -d

>>>>> vm log
docker compose -f /home/cs/oss/k8s-1.26/monitor/victoriametrics/log.yaml 


  
>>>>> oap ui
docker compose -f  /home/cs/oss/k8s-1.26/apm/oap/banyandb-oap-ui.yaml
>>>>>oap  otel all=exporter.yaml
docker compose -f  /home/cs/oss/k8s-1.26/apm/oap/otel-all.yaml 




>>>>>> exporter  jaeger
docker compose -f  /home/cs/oss/k8s-1.26/apm/jaeger/jaegerotel.yaml


>>>>>signoz
docker compose -f  /home/cs/oss/k8s-1.26/apm/signoz/signoz.yaml



>>>>
docker network ls --no-trunc
删除所有未被容器使用的网络
docker network prune


>>><none>
docker rmi `docker images | grep -E \<none\> | awk '{print$3}'`
EOF
}







case $1 in
  se)
     pge_start
     url
   ;;
  tm)
     thanos
   ;;
  d|down)
   pg_down
  ;;
  re)
     yml
  ;;
  *)
   echo "bahs ./start.sh [se|d|tm|re]"
  ;;
esac 
