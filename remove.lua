local app = KEYS[1]
local list = 'list'
local counter = 'counter'
local is_peek = tonumber(KEYS[2])

local dollarize = function (num)
        return '$' .. tostring(num)
end

local list_at = function(index)
        return list .. '[' .. index .. ']'
end

local counter_at = function(key)
        return counter .. '.' .. key
end

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
                                max_data = tonumber(redis.call('JSON.GET', app, list_at(left_child_index)))
                        end
                else
                        local left_child = tonumber(redis.call('JSON.GET', app, list_at(left_child_index)))
                        local right_child = tonumber(redis.call('JSON.GET', app, list_at(right_child_index)))
                        if (left_child > right_child) then
                                max_index = left_child_index
                                max_data = tonumber(redis.call('JSON.GET', app, list_at(left_child_index)))
                        else
                                max_index = right_child_index
                                max_data = tonumber(redis.call('JSON.GET', app, list_at(right_child_index)))
                        end
                end
                local current_val = tonumber(redis.call('JSON.GET', app, list_at(index)))
                if (current_val < max_data) then
                        redis.call('JSON.SET', app, list_at(index), max_data)
                        redis.call('JSON.SET', app, list_at(max_index), current_val)
                        index = max_index
                        keep_sifting = true
                else
                        keep_sifting = false
                end
        until (keep_sifting)
end

local heap_size = tonumber(redis.call('JSON.ARRLEN', app, list)) - 1
local max_priority = redis.call('JSON.MGET', app, list_at(1))[1]

if (heap_size == 0) then
        return nil
else
        if (is_peek == 1) then
                do end
        else
                local dollar_max_priority = dollarize(max_priority)
                local existing_count = tonumber(redis.call('JSON.MGET', app, counter_at(dollar_max_priority))[1])
                if (existing_count == 1) then
                        redis.call('JSON.DEL', app, counter_at(dollar_max_priority))
                        redis.call('JSON.SET', app, list_at(1), tonumber(redis.call('JSON.GET', app, list_at(heap_size))))
                        redis.call('JSON.DEL', app, list_at(heap_size))
                        sift_down(1, heap_size - 1)
                else
                        redis.call('JSON.SET', app, counter_at(dollar_max_priority), existing_count - 1)
                end
        end
        return max_priority
end