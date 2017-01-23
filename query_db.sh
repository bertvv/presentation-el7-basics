#! /usr/bin/env bash
#
# Run SQL query on db server to verify its availability

set -x
mysql --host=192.168.56.73 \
  --user=demo \
  --password=demo \
  demo \
  --execute="SELECT * FROM demo;"
set +x
