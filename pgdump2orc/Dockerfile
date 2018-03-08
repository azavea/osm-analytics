FROM ubuntu:18.04

# planet dump ng version
ARG pdng=1.1.5
# osm2orc version
ARG osm2orc=0.4.0


# update and add package to avoid apt warning
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# utility libs
RUN apt-get install -y curl unzip

# ======================== #
# ==== planet dump ng ==== #
# ======================== #

# build requirements
RUN apt-get install -y build-essential automake autoconf \
  libxml2-dev libboost-dev libboost-program-options-dev \
  libboost-date-time-dev libboost-filesystem-dev \
  libboost-thread-dev libboost-iostreams-dev \
  libosmpbf-dev osmpbf-bin libprotobuf-dev pkg-config \
  postgresql-client

# get/compile planet dump ng
WORKDIR /root/
RUN curl -L https://github.com/zerebubuth/planet-dump-ng/archive/v${pdng}.tar.gz --output pdng-v${pdng}.tar.gz
RUN tar xvf pdng-v${pdng}.tar.gz
RUN rm -rf pdng-v${pdng}.tar.gz

WORKDIR /root/planet-dump-ng-${pdng}/
RUN ./autogen.sh
RUN ./configure
RUN make
RUN chmod +x planet-dump-ng
RUN ln planet-dump-ng /usr/bin/planet-dump-ng

# ================= #
# ==== osm2orc ==== #
# ================= #

# gradle first
RUN apt-get install -y openjdk-8-jdk
WORKDIR /root/
RUN curl -L https://services.gradle.org/distributions/gradle-4.5.1-bin.zip --output gradle-4.5.1-bin.zip
RUN mkdir /root/gradle
RUN unzip -d /root/gradle gradle-4.5.1-bin.zip
RUN rm -rf gradle-4.5.1-bin.zip
ENV PATH="/root/gradle/gradle-4.5.1/bin:${PATH}"

# get/compile osm2orc
WORKDIR /root/
RUN curl -L https://github.com/mojodna/osm2orc/archive/v${osm2orc}.tar.gz --output osm2orc-${osm2orc}.tar.gz
RUN tar xf osm2orc-${osm2orc}.tar.gz
RUN rm -rf osm2orc-${osm2orc}.tar.gz

WORKDIR /root/osm2orc-${osm2orc}/
RUN ./gradlew distTar

WORKDIR /root/osm2orc-${osm2orc}/build/distributions
RUN tar xf osm2orc-${osm2orc}.tar
RUN rm -rf osm2orc-${osm2orc}.tar
ENV PATH="/root/osm2orc-${osm2orc}/build/distributions/osm2orc-${osm2orc}/bin:${PATH}"

# =============== #
# === cleanup === #
# =============== #
WORKDIR /root/
ADD pgdump2orc /bin/pgdump2orc
RUN chmod +x /bin/pgdump2orc

ENTRYPOINT ["pgdump2orc"]
CMD ["-i", "/mnt/input", "-s", "/mnt/scratch", "-o", "/mnt/scratch/planet-osm.orc"]

