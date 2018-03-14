FROM quay.io/geotrellis/osm2orc:latest
RUN apt-get update
RUN apt-get install -y --reinstall groff-base
RUN apt-get install -y python python-dev python-pip less lbzip2
RUN apt-get clean
RUN pip install awscli boto
COPY run.py /root/run.py
ENTRYPOINT ["/root/run.py"]
