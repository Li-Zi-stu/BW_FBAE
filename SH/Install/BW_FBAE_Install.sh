#!/bin/sh
DIR_BW_FBAE="/etc/BW_FBAE"
DIR_BW_FBAE_TMP="${DIR_BW_FBAE}/Temp"
DIR_BW_FBAE_SERVER="${DIR_BW_FBAE}/Server"
DIR_BW_FBAE_CONFIG="${DIR_BW_FBAE}/Config"
DIR_BW_FBAE_CORE_SERVER="${DIR_BW_FBAE_SERVER}/Core_Server"
DIR_BW_FBAE_CORE_SERVER_CONFIG="${DIR_BW_FBAE_CONFIG}/Core_Server"
DIR_BW_FBAE_WEB_SERVER="${DIR_BW_FBAE_SERVER}/Web_Server"
DIR_BW_FBAE_WEB_SERVER_CONFIG="${DIR_BW_FBAE_WEB_SERVER}/conf"
rm -rf ${DIR_BW_FBAE_CORE_SERVER}/*
mv -f ${DIR_BW_FBAE_WEB_SERVER_CONFIG}/nginx.conf ${DIR_BW_FBAE_WEB_SERVER_CONFIG}/nginx.conf.bak
mkdir -p ${DIR_BW_FBAE_TMP}/Config/Web_Server
mkdir ${DIR_BW_FBAE_TMP}/Config/Core_Server
mkdir ${DIR_BW_FBAE_TMP}/Config/Web
cat << EOF > ${DIR_BW_FBAE_TMP}/Config/Web_Server/BW_FBAE_Web_Server_Config.conf
${BWFBAEWEBSERVERCONFIG}
EOF
mv -f ${DIR_BW_FBAE_TMP}/Config/Web_Server/BW_FBAE_Web_Server_Config.conf ${DIR_BW_FBAE_WEB_SERVER}/BW_FBAE_Web_Server_Config.conf
cat << EOF > ${DIR_BW_FBAE_TMP}/Config/Web/BW_FBAE_Web_Config.conf.template
${BWFBAEWEBCONFIG}
EOF
envsubst '${PORT}' < ${DIR_BW_FBAE_TMP}/Config/Web/BW_FBAE_Web_Config.conf.template > ${DIR_BW_FBAE_TMP}/Config/Web/BW_FBAE_Web_Config.conf
mv -f ${DIR_BW_FBAE_TMP}/Config/Web/BW_FBAE_Web_Config.conf ${DIR_BW_FBAE_WEB_SERVER_CONFIG}/BW_FBAE_Web_Config.conf
cat << EOF > ${DIR_BW_FBAE_TMP}/Config/Core_Server/BW_FBAE_Core_Server_Config.json
${BWFBAECORESERVERCONFIG}
EOF
mv -f ${DIR_BW_FBAE_TMP}/Config/Core_Server/BW_FBAE_Core_Server_Config.json ${DIR_BW_FBAE_CORE_SERVER_CONFIG}/BW_FBAE_Core_Server_Config.json
rm -rf ${DIR_BW_FBAE_TMP}/*
mkdir -p ${DIR_BW_FBAE_TMP}/Server/Core_Server
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL ${BWFBAECORESERVERLINK} -o ${DIR_BW_FBAE_TMP}/Server/Core_Server/BW_FBAE_Core_Server.zip
unzip ${DIR_BW_FBAE_TMP}/Server/Core_Server/BW_FBAE_Core_Server.zip -d ${DIR_BW_FBAE_TMP}/Server/Core_Server
install -m 755 ${DIR_BW_FBAE_TMP}/Server/Core_Server/xray ${DIR_BW_FBAE_CORE_SERVER}
rm -rf ${DIR_BW_FBAE_TMP}/*
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL ${BWFBAEIPCONFIGLINK} -o ${DIR_BW_FBAE_CORE_SERVER}/geoip.dat
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL ${BWFBAESITECONFIGLINK} -o ${DIR_BW_FBAE_CORE_SERVER}/geosite.dat
${DIR_BW_FBAE_CORE_SERVER}/xray -config=${DIR_BW_FBAE_CORE_SERVER_CONFIG}/BW_FBAE_Core_Server_Config.json &
${DIR_BW_FBAE_WEB_SERVER}/sbin/nginx -c BW_FBAE_Web_Server_Config.conf -g 'daemon off;'