#!/bin/bash

set -e
set -x

tag=3_200616

docker build -t brainlife/brainstorm container
docker tag brainlife/brainstorm brainlife/brainstorm:$tag 
docker push brainlife/brainstorm:$tag
