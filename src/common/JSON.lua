---json 转换工具（TODO 引用符号：重复引用，循环引用）
---@class JSON by wx771720@outlook.com 2019-08-07 16:03:34
local JSON = {escape = "\\", comma = ",", colon = ":", null = "null"}

---@see JSON
xx.JSON = JSON

---将任意非 nil 数据转换成 json 字符串
---@type fun(data:any,toArray:boolean,toFunction:boolean):string
---@param data any 任意非 nil 数据
---@param toArray boolean 如果是数组，是否按数组格式输出，默认 true
---@param toFunction boolean 是否输出函数，默认 false
---@return string 返回 json 格式的字符串
function JSON.toString(data, toArray, toFunction, __tableList, __keyList)
    if not xx.isBoolean(toArray) then
        toArray = true
    end
    if not xx.isBoolean(toFunction) then
        toFunction = false
    end
    if not xx.isTable(__tableList) then
        __tableList = {}
    end

    local dataType = type(data)
    -- function
    if "function" == dataType then
        return toFunction and '"Function"' or nil
    end
    -- string
    if "string" == dataType then
        data = string.gsub(data, "\\", "\\\\")
        data = string.gsub(data, '"', '\\"')
        return '"' .. data .. '"'
    end
    -- number
    if "number" == dataType then
        return tostring(data)
    end
    -- boolean
    if "boolean" == dataType then
        return data and "true" or "false"
    end
    -- table
    if "table" == dataType then
        xx.arrayPush(__tableList, data)

        local result
        if toArray and JSON.isArray(data) then
            result = "["
            for i = 1, xx.arrayCount(data) do
                if xx.isTable(v) and xx.arrayContains(__tableList, v) then
                    print("json loop refs warning : " .. JSON.toString(xx.arrayPush(xx.arraySlice(__keyList), k)))
                else
                    local valueString =
                        JSON.toString(
                        data[i],
                        toArray,
                        toFunction,
                        xx.arraySlice(__tableList),
                        __keyList and xx.arrayPush(xx.arraySlice(__keyList), i) or {i}
                    )
                    result = result .. (i > 1 and "," or "") .. (valueString or JSON.null)
                end
            end
            result = result .. "]"
        else
            result = "{"
            local index = 0
            for k, v in pairs(data) do
                if xx.isTable(v) and xx.arrayContains(__tableList, v) then
                    print("json loop refs warning : " .. JSON.toString(xx.arrayPush(xx.arraySlice(__keyList), k)))
                else
                    local valueString =
                        JSON.toString(
                        v,
                        toArray,
                        toFunction,
                        xx.arraySlice(__tableList),
                        __keyList and xx.arrayPush(xx.arraySlice(__keyList), k) or {k}
                    )
                    if valueString then
                        result = result .. (index > 0 and "," or "") .. ('"' .. k .. '":') .. valueString
                        index = index + 1
                    end
                end
            end
            result = result .. "}"
        end
        return result
    end
end

---判断指定表是否是数组（不包含字符串索引的表）
---@type fun(target:any):boolean
---@param target any 表
---@return boolean 如果不包含字符串索引则返回 true，否则返回 false
JSON.isArray = function(target)
    if xx.isTable(target) then
        for k, v in pairs(target) do
            -- local valueType = type(v)
            -- if "string" == valueType or "number" == valueType or "boolean" == valueType or "table" == valueType then
            if xx.isString(k) then
                return false
            end
            -- end
        end
        return true
    end
    return false
end

---将字符串转换成 table 对象
---@type fun(text:string):any
---@param text string json 格式的字符串
---@return any|nil 如果解析成功返回对应数据，否则返回 nil
JSON.toJSON = function(text)
    -- string
    if '"' == string.sub(text, 1, 1) and '"' == string.sub(text, -1, -1) then
        return string.sub(JSON.findMeta(text), 2, -2)
    end
    -- boolean
    local lowerText = string.lower(text)
    if "false" == lowerText then
        return false
    elseif "true" == lowerText then
        return true
    end
    -- nil
    if JSON.null == lowerText then
        return
    end
    -- number
    local number = tonumber(text)
    if number then
        return number
    end
    -- array
    if "[" == string.sub(text, 1, 1) and "]" == string.sub(text, -1, -1) then
        local remain = string.gsub(text, "[\r\n]+", "")
        remain = string.sub(remain, 2, -2)
        local array, index, value = {}, 1
        while #remain > 0 do
            value, remain = JSON.findMeta(remain)
            if value then
                value = JSON.toJSON(value)
                array[index] = value
                index = index + 1
            end
        end
        return array
    end
    -- table
    if "{" == string.sub(text, 1, 1) and "}" == string.sub(text, -1, -1) then
        local remain = string.gsub(text, "[\r\n]+", "")
        remain = string.sub(remain, 2, -2)
        local key, value
        local map = {}
        while #remain > 0 do
            key, remain = JSON.findMeta(remain)
            value, remain = JSON.findMeta(remain)
            if key and #key > 0 and value then
                key = JSON.toJSON(key)
                value = JSON.toJSON(value)
                if key and value then
                    map[key] = value
                end
            end
        end
        return map
    end
end

---查找字符串中的 json 元数据
---@type fun(text:string):string, string
---@param text string json 格式的字符串
---@return string,string 元数据,剩余字符串
JSON.findMeta = function(text)
    local stack = {}
    local index = 1
    local lastChar = nil
    while index <= #text do
        local char = string.sub(text, index, index)
        if '"' == char then
            if char == lastChar then
                xx.arrayPop(stack)
                lastChar = #stack > 0 and stack[#stack] or nil
            else
                xx.arrayPush(stack, char)
                lastChar = char
            end
        elseif '"' ~= lastChar then
            if "{" == char then
                xx.arrayPush(stack, "}")
                lastChar = char
            elseif "[" == char then
                xx.arrayPush(stack, "]")
                lastChar = char
            elseif "}" == char or "]" == char then
                assert(char == lastChar, text .. " " .. index .. " not expect " .. char .. "<=>" .. lastChar)
                xx.arrayPop(stack)
                lastChar = #stack > 0 and stack[#stack] or nil
            elseif JSON.comma == char or JSON.colon == char then
                if not lastChar then
                    return string.sub(text, 1, index - 1), string.sub(text, index + 1)
                end
            end
        elseif JSON.escape == char then
            -- index = index + 1
            text = string.sub(text, 1, index - 1) .. string.sub(text, index + 1)
        end

        index = index + 1
    end
    return string.sub(text, 1, index - 1), string.sub(text, index + 1)
end
