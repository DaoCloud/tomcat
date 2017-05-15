#!/bin/sh

# set -ex

image_tag=$1

sed s/\$TOMCAT_VERSION/$image_tag/g Dockerfile.template > Dockerfile
