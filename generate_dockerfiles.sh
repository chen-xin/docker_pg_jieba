#!/bin/bash
alpine="alpine"

for dir in dockerfiles/*
do
    old_tags="${dir##*/}, ${old_tags}"
done

create_dirs()
{
    if [[ ! $tag =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
        echo "Tag is not in the form [9.6.25]"
        exit 1
    fi
    old_tags=$(echo $old_tags | sed "s/$tag, *//")

    sub_directory=dockerfiles/$tag
    mkdir -p $sub_directory/alpine

    sed "s/FROM postgres/FROM postgres:${tag}/g" Dockerfile > $sub_directory/Dockerfile
    echo $line > $sub_directory/tags.txt

    sed "s/FROM postgres:alpine/FROM postgres:$tag-alpine/g" Dockerfile.alpine > $sub_directory/alpine/Dockerfile
    if [ ! -z "${line##*latest*}" ]; then
        echo $line | sed 's/\([0-9.]\+\)/\1-alpine/g' > $sub_directory/alpine/tags.txt
    else
        # cp Dockerfile.alpine $sub_directory/alpine/Dockerfile
        echo $line | sed 's/\([0-9.]\+\)/\1-alpine/g;s/latest/alpine/' > $sub_directory/alpine/tags.txt
    fi
}

# curl https://github.com/docker-library/official-images/blob/master/library/postgres  > tags.html
# cat tags.html | \
curl https://github.com/docker-library/official-images/blob/master/library/postgres | \
grep -o 'Tags: [0-9. ,a-z-]\+' | sed 's/Tags: //' | \
while read line 
do
    for tag in $line
    do
        tag=$(echo $tag | grep -o '[^,]\+')
        if [ ! -z "${tag##*$alpine*}" ]; then
            # if [ ! -d "$tag" ]; then
            # fi
            create_dirs
        fi
        break
    done
    echo $old_tags > old_tags.txt
done

for old_tag in $(cat old_tags.txt)
do
    old_tag=$(echo $old_tag | grep -o '[^,]\+')
    echo "removing old tag [$old_tag]"
    rm -rf dockerfiles/$old_tag
done

rm old_tags.txt


