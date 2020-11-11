# vim:set ft=dockerfile:
# docker build -t chenxinaz/pg_jieba:alpine --build-arg CN_MIRROR=1 .
FROM postgres:alpine
ARG CN_MIRROR=0

RUN if [ $CN_MIRROR = 1 ] ; then OS_VER=$(grep main /etc/apk/repositories | sed 's#/#\n#g' | grep "v[0-9]\.[0-9]") \
  && echo "using mirrors for $OS_VER" \
  && echo https://mirrors.ustc.edu.cn/alpine/$OS_VER/main/ > /etc/apk/repositories; fi

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		ca-certificates \
    cmake \
    git \
		openssl \
		tar \
  && git clone https://github.com/jaiminpan/pg_jieba \
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		g++ \
		libc-dev \
		make \
    postgresql-dev \
	&& apk add --no-cache --virtual .rundeps \
		libstdc++ \
  && cd / \
  && cd pg_jieba \
  && git submodule update --init --recursive \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make \
  && make install \
  && echo -e "  \n\
  # echo \"timezone = 'Asia/Shanghai'\" >> /var/lib/postgresql/data/postgresql.conf \n\
  echo \"shared_preload_libraries = 'pg_jieba.so'\" >> /var/lib/postgresql/data/postgresql.conf" \
  > /docker-entrypoint-initdb.d/init-dict.sh \
# The following command is not required if load database from backup
  && echo -e "CREATE EXTENSION pg_jieba;" > /docker-entrypoint-initdb.d/init-jieba.sql \
# RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#   && echo "Asia/Shanghai" >  /etc/timezone
    && apk del .build-deps .fetch-deps \
	&& rm -rf \
		/usr/src/postgresql \
		/pg_jieba \
	&& find /usr/local -name '*.a' -delete
