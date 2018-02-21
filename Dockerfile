# Azurewind's PostgreSQL image with Chinese full text search

FROM postgres

# set source to china mirrors
# --deplicted--..do not add "\" at end of line, in case that will merge
# all lines to one and cause error running "apt-get update"
# RUN echo "deb http://ftp2.cn.debian.org/debian/ jessie main non-free contrib \n\
# deb http://ftp2.cn.debian.org/debian/ jessie-updates main non-free contrib \n\
# deb http://ftp2.cn.debian.org/debian/ jessie-backports main non-free contrib \n\
# deb http://ftp2.cn.debian.org/debian-security/ jessie/updates main non-free contrib \n\
# deb-src http://ftp2.cn.debian.org/debian/ jessie main non-free contrib \n\
# deb-src http://ftp2.cn.debian.org/debian/ jessie-updates main non-free contrib \n\
# deb-src http://ftp2.cn.debian.org/debian/ jessie-backports main non-free contrib \n\
# deb-src http://ftp2.cn.debian.org/debian-security/ jessie/updates main non-free contrib" > /etc/apt/sources.list

# Uncomment the following command if you have bad internet connection
# and first download the files into data directory
# COPY data/pg_jieba.zip /pg_jieba.zip

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
      postgresql-server-dev-$PG_VERSION \
      gcc \
      make \
      libc-dev \
      g++ \
      #libstdc++ \
      #postgresql-server-dev-9.6 \
      wget \
      unzip \
      ca-certificates \
      openssl \
	&& rm -rf /var/lib/apt/lists/*

RUN wget -O pg_jieba.zip "https://github.com/jaiminpan/pg_jieba/archive/master.zip" \
  && cd / \
  && unzip pg_jieba.zip \
  && cd /pg_jieba-master \
  && USE_PGXS=1 make \
  && USE_PGXS=1 make install \
  && echo "  \n\
  # echo \"timezone = 'Asia/Shanghai'\" >> /var/lib/postgresql/data/postgresql.conf \n\
  echo \"shared_preload_libraries = 'pg_jieba.so'\" >> /var/lib/postgresql/data/postgresql.conf" \
  > /docker-entrypoint-initdb.d/init-dict.sh \
# The following command is not required if load database from backup
  && echo "CREATE EXTENSION pg_jieba;" > /docker-entrypoint-initdb.d/init-jieba.sql \
# RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#   && echo "Asia/Shanghai" >  /etc/timezone
  && apt-get purge -y gcc make libc-dev postgresql-server-dev-$PG_VERSION g++ \
  && apt-get autoremove -y \
  && rm -rf \
    /pg_jieba-master

