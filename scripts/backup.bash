#!/bin/bash

export $(xargs <../.env)

NS=wordpress
TAR_NAME=wp-content.tar
DB_PASSWD=${MARIADB_ROOT_PASSWORD}
WP_POD=$(kubectl get pods -n ${NS} --no-headers -o custom-columns=":metadata.name" | grep wordpress | grep -v mysql)
DB_POD=wordpress-production-mysql-0
BK_CMD="mysqldump -u root --password=${DB_PASSWD} wordpress > /tmp/wordpress_backup.sql"

### mysql ###
kubectl exec -it -n ${NS} ${DB_POD} -- /bin/bash -c "${BK_CMD}"
kubectl cp ${NS}/${DB_POD}:/tmp/wordpress_backup.sql ./wordpress_backup.sql

### wp-content ###
kubectl exec -it -n ${NS} ${WP_POD} -- /bin/bash -c "cp -r /bitnami/wordpress/wp-content /tmp; cd /tmp; tar -cvf ${TAR_NAME} wp-content"
kubectl cp ${NS}/${WP_POD}:/tmp/${TAR_NAME} ./${TAR_NAME}
