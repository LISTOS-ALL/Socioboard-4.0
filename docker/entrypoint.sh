#!/bin/sh
set -e

# # first arg is `-f` or `--some-option`
# if [ "${1#-}" != "$1" ]; then
#         set -- apache2-foreground "$@"
# fi
service mysql start

mongod &

cd /var/www/html/socioboard-api/feeds/ && pm2 start app.js 
cd /var/www/html/socioboard-api/notification/ && pm2 start app.js
cd /var/www/html/socioboard-api/publish/ && pm2 start app.js && \
cd /var/www/html/socioboard-api/user/ && pm2 start app.js

apache2-foreground

exec "$@"