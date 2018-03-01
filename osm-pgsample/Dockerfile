FROM ubuntu:18.04

# update and add package to avoid apt warning
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# utility libs
RUN apt-get install -y curl unzip openjdk-8-jdk postgresql-client osmium-tool git

# ======================== #
# ======= osm rails ====== #
# ======================== #

WORKDIR /root/
# tzdata prompts without this
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y ruby2.3 libruby2.3 ruby2.3-dev \
                   libmagickwand-dev libxml2-dev libxslt1-dev nodejs \
                   apache2 apache2-dev build-essential git-core \
                   postgresql postgresql-contrib libpq-dev postgresql-server-dev-all \
                   libsasl2-dev imagemagick libffi-dev
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN gem2.3 install bundler
RUN git clone --depth=1 https://github.com/openstreetmap/openstreetmap-website.git


# ======================= #
# ======= osmosis ======= #
# ======================= #

WORKDIR /root/
RUN curl -L https://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz --output osmosis-latest.tgz
RUN mkdir osmosis
RUN mv osmosis-latest.tgz osmosis
WORKDIR /root/osmosis/
RUN tar xfz osmosis-latest.tgz
RUN rm osmosis-latest.tgz
RUN chmod a+x bin/osmosis
ENV PATH="/root/osmosis/bin:${PATH}"

# Retrieving data to populate DB with
RUN curl -L http://download.geofabrik.de/europe/isle-of-man-170101.osm.pbf --output /opt/isle-of-man-170101.osm.pbf
RUN curl -L http://download.geofabrik.de/europe/isle-of-man-170101.osm.pbf --output /opt/isle-of-man-180101.osm.pbf

COPY osm.properties /etc/osmosis/osm.properties

COPY sample-ingest.sh /root/sample-ingest.sh

RUN chmod +x /root/sample-ingest.sh

WORKDIR /root
ENTRYPOINT ./sample-ingest.sh

