#!/bin/bash
#
# satis-upd.sh  This shell script used for updatingsatis priavte repository 
# 

# Set up a default search path.
PATH="/usr/local/bin/:/sbin:/usr/sbin:/bin:/usr/bin"
export PATH

SATIS_EXEC=/usr/local/bin/satis
SATIS_CONFIG=(
    "/usr/local/satis/build/inner.json"
    "/usr/local/satis/build/mirror.json"
)
LOG_FILE=/var/log/satis.log

headshow(){
    datetime=`date "+%Y-%m-%d %H:%M:%S"`
    echo "-----------------------------------"
    echo "Update satis configure file: $1"
    echo ${datetime}
    echo "-----------------------------------"
}

footshow(){
    datetime=`date "+%Y-%m-%d %H:%M:%S"`
    echo "-----------------------------------"
    echo "Update finish : ${datetime} "
    echo "-----------------------------------"
}

update() {
    stcf=$1 
    headshow $stcf
    if [ ! -f "$stcf" ]; then
        echo "Config file $stcf not exist!"
        return 1    
    fi
    $SATIS_EXEC build $1 -vvv
    footshow 
}

for cf in ${SATIS_CONFIG[@]}; 
do
    update $cf >> $LOG_FILE 2>&1
done
