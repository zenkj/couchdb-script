#!/bin/sh

db='http://127.0.0.1:5984'

rev=`curl -sX GET $db/hellodb/123 | sed -e 's/.*rev":"\([^"]*\)".*/\1/'`

i=0
while [ $i -le 1000 ]; do
    rev=`curl -sX PUT $db/hellodb/123?rev=$rev -d "{\"i\":$i,\"msg\":\"hello good morning\"}" | sed -e 's/.*rev":"\([^"]*\)".*/\1/'`
    i=`expr $i + 1`
done

echo $rev
