db='http://127.0.0.1:5984'
cdo() {
    op=$1; shift
    path=$1; shift
    curl -s $op $db/$path $*
}
cget() { cdo -XGET $*; }
cvget() { cdo -vXGET $*; }
cput() { cdo -XPUT $*; }
cvput() { cdo -vXPUT $*; }
cpost() { cdo -XPOST $*; }
cvpost() { cdo -vXPOST $*; }
cdel() { cdo -XDELETE $*; }
cvdel() { cdo -vXDELETE $*; }
alldbs() { cget _all_dbs; }
alldocs() { cget $1/_all_docs; }
rep() {
    cpost _replicate -H 'Content-Type:application/json' -d '{"source":"'$1'","target":"'$2'"}'
}
revs() {
    cget $1?revs_info=true
}
rrevs() {
    echo cget $1?rev=$2\&revs_info=true
    cget $1?rev=$2\&revs_info=true
}
openrevs() {
    cget $1?open_revs=all
}

conflicts() {
    cget $1?conflicts=true
}

compact() {
    cpost $1/_compact -H "Content-Type:application/json"
}

json() {
    data='{'
    for value in $*; do
        key=`echo $value | sed -e 's/=.*//'`
        val=`echo $value | sed -e 's/.*=//'`
        if echo $val | grep '^~' >/dev/null; then
            val=`echo $val | sed -e 's/^~//'`
            data="$data\"$key\":$val,"
        else
            data="$data\"$key\":\"$val\","
        fi
    done
    echo $data|sed -e 's/,$/}/'
}

putbulk() {
    path=$1/_bulk_docs; shift
    docs="docs=~[`json $*`]"

    data=`json all_or_nothing=~true $docs`
    head="Content-Type:application/json"
    cpost $path -d$data -H$head
}

putdoc() {
    path=$1; shift
    prev=`cget $path`
    if echo $* | grep _rev= >/dev/null; then
      data="-d`json $*`"
    elif echo $prev | grep '"error":"not_found"' >/dev/null; then
      data="-d`json $*`"
    else
      rev=`echo $prev | sed -e 's/.*"_rev":"\([^"]*\)".*/\1/'`
      data="-d`json $* _rev=$rev`"
    fi
    cput $path $data
}

d0='-d{"a":0}' 
d1='-d{"a":1}' 
d2='-d{"a":2}' 
d3='-d{"a":3}' 
d4='-d{"a":4}' 
d5='-d{"a":5}' 
d6='-d{"a":6}' 
d7='-d{"a":7}' 
d8='-d{"a":8}' 
d9='-d{"a":9}' 
