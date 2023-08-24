#!/bin/bash

# NOTE : The SQL import should exclude 'wp_users' & 'wp_usermeta' tables to preserve initial 'admin' password.
export $(xargs <../.env)

NS=wordpress
TAR_FILE=wp-content.tar
TAR_NAME="${PWD}/${TAR_FILE}"
DUMPED_NAME=wordpress_backup.sql
DUMPED_FILE="${PWD}/${DUMPED_NAME}"

WP_POD=$(kubectl get pods -n ${NS} --no-headers -o custom-columns=":metadata.name" | grep wordpress | grep -v mysql)
DB_POD=wordpress-production-mysql-0

echo "Copying file [${TAR_NAME} ] into pod [${WP_POD}]..."
kubectl cp ${TAR_NAME} ${NS}/${WP_POD}:/bitnami/wordpress

echo "Copying file [${DUMPED_FILE}] into pod [${DB_POD}]..."
kubectl cp ${DUMPED_FILE} ${NS}/${DB_POD}:/tmp

echo "Extracting file [${TAR_FILE}] in pod [${WP_POD}]..."
kubectl exec -it -n ${NS} ${WP_POD} -- /bin/bash -c "cd /bitnami/wordpress; touch migrate.txt; tar -xvf ${TAR_FILE}"

echo "Importing SQL [${DUMPED_NAME}] in pod [${DB_POD}]..."
kubectl exec -it -n ${NS} ${DB_POD} -- /bin/bash -c "cd /tmp; mysql -u root --password=${MARIADB_ROOT_PASSWORD} wordpress < ${DUMPED_NAME}"