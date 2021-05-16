local app = KEYS[1]
local list = app .. ':list'
local counter = app .. ':counter'
local is_peek = tonumber(KEYS[2])

local sift_down = function (index, heap_size)
        local keep_sifting
        repeat
                local left_child_index = 2 * index
                local right_child_index = 2 * index + 1
                local max_index, max_data
                if (right_child_index > heap_size) then
                        if (left_child_index > heap_size) then
                                return
                        else
                                max_index = left_child_index
                                max_data = tonumber(redis.call('HGET', list, left_child_index))
                        end
                else
                        local left_child = tonumber(redis.call('HGET', list, left_child_index))
                        local right_child = tonumber(redis.call('HGET', list, right_child_index))
                        if (left_child > right_child) then
                                max_index = left_child_index
                                max_data = tonumber(redis.call('HGET', list, left_child_index))
                        else
                                max_index = right_child_index
                                max_data = tonumber(redis.call('HGET', list, right_child_index))
                        end
                end
                local current_val = tonumber(redis.call('HGET', list, index))
                if (current_val < max_data) then
                        redis.call('HSET', list, index, max_data)
                        redis.call('HSET', list, max_index, current_val)
                        index = max_index
                        keep_sifting = true
                else
                        keep_sifting = false
                end
        until (keep_sifting)
end

local heap_size = tonumber(redis.call('HLEN', list))
local max_priority = redis.call('HGET', list, 1)

if (heap_size == 0) then
        return nil
else
        if (is_peek == 1) then
                do end
        else
                local existing_count = tonumber(redis.call('HGET', counter, max_priority))
                if (existing_count == 1) then
                        redis.call('HDEL', counter, max_priority)
                        redis.call('HSET', list, 1, tonumber(redis.call('HGET', list, heap_size)))
                        redis.call('HDEL', list, heap_size)
                        sift_down(1, heap_size - 1)
                else
                        redis.call('HSET', counter, max_priority, existing_count - 1)
                end
        end
        return max_priority
end