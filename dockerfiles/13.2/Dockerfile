# vim:set ft=dockerfile:
# Azurewind's PostgreSQL image with Chinese full text searchi using pg_jieba
# docker build -t chenxinaz/pg_jieba --build-arg CN_MIRROR=1 .

FROM postgres:13.2 as builder
ARG CN_MIRROR=1

RUN if [ $CN_MIRROR = 1 ] ;
RUN if [ $CN_MIRROR = 1 ] ; then \
DEBIAN_VERSION=$(dpkg --status tzdata|grep Provides|cut -f2 -d'-') \
DEBIAN_MIRROR=http://ftp.cn.debian.org/debian \
&& echo "using mirrors for $DEBIAN_VERSION" \
&& echo "deb $DEBIAN_MIRROR/ $DEBIAN_VERSION main non-free contrib \n\
deb $DEBIAN_MIRROR/ $DEBIAN_VERSION-updates main non-free contrib \n\
deb $DEBIAN_MIRROR/ $DEBIAN_VERSION-backports main non-free contrib \n\
deb $DEBIAN_MIRROR-security/ $DEBIAN_VERSION/updates main non-free contrib \n\
deb-src $DEBIAN_MIRROR/ $DEBIAN_VERSION main non-free contrib \n\
deb-src $DEBIAN_MIRROR/ $DEBIAN_VERSION-updates main non-free contrib \n\
deb-src $DEBIAN_MIRROR/ $DEBIAN_VERSION-backports main non-free contrib \n\
deb-src $DEBIAN_MIRROR-security/ $DEBIAN_VERSION/updates main non-free contrib" > /etc/apt/sources.list; else echo "No mirror"; fi

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
      gcc \
      make \
      libc-dev \
      g++ \
      git \
      cmake \
      curl \
      ca-certificates \
      openssl

RUN apt-get install -y --no-install-recommends \
      postgresql-server-dev-$PG_MAJOR

RUN curl -L https://raw.githubusercontent.com/Kitware/CMake/master/Modules/FindPostgreSQL.cmake > $(find /usr -name "FindPostgreSQL.cmake")

RUN git clone --depth 1 https://github.com/jaiminpan/pg_jieba \
  && cd /pg_jieba \
  && git submodule update --init --recursive 

RUN cd /pg_jieba \
  && mkdir -p build \
  && cd build \
  && cmake .. \
  && make \
  && make install \
  && cat install_manifest.txt | xargs tar zcf pgjieba.tar.gz

##############################################################################
##############################################################################

FROM postgres:13.2
ARG CN_MIRROR=1

COPY --from=builder /pg_jieba/build/pgjieba.tar.gz /
RUN tar zxf /pgjieba.tar.gz \
  && rm /pgjieba.tar.gz \
  && echo "  \n\
  echo \"shared_preload_libraries = 'pg_jieba.so'\" >> /var/lib/postgresql/data/postgresql.conf" \
  > /docker-entrypoint-initdb.d/init-dict.sh \
  && echo "CREATE EXTENSION pg_jieba;" > /docker-entrypoint-initdb.d/init-jieba.sql 

RUN if [ $CN_MIRROR = 1 ] ; then echo " \n\
  echo \"timezone = 'Asia/Shanghai'\" >> /var/lib/postgresql/data/postgresql.conf" \
  >> /docker-entrypoint-initdb.d/init-dict.sh; fi

