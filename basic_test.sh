#!/bin/bash

CMDA = `redis-cli eval "$(cat ./add.lua)" 2 MYAPP 100 && redis-cli eval "$(cat ./add.lua)" 2 MYAPP 100 && redis-cli eval "$(cat ./add.lua)" 2 MYAPP 1000 && redis-cli eval "$(cat ./add.lua)" 2 MYAPP 10 && redis-cli eval "$(cat ./add.lua)" 2 MYAPP 10000 && redis-cli eval "$(cat ./add.lua)" 2 MYAPP 10000 && redis-cli eval "$(cat ./remove.lua)" 2 MYAPP 1 && redis-cli eval "$(cat ./remove.lua)" 2 MYAPP 1 && for i in {1..8}; do redis-cli eval "$(cat ./remove.lua)" 2 MYAPP 0; done`

echo "$CMDA"