# Processing OSM Statistics


### Producing Planet OSM ORCfiles from OSM PGDumps
OSM database dumps are rather large. As a result, we'll need to mount
our pgdump and some scratch space with sufficient room for processing while
supplementary tables are produced. For the authors of this dockerfile,
AWS Elastic File Storage (EFS) is being used to provide indefinitely
large blocks of storage space which are then volume mounted. Here's an
example of what our use might look like:

```
# Mounting 'infinite' disk space
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 <file-system-id>.efs.<aws-region>.amazonaws.com:/ efs
# Copy OSM data to our massive disk
s3 cp s3://osm/osm.pgdump efs/osm.pgdump
# Make a directory to work out of
mkdir efs/scratch
# Run through a conversion from pgdump to orc
docker run -v efs:/mnt/efs quay.io/geotrellis/osm-pgdump2orc -i /mnt/osm.pgdump -s /mnt/scratch -o /mnt/planet-osm.orc
```


### Running a local test
```
docker-compose build

# This command will spin up a postgres instance and fill it with isle of man data
#  You should only need to run it if you want to generate a new pgdump file to test
docker-compose run osm-pgsample

# The following command can then be used to produce our orc files. Note
#  the volume mount. It is important that any output files be created on
#  a mounted portion of the container's FS so that generated data is
#  available outside the docker run.
# Keep in mind that each of the following arguments should be mapped
#  into the container's volume-mounted address-space!
#  -i - the input location (the file or dir of the pgdump)
#  -s - scratch space in which docker can build temporary databases as necessary
#  -o - the output location of our generated ORC file
docker-compose run -v $(pwd)/data:/mnt/efs osm-pgdump2orc \
  -i /mnt/efs/iom.pgdump -s /mnt/efs -o /mnt/efs/isle-of-man_sample.osh.orc
```
