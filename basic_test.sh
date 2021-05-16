sleep 20

redis-cli FLUSHALL

for i in 100 100 1000 10 10000 10000; do
        redis-cli eval "$(cat ./add.lua)" 2 MYAPP "$i"
done

for i in {1..2}; do
        cmd="$(redis-cli eval "$(cat ./remove.lua)" 2 MYAPP 1)"
        echo $cmd
        if [[ $cmd != "10000" ]] ; then
                exit 1
        fi
done

for i in "10000" "10000" "1000" "100" "100" "10"; do
        cmd="$(redis-cli eval "$(cat ./remove.lua)" 2 MYAPP 0)"
        echo $cmd
        if [[ $cmd != $i ]] ; then
                exit 1
        fi
done