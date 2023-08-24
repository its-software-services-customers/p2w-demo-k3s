#!/bin/bash

export KUBECONFIG=${HOME}/p2w-epeagle-k3s/kubeconfig.yaml

TS=$(date +%Y%m%d_%H%M%S)
SQL_FILE=wordpress_backup.sql
TAR_FILE=wp-content.tar
UPLOAD_SQL_FILE=${SQL_FILE}.${TS}
UPLOAD_TAR_FILE=${TAR_FILE}.${TS}
TMP_TEMPLATE=template.json

KEY_FILE=${HOME}/secrets/sa.json
BUCKET=gs://p2w-backup/ep-eagle-pharma

echo "##### Starting to backup Wordpress data ####"
./backup.bash

echo "##### Activating Gcloud service account ####"
gcloud auth activate-service-account --key-file=${KEY_FILE}

echo "##### Copying backup files to cloud storage ####"
mv ${SQL_FILE} ${UPLOAD_SQL_FILE}
mv ${TAR_FILE} ${UPLOAD_TAR_FILE}
gsutil cp ${UPLOAD_SQL_FILE} ${UPLOAD_TAR_FILE} ${BUCKET}

export $(xargs <../.env)

cat << EOF > ${TMP_TEMPLATE}
{
    "text": "Done uploading files [${UPLOAD_SQL_FILE}] [${UPLOAD_TAR_FILE}]"
}
EOF

curl -X POST -H 'Content-type: application/json' --data "@${TMP_TEMPLATE}" ${SLACK_URI}

echo "##### Remove local uploaded files ####"
rm ${UPLOAD_SQL_FILE} ${UPLOAD_TAR_FILE} ${TMP_TEMPLATE}

echo "##### Done ####"
