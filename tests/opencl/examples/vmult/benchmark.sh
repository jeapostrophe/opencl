#!/bin/sh

cd $(dirname $0)

DATA=test.dat
if ! [ -f ${DATA} ] ; then
    echo Making data
    racket -t make-data.rkt > ${DATA}
fi

for VER in racket-list.rkt racket-vector.rkt racket-unsafe-vector.rkt c-kernel.rkt c-loop.rkt opencl.rkt ; do
    VER_DATA=${VER}.dat
    echo $VER
    if [ -f ${VER_DATA} ] ; then
        cat ${VER_DATA}
    else
        if ! (racket -t ${VER} < ${DATA} | tee ${VER_DATA}) ; then
            rm ${VER_DATA}
        fi
    fi
done
