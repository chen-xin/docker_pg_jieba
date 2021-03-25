to get all postgres docker image tags:
```
curl https://github.com/docker-library/official-images/blob/master/library/postgres | \
grep -o 'Tags: [0-9. ,a-z-]\+' tags.html | sed 's/Tags: //'
```
