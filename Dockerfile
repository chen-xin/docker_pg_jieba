# vim:set ft=dockerfile:
FROM postgres:alpine

# Uncomment the following command if you are in China, or preffer other mirror
# RUN echo -e 'https://mirror.tuna.tsinghua.edu.cn/alpine/v3.5/main/' > /etc/apk/repositories

# Uncomment the following 2 commands if you have bad internet connection
# and first download the files into data directory
# COPY data/postgresql-9.6.3.tar.bz2 ./postgresql.tar.bz2
# COPY data/pg_jieba-master.zip /pg_jieba-master.zip



RUN set -ex \
	\
	&& apk add --no-cache --virtual .fetch-deps \
		ca-certificates \
                cmake \
                git \
		openssl \
		tar \
	# && wget -O pg_jieba-master.zip "https://github.com/jaiminpan/pg_jieba/archive/master.zip" \
        && git clone https://github.com/jaiminpan/pg_jieba \
	&& wget -O postgresql.tar.bz2 "https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.bz2" \
	&& echo "$PG_SHA256 *postgresql.tar.bz2" | sha256sum -c - \
	&& mkdir -p /usr/src/postgresql \
	&& tar \
		--extract \
		--file postgresql.tar.bz2 \
		--directory /usr/src/postgresql \
		--strip-components 1 \
	&& rm postgresql.tar.bz2 \
	\
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		g++ \
		libc-dev \
		make \
	\
	&& apk add --no-cache --virtual .rundeps \
		libstdc++ \
  && cd / \
  # && unzip pg_jieba-master.zip \
  # && cd /pg_jieba-master \
  # && USE_PGXS=1 make \
  # && USE_PGXS=1 make install \
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
		/pg_jieba-master \
		/pg_jieba-master.zip \
	&& find /usr/local -name '*.a' -delete
