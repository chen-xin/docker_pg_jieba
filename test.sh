#!/bin/bash

DEBIAN_MIRROR=http://ftp.cn.debian.org/debian \
    && echo "deb $DEBIAN_MIRROR/" \
    && echo "deb $DEBIAN_MIRROR-security/"

cat tags.txt | while read line 
do
    echo line: $line
done
