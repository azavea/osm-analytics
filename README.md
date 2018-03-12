# Processing OSM Statistics


### Producing Planet OSM ORCfiles from OSM PGDumps
OSM database dumps are rather large. As a result, we'll need to mount
our pgdump and some scratch space with sufficient room for processing while
supplementary tables are produced. For the authors of this dockerfile,
AWS Elastic Block Storage (EBS) is being used to provide indefinitely
large blocks of storage space which are then volume mounted. Here's an
example of what our use might look like:


### Running locally
```
docker-compose build

# spin up a postgres instance and fill it with isle of man sample data
docker-compose run osm-pgsample

# Build the docker images
docker-compose build

# construct sample isle-of-man pgdump
docker-compose run osm-pgsample

# use planet-dump-ng to construct pbfs/xml from the pgdump:
docker-compose run -v $(pwd)/data:/tmp/data planet-dump-ng \
  -f /tmp/data/iom.pgdump.dir \
  --history-pbf /tmp/data/iom.osh.pbf \
  --pbf /tmp/data/iom.osm.pbf \
  --changesets /tmp/data/iom.osc.xml.bz2

# producing ORC osm history
docker-compose run -v $(pwd)/data:/tmp/data osm2orc \
  /tmp/data/iom.osh.pbf /tmp/data/iom.osh.orc

# producing ORC changesets
bzip2 -dc data/iom.osc.xml.bz2 > data/iom.osc.xml

docker-compose run -v $(pwd)/data:/tmp/data osm2orc \
  --changesets /tmp/data/iom.osc.xml /tmp/data/iom.osc.orc
```

