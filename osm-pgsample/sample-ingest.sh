#!/bin/bash

echo "Dropping osm database"
dropdb --if-exists openstreetmap

echo "Creating osm database"
createdb openstreetmap

echo "Creating extensions..."
psql -d openstreetmap -c 'CREATE EXTENSION postgis; CREATE EXTENSION hstore;'

echo "Applying schemas"
install_osm() {
  cd /root/openstreetmap-website
  bundle install
  cp config/example.application.yml config/application.yml
  cp config/example.database.yml config/database.yml
  bundle exec rake db:create
  psql -d openstreetmap -c "CREATE EXTENSION btree_gist"
  cd /root/openstreetmap-website/db/functions
  make libpgosm.so
  cd /root/openstreetmap-website
  psql -d openstreetmap -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT"
  psql -d openstreetmap -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '`pwd`/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT"
  psql -d openstreetmap -c "CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT"
  bundle exec rake db:migrate
}
install_osm


echo "Applying osm pbf"
osmosis --read-pbf-fast /opt/isle-of-man-170101.osm.pbf \
  --log-progress \
  --write-apidb authFile=/etc/osmosis/osm.properties validateSchemaVersion=no

echo "producing changeset"
osmium derive-changes /opt/isle-of-man-170101.osm.pbf /opt/isle-of-man-180101.osm.pbf -o /opt/iom-2017-changes.osc

echo "Applying changes"
osmosis --read-xml-change /opt/iom-2017-changes.osc \
  --write-apidb-change authFile=/etc/osmosis/osm.properties validateSchemaVersion=no

pg_dump -Fc openstreetmap > /tmp/data/iom.pgdump

