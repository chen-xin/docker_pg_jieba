# vim:set ft=dockerfile:
FROM postgres:alpine as builder
ARG CN_MIRROR=1

RUN if [ $CN_MIRROR = 1 ] ; then OS_VER=$(grep main /etc/apk/repositories | sed 's#/#\n#g' | grep "v[0-9]\.[0-9]") \
  && echo "using mirrors for $OS_VER" \
  && echo https://mirrors.ustc.edu.cn/alpine/$OS_VER/main/ > /etc/apk/repositories; fi

RUN apk update
RUN apk add ca-certificates cmake git openssl tar 
RUN apk add gcc g++ libc-dev make postgresql-dev libstdc++
RUN git clone https://github.com/jaiminpan/pg_jieba
RUN cd /pg_jieba \
  && git submodule update --init --recursive
RUN cd /pg_jieba \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make \
  && make install \
  && cat install_manifest.txt | xargs tar zcf pgjieba.tar.gz

FROM postgres:alpine
ARG CN_MIRROR=1

COPY --from=builder /pg_jieba/build/pgjieba.tar.gz /
RUN tar zxf /pgjieba.tar.gz \
  && rm /pgjieba.tar.gz \
  && echo -e "  \n\
  echo \"shared_preload_libraries = 'pg_jieba.so'\" >> /var/lib/postgresql/data/postgresql.conf" \
  > /docker-entrypoint-initdb.d/init-dict.sh \
  && echo -e "CREATE EXTENSION pg_jieba;" > /docker-entrypoint-initdb.d/init-jieba.sql 

RUN if [ $CN_MIRROR = 1 ] ; then echo -e " \n\
  echo \"timezone = 'Asia/Shanghai'\" >> /var/lib/postgresql/data/postgresql.conf" \
  >> /docker-entrypoint-initdb.d/init-dict.sh; fi

