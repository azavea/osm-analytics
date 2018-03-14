ARG osm2orc=0.4.0

FROM openjdk:8-slim as osm2orc-build
ARG osm2orc
RUN apt-get update
RUN apt-get install -y curl unzip
# gradle
WORKDIR /root/
RUN curl -L https://services.gradle.org/distributions/gradle-4.5.1-bin.zip --output gradle-4.5.1-bin.zip
RUN mkdir /root/gradle
RUN unzip -d /root/gradle gradle-4.5.1-bin.zip
ENV PATH="/root/gradle/gradle-4.5.1/bin:${PATH}"
# osm2orc
RUN curl -L https://github.com/mojodna/osm2orc/archive/v${osm2orc}.tar.gz --output osm2orc-${osm2orc}.tar.gz
RUN tar xf osm2orc-${osm2orc}.tar.gz
WORKDIR /root/osm2orc-${osm2orc}/
RUN ./gradlew distTar
WORKDIR /root/osm2orc-${osm2orc}/build/distributions
RUN tar xf osm2orc-${osm2orc}.tar

FROM openjdk:8-slim
ARG osm2orc
COPY --from=osm2orc-build /root/osm2orc-${osm2orc} /root/osm2orc-${osm2orc}
ENV PATH="/root/osm2orc-${osm2orc}/build/distributions/osm2orc-${osm2orc}/bin:${PATH}"
ENTRYPOINT ["osm2orc"]

