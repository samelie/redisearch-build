# https://hub.docker.com/r/eventbrain/redisearch/dockerfile

FROM debian:buster AS builder
WORKDIR /build

ARG BUILD_PACKAGES="build-essential git"

# install packages
RUN apt-get update -qq \
 && apt-get upgrade -qq \
 && apt-get install -y $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone --recursive https://github.com/RediSearch/RediSearch.git .
RUN ./deps/readies/bin/getpy2
RUN ./system-setup.py
RUN make fetch SHOW=1
RUN make build SHOW=1

#---------------------------------------------------------------------------------------

FROM redis:latest

WORKDIR /data

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p "$LIBDIR";

COPY --from=builder /build/build/redisearch.so  "$LIBDIR"

CMD ["redis-server", "--loadmodule", "/usr/lib/redis/modules/redisearch.so"]