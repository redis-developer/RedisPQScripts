local app = KEYS[1]
local list = app .. ':list'
local counter = app .. ':counter'
local new_val = tonumber(KEYS[2])

local sift_up = function (val, index)
        local parent_index = math.floor(index / 2)
        local parent_val = tonumber(redis.call('HGET', list, parent_index))
        while (parent_index > 0) and (val > parent_val) do
                redis.call('HSET', list, parent_index, val)
                redis.call('HSET', list, index, parent_val)
                index = parent_index
                parent_index = math.floor(index / 2)
                parent_val = tonumber(redis.call('HGET', list, parent_index))
        end
end

local existing_count = redis.call('HGET', counter, new_val)
if existing_count then
        redis.call('HSET', counter, new_val, tonumber(existing_count) + 1)
else
        local heap_size = tonumber(redis.call('HLEN', list))
        heap_size = heap_size + 1
        redis.call('HSET', list, heap_size, new_val)
        redis.call('HSET', counter, new_val, 1)
        sift_up(new_val, heap_size)
end