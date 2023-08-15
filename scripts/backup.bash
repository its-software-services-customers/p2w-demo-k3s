#!/bin/bash

export $(xargs <../.env)

NS=wordpress
WP_POD=$(kubectl get pods -n ${NS} --no-headers -o custom-columns=":metadata.name" | grep wordpress)
DB_POD=wordpress-production-mysql-0
DB_PASSWD=${WORDPRESS_PASSWORD}

BK_CMD="mysqldump -u root --password=${DB_PASSWD} wordpress > /tmp/wordpress_backup.sql"

kubectl exec -it -n ${NS} ${DB_POD} -- /bin/bash -c "${BK_CMD}"
kubectl cp ${NS}/${DB_POD}:/tmp/wordpress_backup.sql wordpress_backup.sql
