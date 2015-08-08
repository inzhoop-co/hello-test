#!/bin/sh

dc_version=$(docker-compose --version | grep docker-compose | cut -c 25-27)
corrigendum=""

if [ "1.3" = "$dc_version" ]; then
  corrigendum="--no-deps"
fi

# start the background containers
docker-compose up --no-color $corrigendum --no-recreate compilers ipfs helloworldmaster &
sleep 10 # give the master a bit of time to get everything sorted

# start the writer
docker-compose up --no-color $corrigendum --no-recreate helloworldwrite &
sleep 30 # give the writer time to catch up with master and deploy contracts

# grab the root contract from the writer
helloworldwrite=$(docker-compose ps -q helloworldwrite)
export ROOT_CONTRACT=$(docker logs $helloworldwrite | grep ROOT_CONTRACT | tail -n 1 | cut -c 16-57)

# helpful for debugging
echo ""
echo ""
echo "Hello World Writer's DOUG Contract is at:"
echo $ROOT_CONTRACT
echo ""

# start the reader
docker-compose up --no-color $corrigendum --no-recreate helloworldread &
sleep 30 # give the reader a chance to boot

docker-compose up --no-color -d $corrigendum --no-recreate seleniumhub
docker-compose up --no-color -d $corrigendum --no-recreate seleniumnode

docker-compose up --no-color $corrigendum helloworldtest
docker-compose kill
docker-compose rm --force
docker rmi helloworld_helloworldread
docker rmi helloworld_helloworldwrite
docker rmi -f helloworld_helloworldtest