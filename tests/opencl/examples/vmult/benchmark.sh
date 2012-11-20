#!/bin/sh

DATA=test.dat
if ! [ -f ${DATA} ] ; then
    mzscheme -t make-data.ss > ${DATA}
fi

for VER in scheme-list.ss scheme-vector.ss scheme-unsafe-vector.ss c-kernel.ss c-loop.ss opencl.ss ; do
    VER_DATA=${VER}.dat
    echo $VER
    if ! [ -f ${VER_DATA} ] ; then
	mzscheme -t ${VER} < ${DATA} | tee ${VER_DATA}
    else
	cat ${VER_DATA}
    fi
done