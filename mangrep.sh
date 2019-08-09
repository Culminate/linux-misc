#!/bin/bash
MANFOLDER=/usr/share/man/man*

MANS=$(find $MANFOLDER -exec zgrep -l -e $1 {} \;)
for MAN in $MANS; do
    man -P cat $MAN | grep -H --label $(basename $MAN .gz) $1 --color=always
done