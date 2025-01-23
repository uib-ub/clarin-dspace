#
# The contents of this file are subject to the license and copyright
# detailed in the LICENSE and NOTICE files at the root of the source
# tree and available online at
#
# http://www.dspace.org/license/
#

# To build for example use:
# docker build --build-arg POSTGRES_VERSION=13 --build-arg POSTGRES_PASSWORD=mypass ./dspace/src/main/docker/dspace-postgres-pgcrypto-curl/
# This will be published as dspace/dspace-postgres-pgcrypto:$DSPACE_VERSION-loadsql

ARG POSTGRES_VERSION=13
ARG POSTGRES_PASSWORD=dspace
ARG_POSTGRES_DATA_DIR=/pgdata
FROM postgres:${POSTGRES_VERSION}

ENV POSTGRES_DB dspace
ENV POSTGRES_USER dspace
ENV POSTGRES_PASSWORD ${POSTGRES_PASSWORD}

# Install curl which is necessary to load SQL file
# Copy directory needed by postgres to initialize first time
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*  &&\
mkdir $POSTGRES_DATA_DIR && \
chown 999 $POSTGRES_DATA
# Load a SQL dump.  Set LOADSQL to a URL for the sql dump file.
COPY install-pgcrypto.sh /docker-entrypoint-initdb.d/
USER 999
