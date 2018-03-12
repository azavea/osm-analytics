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

mkdir -p /tmp/data/iom.pgdump.dir
pg_dump -Fd -j 2 openstreetmap -f /tmp/data/iom.pgdump.dir
pg_dump -Fc openstreetmap -f /tmp/data/iom.pgdump

