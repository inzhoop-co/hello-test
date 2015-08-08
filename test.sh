#!/bin/sh

dc_version=$(docker-compose --version | grep docker-compose | cut -c 25-27)
corrigendum=""

if [ "1.3" = "$dc_version" ]; then
  echo "Using docker-compose version 1.3. Adding --no-deps"
  corrigendum="--no-deps"
fi

# start the background containers
docker-compose up $corrigendum --no-recreate -d compilers ipfs helloworldmaster
sleep 10 # give the master a bit of time to get everything sorted

# start the writer
docker-compose up $corrigendum --no-recreate -d helloworldwrite
sleep 30 # give the writer time to catch up with master and deploy contracts

# grab the root contract from the writer
helloworldwrite=$(docker-compose ps -q helloworldwrite)
export ROOT_CONTRACT=$(docker logs $helloworldwrite | grep ROOT_CONTRACT | tail -n 1 | cut -c 16-57)

# helpful for debugging
echo ""
echo ""
echo "Hello Hugo Writer's DOUG Contract is at:"
echo $ROOT_CONTRACT
echo ""

# start the reader
docker-compose up -d $corrigendum --no-recreate helloworldread
sleep 30 # give the reader time to catch up with master and deploy contracts

docker-compose up -d $corrigendum --no-recreate seleniumhub
docker-compose up -d $corrigendum --no-recreate seleniumnode
sleep 30 # sleep for timeout
docker-compose run helloworldtest
