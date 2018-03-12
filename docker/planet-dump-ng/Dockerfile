ARG pdng=1.1.5

FROM debian:buster-slim as osm-pdng-build
ARG pdng
RUN apt-get update
RUN apt-get install -y curl build-essential automake autoconf \
  libxml2-dev libboost-dev libboost-program-options-dev \
  libboost-date-time-dev libboost-filesystem-dev \
  libboost-thread-dev libboost-iostreams-dev \
  libosmpbf-dev osmpbf-bin libprotobuf-dev pkg-config
WORKDIR /root/
RUN curl -L https://github.com/zerebubuth/planet-dump-ng/archive/v${pdng}.tar.gz --output pdng-v${pdng}.tar.gz
RUN tar xvf pdng-v${pdng}.tar.gz
WORKDIR /root/planet-dump-ng-${pdng}/
RUN ./autogen.sh
RUN ./configure
RUN make
RUN chmod +x planet-dump-ng

FROM postgres:10
ARG pdng
COPY --from=osm-pdng-build /root/planet-dump-ng-${pdng}/planet-dump-ng /bin/planet-dump-ng
RUN apt-get update
RUN apt-get install -y \
  libxml2-dev libboost-dev libboost-program-options-dev \
  libboost-date-time-dev libboost-filesystem-dev \
  libboost-thread-dev libboost-iostreams-dev \
  libosmpbf-dev osmpbf-bin libprotobuf-dev pkg-config
RUN apt-get clean
RUN mkdir -p /tmp/pgtemp
WORKDIR /tmp/pgtemp
ENTRYPOINT ["/bin/planet-dump-ng"]
