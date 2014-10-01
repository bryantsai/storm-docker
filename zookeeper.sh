#!/bin/bash
PORT=$1
[[ -z "$PORT" ]] && PORT=49181
docker run -p $PORT:2181 -h zookeeper --name zookeeper -d zookeeper:3.4.5
