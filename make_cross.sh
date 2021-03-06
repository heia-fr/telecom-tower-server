#!/usr/bin/env bash

APP=telecom-tower-server
REPO=github.com/heia-fr
BASE=/vagrant
APP_SUFFIX=.raspbian-release

mkdir -p ${BASE}/_build
cd ${BASE}/_build

mkdir -p go/src
mkdir -p go/pkg
mkdir -p go/bin

export GOPATH=$(pwd)/go

go get -d github.com/supcik-go/ws2811
cd ${GOPATH}/src/github.com/supcik-go/ws2811

git clone https://github.com/jgarff/rpi_ws281x.git

cd rpi_ws281x
patch -i ${BASE}/01_cross.patch

export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++
export LD=arm-linux-gnueabihf-g++
export AR=arm-linux-gnueabihf-ar
export STRIP=arm-linux-gnueabihf-strip

scons

cd ..
export CGO_ENABLED=1
export GOOS=linux
export GOARCH=arm
export CC_FOR_TARGET=arm-linux-gnueabihf-gcc
export CXX_FOR_TARGET=arm-linux-gnueabihf-g++

export CPATH=${GOPATH}/src/github.com/supcik-go/ws2811/rpi_ws281x
export LIBRARY_PATH=${GOPATH}/src/github.com/supcik-go/ws2811/rpi_ws281x

# The following line is needed for cross compiling
sudo -E go install std

patch -i ${BASE}/02_go.patch

cd $GOPATH
mkdir -p src/${REPO}/${APP}
cp ${BASE}/*.go src/${REPO}/${APP}/

cd $GOPATH/src/${REPO}/${APP}
go get --tags physical .
go build --tags physical
# go install --tags physical

cp ${GOPATH}/src/${REPO}/${APP}/${APP} ${BASE}/${APP}${APP_SUFFIX}
file ${BASE}/${APP}${APP_SUFFIX}