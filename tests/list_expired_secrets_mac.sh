#!/bin/bash
# set the timezone - this is important
export TZ=GMT
# -------------------
# Tools
VAULT="/usr/local/bin/vault"
CUT="/usr/bin/cut"
# JQ="/usr/local/bin/jq"
JQ="/usr/bin/jq"
SED="/usr/bin/sed"
DATE="/bin/date"

# -------------------
# Paths

HOME=/Users/parmindersingh
DIR=$HOME/vault/tests

# -------------------
# Files

log=$DIR/log.txt
file=$DIR/input.txt
file=$DIR/input_comcast.txt
errfile=$DIR/error.txt

# -------------------
# Variables

export VAULT_ADDR="http://localhost:8200/"
export VAULT_TOKEN="s.1kUxd6axjzqzlKyImCtWxOhs"

nvf='No value'
date_now=$(date +%Y-%m-%dT%H:%M:%S)
now=$(date +%s)

exp_days=90
exp_days=0
exp_sec=$(($exp_days * 24 * 3600 ))
# echo "days=$exp_days; sec=$exp_sec"


# -------------------
# Functions

function update_timestamp 
{

   meta=$(vault kv metadata  get -format=json $1 2>&1)
   rtn=$?
   # echo rtn=$rtn
   # return

   case $rtn in 
   0)
     udt=$(vault kv metadata  get -format=json $1 | jq .data.updated_time 2>$errfile  )
     udt_ymdhms=$( echo ${udt} | /usr/bin/cut -d. -f1 | sed -e 's/\"//' )
     # echo "$cmd:udt=${udt}"
     # echo "$cmd:udt_ymdhms=${udt_ymdhms}"
     # echo "$cmd:date_now=${date_now}"

     # works on linux
     # udt_j=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$udt_ymdhms" "+%s" )
     # works on mac
     udt_j=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$udt_ymdhms" "+%s" )

     # echo "$cmd:now=${now}; last-update-timestamp=${udt_j}"
     diff=$(( $now - $udt_j ))
     # echo "diff=${diff}; exp_sec=${exp_sec}"
     if [ $diff -gt $exp_sec ]; then
        echo "****** ALERT: EXPIRED password (last update: $udt_ymdhms, expiration days: $exp_days) for $cmd " 
     else
        echo "******  INFO: UNEXPIRED password for $cmd " 
     fi
     ;;
   1)
     echo "****** ERROR: NO METADATA for KV1 password at $cmd "
     return
     ;;
   2)
     echo "****** ERROR: INVALID path $cmd " 
     return
     ;;
   *)
     echo "****** ERROR: UNKNOWN ERR for path $cmd "
     return
     ;;
   esac
}

while IFS= read -r cmd; do
    # printf '%s\n' "$cmd"
    update_timestamp "$cmd"
done < "$file"
