A source repo of Postgres Chinese full-test search docker image, based on pg_jieba.

Supported tags and respective Dockerfile links
===============================================

- 9.6, 9.6.3, latest
- 9.6-alpine, 9.6.3-alpine, alpine

Quick reference
===============
Until version 9.6.3, Chinese full-text search is not shipped with PostgreSQL official release, and has to be implement by third-party extensions.

Pg-jieba, based on the c++ implementation of jieba, which announced to "built to be the best Python Chinese word segmentation module",

[The postgres official docker image](https://store.docker.com/images/postgres)

[pg_jieba on Github](https://github.com/jaiminpan/pg_jieba)

[My other Chinese full-text search docker image based on zhparser](https://store.docker.com/community/images/chenxinaz/docker_zhparser)

How to use this image
=====================

To run this image, please refer to the [postgres docker image doc](https://store.docker.com/images/postgres).
A basic command would be `docker run -p 5432:5432 chenxinaz/pg_jieba`.

When the container runs first time, the follow scripts would be executed on the default database. You need to run them to configure pg_jieba for any other newly created databases :
```
CREATE EXTENSION pg_jieba;
```

Testing
------------------------------
**ts_debug:**

`select ts_debug('jiebacfg', '白垩纪是地球上海陆分布和生物界急剧变化、火山活动频繁的时代');`

```
ts_debug
-------------------------------------------
"(n,noun,白垩纪,{jieba_stem},jieba_stem,{白垩纪})"
"(n,noun,是,{jieba_stem},jieba_stem,{})"
"(n,noun,地球,{jieba_stem},jieba_stem,{地球})"
"(n,noun,上,{jieba_stem},jieba_stem,{})"
"(n,noun,海陆,{jieba_stem},jieba_stem,{海陆})"
"(n,noun,分布,{jieba_stem},jieba_stem,{分布})"
"(n,noun,和,{jieba_stem},jieba_stem,{})"
"(n,noun,生物界,{jieba_stem},jieba_stem,{生物界})"
"(n,noun,急剧,{jieba_stem},jieba_stem,{急剧})"
"(n,noun,变化,{jieba_stem},jieba_stem,{变化})"
"(n,noun,、,{jieba_stem},jieba_stem,{})"
"(n,noun,火山,{jieba_stem},jieba_stem,{火山})"
"(n,noun,活动,{jieba_stem},jieba_stem,{活动})"
"(n,noun,频繁,{jieba_stem},jieba_stem,{频繁})"
"(n,noun,的,{jieba_stem},jieba_stem,{})"
"(n,noun,时代,{jieba_stem},jieba_stem,{时代})"
(16 rows)
```

