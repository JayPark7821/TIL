#!/bin/bash

echo "> 배포 환경 Profile 확인 $1"
TARGET_PROFILE=$1
echo "> 배포 환경 tag 확인 $2"
TARGET_TAG=$2
echo "> 배포 환경 ip 확인 $3"
TARGET_IP=$3


echo "> 현재 구동중인 Set 확인"
CURRENT_PORT=$(docker ps --filter name=image* --format "{{.Ports}}" | awk -F'[:>-]' '{print $2}')

if [ "${CURRENT_PORT}" == 8087 ]
then
  IDLE_PORT=8086
  echo "> 8086을 할당합니다."
elif [ "${CURRENT_PORT}" == 8086 ]
then
  IDLE_PORT=8087
  echo "> 8087을 할당합니다."
else
  echo "> 일치하는 SET이 없습니다."
  echo "> SET1 8086을 할당합니다."

  IDLE_PORT=8086
fi

echo "> IDLE_PORT = $IDLE_PORT"

docker run --name image-"${TARGET_TAG}" -d --rm \
                          -e "PROFILE=${TARGET_PROFILE}" -e "TAG=${TARGET_TAG}" -p ${IDLE_PORT}:8080 registry/image:"${TARGET_TAG}"

echo "> $TARGET_PROFILE 10초 후 Health check 시작"
echo "> curl -s http://$TARGET_IP:$IDLE_PORT/v1/deploy/up-tag "

sleep 10

for retry_count in {1..10}
do
     response=$(curl -s http://"${TARGET_IP}":"${IDLE_PORT}"/v1/deploy/up-tag)
     up_count=$(echo "${response}" | grep "${TARGET_TAG}" | wc -l)

     if [ $up_count -ge 1 ]
     then
             echo "> Health check 성공"
             break
     else
             echo "> Health check의 응답을 알 수 없거나 혹은 status가 UP이 아닙니다."
             echo "> Health check: ${response}"
     fi

     if [ $retry_count -eq 10 ]
     then
             echo "> Health check 실패. "
             echo "> Nginx에 연결하지 않고 배포를 종료합니다."
             exit 1
     fi
     echo "> Health check 연결 실패. 재시도…"
     sleep 10
done


echo "> swap "

echo "set \$service_url http://${TARGET_IP}:${IDLE_PORT};" | tee /etc/nginx/conf.d/service-url.inc
echo "> Nginx Reload"
chmod 644 /var/log/nginx/error.log
nginx -s reload

TARGET_CONTAINER_ID=$(docker ps --filter name=server-image- --format "{{.ID}} {{.Names}}" | grep -v image-${TARGET_TAG} | awk '{print $1}')
docker stop "${TARGET_CONTAINER_ID}"