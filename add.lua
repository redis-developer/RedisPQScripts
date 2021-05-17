local app = KEYS[1]
local list = app .. ' list'
local counter = app .. ' counter'
local new_val = KEYS[2]

local get_root_obj = redis.call('JSON.GET', app)
if get_root_obj then
        do end
else
        redis.call('JSON.SET', app, '.', "'{ \"list\": [0], \"counter\": {}}'")
end

local dollarize = function (num)
        return '$' .. tostring(num)
end

local list_at = function (index)
        '[' .. tostring(index) .. ']'
end

local counter_at = function (key)
        return counter .. key
end

local sift_up = function (val, index)
        local parent_index = math.floor(index / 2)
        local parent_val = tonumber(redis.call('JSON.GET', list, parent_index))
        while (parent_index > 0) and (val > parent_val) do
                redis.call('JSON.SET', list, parent_index, val)
                redis.call('JSON.SET', list, index, parent_val)
                index = parent_index
                parent_index = math.floor(index / 2)
                parent_val = tonumber(redis.call('JSON.GET', list, parent_index))
        end
end

local new_val_str = dollarize(new_val)

local existing_count = redis.call('JSON.GET', counter, new_val_str)
if existing_count then
        redis.call('JSON.SET', counter, new_val_str, tonumber(existing_count) + 1)
else 
        local heap_size = tonumber(redis.call('JSON.ARRLEN', list))
        redis.call('JSON.ARRAPPEND', list, new_val)
        redis.call('JSON.SET', counter, new_val_str), 1)
        sift_up(new_val, heap_size)
end